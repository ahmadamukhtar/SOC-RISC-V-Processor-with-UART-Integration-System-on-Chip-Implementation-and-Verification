`timescale 1ns / 1ps
module mux_A(
    input logic ASel,
    input logic [31:0]count,
    input logic [31:0]data_R1,
    output logic [31:0]data_mux_a_out
);
    assign data_mux_a_out = (ASel) ? (count) : (data_R1);
endmodule
