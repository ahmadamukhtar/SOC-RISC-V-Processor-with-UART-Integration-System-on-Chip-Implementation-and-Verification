`timescale 1ns / 1ps
module ALU (
    input logic [31:0]data_mux_a_out,
    input logic [31:0]data_mux_b_alu,
    input logic [3:0] ALUSel,  // 4-bit ALU operation selector
    output logic [31:0] ALU_OUT
);

always_comb begin
    case (ALUSel)
        4'b0000: ALU_OUT = data_mux_a_out +data_mux_b_alu;  // ADD
        4'b0001: ALU_OUT = data_mux_a_out -data_mux_b_alu;  // SUB
        4'b0010: ALU_OUT = data_mux_a_out &data_mux_b_alu;  // AND
        4'b0011: ALU_OUT = data_mux_a_out |data_mux_b_alu;  // OR
        4'b0100: ALU_OUT = data_mux_a_out ^data_mux_b_alu;  // XOR
        4'b0101: ALU_OUT = data_mux_a_out <<data_mux_b_alu[4:0];  // SLL
        4'b0110: ALU_OUT = data_mux_a_out >>data_mux_b_alu[4:0];  // SRL
        4'b0111: ALU_OUT = $signed(data_mux_a_out) >>> data_mux_b_alu[4:0];  // SRA
        4'b1000: ALU_OUT = ($signed(data_mux_a_out) < $signed(data_mux_b_alu)) ? 32'b1 : 32'b0;  // SLT
        4'b1001: ALU_OUT = (data_mux_a_out < data_mux_b_alu) ? 32'b1 : 32'b0;  // SLTU
        4'b1010: ALU_OUT = {data_mux_b_alu<<12}+data_mux_a_out;//aupic
        4'b1011: ALU_OUT = {data_mux_b_alu<<12};//aupic
        default: ALU_OUT = 32'b0;  // Default to zero
    endcase
end
endmodule
