`timescale 1ns / 1ps
module imm_gen(
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [6:0] func_7,
    input logic [2:0] func_3,
    input logic [2:0] ImmSel,         // Control signal to select the immediate type
    output logic [31:0] immGen_out    // Sign-extended 32-bit immediate
);

always_comb
    case(ImmSel)
        3'b000: begin // I-type
            immGen_out = {{20{func_7[6]}}, func_7, rs2}; 
        end
        3'b001: begin  // U-type
            immGen_out = {{12{func_7[6]}}, func_7, rs2, rs1, func_3}; 
        end
        3'b010: begin // S-type
            immGen_out = {{20{func_7[6]}}, func_7, rd}; 
        end
        3'b011: begin // B-type 13bit imm
            immGen_out = {{19{func_7[6]}}, func_7[6], rd[0], func_7[5:0], rd[4:1], 1'b0};
        end
        3'b100: begin // J-type   20bit imm
            immGen_out = {{11{func_7[6]}}, func_7[6], rs1, func_3, rs2[0], func_7[5:0], rs2[4:1], 1'b0}; 
        end
        default: immGen_out = 32'b0;
    endcase
endmodule
