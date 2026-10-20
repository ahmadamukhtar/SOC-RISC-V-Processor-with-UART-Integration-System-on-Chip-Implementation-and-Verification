// Author: Ahmad Mukhtar
// Role: Fetches the instruction addressed by the program counter and splits out its decode fields.
// Input: count is a byte PC based at BASE_ADDR (default 0x80000000); data.mem initializes the image.
// Outputs: rs1, rs2, rd, opcode, func_3, and func_7 fields feed the register file and control unit.
// Safety: Out-of-range fetches return ADDI x0,x0,0 rather than indexing outside the instruction array.

`timescale 1ns / 1ps
module instruction_memory #(
    parameter int width = 32,
    parameter int depth = 30,
    parameter logic [31:0] BASE_ADDR = 32'h8000_0000
)(
    input  logic [width-1:0] count,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [6:0] opcode,
    output logic [2:0] func_3,
    output logic       func_7_sig,
    output logic [6:0] func_7
);
    logic [31:0] inst [0:depth-1];
    logic [31:0] current_instruction;
    integer word_index;
    integer i;

    initial begin
        for (i = 0; i < depth; i = i + 1) inst[i] = 32'h0000_0013; // ADDI x0,x0,0
        $readmemh("data.mem", inst);
    end

    always_comb begin
        current_instruction = 32'h0000_0013;
        word_index = -1;
        if (count >= BASE_ADDR) begin
            word_index = (count - BASE_ADDR) >> 2;
            if (word_index >= 0 && word_index < depth)
                current_instruction = inst[word_index];
        end
        rs1       = current_instruction[19:15];
        rs2       = current_instruction[24:20];
        rd        = current_instruction[11:7];
        opcode    = current_instruction[6:0];
        func_3    = current_instruction[14:12];
        func_7_sig = current_instruction[30];
        func_7    = current_instruction[31:25];
    end
endmodule
