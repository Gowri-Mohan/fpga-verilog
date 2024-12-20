`timescale 1ns / 1ps

module fir_filter (
    input clk,
    input reset,
    input signed [15:0] sample_in,
    output reg signed [15:0] sample_out
);
    // Coefficients for the filter
    reg signed [15:0] coeff [0:2];
    reg signed [15:0] pipeline [0:2];
    reg signed [31:0] acc;

    initial begin
        // Example coefficients for low-pass filter (normalized for scaling)
        coeff[0] = 16'd1024; // Scaled-up value for better precision
        coeff[1] = 16'd2048; // Scaled-up value for better precision
        coeff[2] = 16'd1024; // Scaled-up value for better precision
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_out <= 16'd0;
            pipeline[0] <= 16'd0;
            pipeline[1] <= 16'd0;
            pipeline[2] <= 16'd0;
        end else begin
            // Shift pipeline and multiply in parallel
            pipeline[2] <= pipeline[1];
            pipeline[1] <= pipeline[0];
            pipeline[0] <= sample_in;

            // Accumulate results with coefficients
            acc = (pipeline[0] * coeff[0]) +
                  (pipeline[1] * coeff[1]) +
                  (pipeline[2] * coeff[2]);

            // Normalize output using bit-shift (avoids rounding issues)
            sample_out <= acc[31:16] >> 2;
        end
    end
endmodule
