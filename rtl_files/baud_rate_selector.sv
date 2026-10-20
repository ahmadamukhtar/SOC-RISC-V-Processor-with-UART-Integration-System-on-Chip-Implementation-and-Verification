// Author: Ahmad Mukhtar
// Role: Chooses the timing clock that advances UART transmit bit states.
// Inputs: clk_in/reset feed the source clock and dividers; S selects a baud-clock option.
// Output: clk_out is clk_in for S=00; S=01 selects /20833, S=10 selects /868, S=11 selects /100000000.

`timescale 1ns / 1ps
module baud_rate_selector(
    input logic clk_in,
    input logic reset,
    input logic [1:0] S,
    output logic clk_out
);

    logic clk_out_1, clk_out_2, clk_out_3;
    logic clk_out_0;

    assign clk_out_0 = clk_in;

    // Divider outputs are available for 4800, 115200, and very slow debug rates
    // when the input clock is 100 MHz; S=00 bypasses division for simulation.
    clock_divider div_4800   (.clk_in(clk_in), .reset(reset), .clk_out(clk_out_1), .DIV_FACTOR(32'd20_833));
    clock_divider div_115200 (.clk_in(clk_in), .reset(reset), .clk_out(clk_out_2), .DIV_FACTOR(32'd868));
    clock_divider div_debug  (.clk_in(clk_in), .reset(reset), .clk_out(clk_out_3), .DIV_FACTOR(32'd100_000_000));

    always_comb begin
        case (S)
            2'b00: clk_out = clk_out_0;
            2'b01: clk_out = clk_out_1;
            2'b10: clk_out = clk_out_2;
            2'b11: clk_out = clk_out_3;
            default: clk_out = clk_in; 
        endcase
    end
endmodule
