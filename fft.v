`timescale 1ns / 1ps

module fft (
    input clk,
    input reset,
    input signed [15:0] sample_in,       // Input signal from FIR filter
    output reg signed [15:0] fft_real_out, // Real part of FFT output
    output reg signed [15:0] fft_imag_out  // Imaginary part of FFT output
);
    parameter N = 8;             // Number of FFT points
    parameter WIDTH = 16;        // Input/output bit width

    // Buffers for FFT computation
    reg signed [WIDTH-1:0] real_buf [0:N-1];
    reg signed [WIDTH-1:0] imag_buf [0:N-1];

    // Precomputed twiddle factors (hardcoded values for N = 8)
    reg signed [WIDTH-1:0] twiddle_real [0:3];
    reg signed [WIDTH-1:0] twiddle_imag [0:3];

    integer stage, butterfly, k, j;
    reg signed [31:0] temp_real, temp_imag; // Temporary storage for butterfly results

    // Initialize twiddle factors
    initial begin
        // Hardcoded cosine and sine values scaled to 15-bit
        twiddle_real[0] = 16'd32767;  // cos(0) = 1.0
        twiddle_real[1] = 16'd23170;  // cos(pi/4) ≈ 0.707
        twiddle_real[2] = 16'd0;      // cos(pi/2) = 0
        twiddle_real[3] = -16'd23170; // cos(3*pi/4) ≈ -0.707

        twiddle_imag[0] = 16'd0;      // sin(0) = 0
        twiddle_imag[1] = -16'd23170; // sin(-pi/4) ≈ -0.707
        twiddle_imag[2] = -16'd32767; // sin(-pi/2) = -1.0
        twiddle_imag[3] = -16'd23170; // sin(-3*pi/4) ≈ -0.707
    end

    // FFT Computation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset buffers and outputs
            fft_real_out <= 0;
            fft_imag_out <= 0;
            for (integer i = 0; i < N; i = i + 1) begin
                real_buf[i] <= 0;
                imag_buf[i] <= 0;
            end
        end else begin
            // Shift input samples into real buffer
            real_buf[0] <= sample_in;
            for (integer i = 1; i < N; i = i + 1) begin
                real_buf[i] <= real_buf[i-1];
                imag_buf[i] <= 0; // Initialize imaginary buffer
            end

            // Perform FFT processing using Radix-2 DIT
            for (stage = 0; stage < $clog2(N); stage = stage + 1) begin
                for (butterfly = 0; butterfly < (N >> (stage + 1)); butterfly = butterfly + 1) begin
                    k = butterfly + (N >> (stage + 1)); // Pair index
                    j = butterfly % (N >> (stage + 1)); // Twiddle factor index

                    // Butterfly computations
                    temp_real = real_buf[k] * twiddle_real[j] - imag_buf[k] * twiddle_imag[j];
                    temp_imag = real_buf[k] * twiddle_imag[j] + imag_buf[k] * twiddle_real[j];

                    // Update real and imaginary buffers
                    real_buf[k] <= real_buf[butterfly] - temp_real;
                    imag_buf[k] <= imag_buf[butterfly] - temp_imag;

                    real_buf[butterfly] <= real_buf[butterfly] + temp_real;
                    imag_buf[butterfly] <= imag_buf[butterfly] + temp_imag;
                end
            end

            // Output the DC component as an example
            fft_real_out <= real_buf[0];
            fft_imag_out <= imag_buf[0];
        end
    end
endmodule
