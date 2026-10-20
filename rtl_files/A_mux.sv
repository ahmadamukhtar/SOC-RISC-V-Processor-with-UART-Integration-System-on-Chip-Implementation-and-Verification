// Author: Ahmad Mukhtar
// Role: Supplies the ALU's first operand in the processor datapath.
// Inputs: ASel chooses count (the current PC) or data_R1 (register-file rs1 data).
// Output: data_mux_a_out is the selected 32-bit value sent to the ALU.

`timescale 1ns / 1ps
module mux_A(
    input logic ASel,
    input logic [31:0]count,
    input logic [31:0]data_R1,
    output logic [31:0]data_mux_a_out
);
    assign data_mux_a_out = (ASel) ? (count) : (data_R1);
endmodule
