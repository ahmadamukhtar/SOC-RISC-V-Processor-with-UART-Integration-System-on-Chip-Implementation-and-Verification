// Author: Ahmad Mukhtar
// Role: Reassembles split instruction bits into the immediate used by the ALU/address path.
// Inputs: rs1/rs2/rd/funct fields are the instruction slices; ImmSel selects I, U, S, B, or J format.
// Output: immGen_out is the 32-bit sign-extended or aligned immediate for the selected format.

`timescale 1ns / 1ps
module imm_gen(
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    input  logic [6:0] func_7,
    input  logic [2:0] func_3,
    input  logic [2:0] ImmSel,
    output logic [31:0] immGen_out
);
    always_comb begin
        case (ImmSel)
            3'd0: immGen_out = {{20{func_7[6]}}, func_7, rs2};
            3'd1: immGen_out = {func_7, rs2, rs1, func_3, 12'b0};
            3'd2: immGen_out = {{20{func_7[6]}}, func_7, rd};
            3'd3: immGen_out = {{19{func_7[6]}}, func_7[6], rd[0],
                                  func_7[5:0], rd[4:1], 1'b0};
            3'd4: immGen_out = {{11{func_7[6]}}, func_7[6], rs1, func_3,
                                  rs2[0], func_7[5:0], rs2[4:1], 1'b0};
            default: immGen_out = 32'b0;
        endcase
    end
endmodule
