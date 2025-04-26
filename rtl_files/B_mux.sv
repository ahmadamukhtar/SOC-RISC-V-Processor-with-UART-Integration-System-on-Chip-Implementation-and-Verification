`timescale 1ns / 1ps
module mux_B(
    input logic BSel,
    input logic [31:0] ImmGen_out,
    input logic [31:0] data_R2,
    output logic [31:0] data_mux_b_alu
);
    assign data_mux_b_alu = (BSel) ? (ImmGen_out) : (data_R2);
endmodule
