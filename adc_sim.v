`timescale 1ns / 1ps
module adc_sim (
    input clk,
    input reset,
    output reg signed [15:0] adc_out // 16-bit ADC output
);
    reg [15:0] counter; // Simulates time steps for sine wave generation
    real sine_value;    // Temporary variable for sine calculation

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            adc_out <= 16'd0;
        end else begin
            counter <= counter + 16'd1;

            // Simulate a sine wave using real numbers
            sine_value = 1000.0 * $sin(2.0 * 3.14159 * counter / 1024.0);
            adc_out <= $rtoi(sine_value); // Convert real to signed integer
        end
    end
endmodule
