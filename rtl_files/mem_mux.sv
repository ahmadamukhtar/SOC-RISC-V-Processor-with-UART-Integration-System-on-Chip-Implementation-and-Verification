// Author: Ahmad Mukhtar
// Role: Closes the datapath write-back path by choosing which result is written to rd.
// Inputs: WBSel selects dataR, alu_out, or current PC+4 for load, ALU, or link instructions.
// Output: mux_out is the 32-bit value presented to the register-file write port.

`timescale 1ns / 1ps
module mux_WB #(
    parameter int width = 32
)(
    input  logic [31:0] alu_out,
    input  logic [31:0] dataR,
    input  logic [width-1:0] count,
    input  logic [1:0] WBSel,
    output logic [31:0] mux_out
);
    always_comb begin
        case (WBSel)
            2'd0: mux_out = dataR;
            2'd1: mux_out = alu_out;
            2'd2: mux_out = count + 32'd4;
            default: mux_out = 32'b0;
        endcase
    end
endmodule
