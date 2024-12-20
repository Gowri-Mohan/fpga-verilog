`timescale 1ns / 1ps
module top_tb;
    reg clk, reset;
    wire signed [15:0] adc_out;
    wire signed [15:0] filtered_out;
    wire signed [15:0] fft_real_out, fft_imag_out;

    // Instantiate ADC Simulation
    adc_sim adc_inst (
        .clk(clk),
        .reset(reset),
        .adc_out(adc_out)
    );

    // Instantiate FIR Filter
    fir_filter fir_inst (
        .clk(clk),
        .reset(reset),
        .sample_in(adc_out),
        .sample_out(filtered_out)
    );


    fft fft_inst (
        .clk(clk),
        .reset(reset),
        .sample_in(filtered_out), // Input from FIR filter
        .fft_real_out(fft_real_out),
        .fft_imag_out(fft_imag_out)
    );

    initial begin
        $dumpfile("waveform.vcd"); // Generate VCD file for GTKWave
        $dumpvars(0, top_tb);      // Dump all signals in the testbench


        clk = 0;
        reset = 1;
        #10 reset = 0;            // De-assert reset after 10 time units
        #2000 $finish;             // End simulation after 500 time units
    end
     

    always #5 clk = ~clk; // Generate clock signal with a 10ns period
endmodule

