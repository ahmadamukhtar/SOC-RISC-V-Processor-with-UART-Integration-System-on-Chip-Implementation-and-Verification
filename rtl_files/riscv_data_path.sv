// Author: Ahmad Mukhtar
// Role: Connects the processor's instruction fetch, decode, execute, memory, and write-back stages.
// Inputs: cpu_clk/reset control sequential state; status supplies the UART-ready value to data memory.
// Outputs: ALU_OUT_check is the current ALU effective result/SoC address, uart_reg is x6[7:0],
//          and signal marks a decoded store for the top-level UART transmit trigger.
// Integration: Instantiates PC, instruction/data memories, register file, immediate generator,
//              operand muxes, ALU, branch comparator, control unit, and write-back mux.

`timescale 1ns / 1ps
module RISC_V_Base_data_path #(
    parameter int width = 32,
    parameter int depth = 30
)(
    input  logic       cpu_clk,
    input  logic       reset,
    output logic [31:0] ALU_OUT_check,
    output logic [7:0] uart_reg,
    input  logic       status,
    output logic       signal
);
    logic [31:0] PC_val, immGen_out, data_R1, data_R2, dataR;
    logic [31:0] data_mux_a_out, data_mux_b_alu, ALU_OUT, mux_out;
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode, func_7;
    logic [2:0] func_3, ImmSel;
    logic func_7_sig, PCSel, BrUn, BSel, ASel, MEMRW, RegWEn;
    logic BrEq, BrLt;
    logic [3:0] ALUSel;
    logic [1:0] WBSel;

    PC #(.width(width)) pc_inst (
        .reset(reset), .cpu_clk(cpu_clk), .PCSel(PCSel),
        .alu_out(ALU_OUT), .count(PC_val)
    );

    instruction_memory #(.width(width), .depth(depth)) instruction_memory_inst (
        .count(PC_val), .rs1(rs1), .rs2(rs2), .rd(rd), .opcode(opcode),
        .func_3(func_3), .func_7_sig(func_7_sig), .func_7(func_7)
    );

    imm_gen immediate_generator (
        .rs1(rs1), .rs2(rs2), .rd(rd), .func_7(func_7), .func_3(func_3),
        .ImmSel(ImmSel), .immGen_out(immGen_out)
    );

    reg_file register_file (
        .cpu_clk(cpu_clk), .reset(reset), .RegWEn(RegWEn),
        .rs1(rs1), .rs2(rs2), .rd(rd), .mux_out(mux_out),
        .data_R1(data_R1), .data_R2(data_R2), .uart_reg(uart_reg)
    );

    mux_A alu_a_mux (
        .ASel(ASel), .count(PC_val), .data_R1(data_R1),
        .data_mux_a_out(data_mux_a_out)
    );
    mux_B alu_b_mux (
        .BSel(BSel), .ImmGen_out(immGen_out), .data_R2(data_R2),
        .data_mux_b_alu(data_mux_b_alu)
    );
    ALU alu_inst (
        .data_mux_a_out(data_mux_a_out), .data_mux_b_alu(data_mux_b_alu),
        .ALUSel(ALUSel), .ALU_OUT(ALU_OUT)
    );

    data_mem data_memory (
        .cpu_clk(cpu_clk), .adr(ALU_OUT), .dataW(data_R2), .MEMRW(MEMRW),
        .func3(func_3), .dataR(dataR), .status(status)
    );
    mux_WB writeback_mux (
        .alu_out(ALU_OUT), .dataR(dataR), .count(PC_val),
        .WBSel(WBSel), .mux_out(mux_out)
    );

    control_unit control_unit_inst (
        .func_3(func_3), .opcode(opcode[6:2]), .func_7(func_7_sig),
        .BrEq(BrEq), .BrLt(BrLt), .PCSel(PCSel), .ImmSel(ImmSel),
        .BrUn(BrUn), .ASel(ASel), .BSel(BSel), .ALUSel(ALUSel),
        .MemRW(MEMRW), .RegWEn(RegWEn), .WBSel(WBSel), .signal(signal)
    );

    Branch_comp branch_comparator (
        .data_R1(data_R1), .data_R2(data_R2), .BrUn(BrUn),
        .BrLT(BrLt), .BrEQ(BrEq)
    );

    assign ALU_OUT_check = ALU_OUT;
endmodule
