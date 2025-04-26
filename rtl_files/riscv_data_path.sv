`timescale 1ns / 1ps
module RISC_V_Base_data_path(
    input logic cpu_clk,
    input logic reset,
    output logic [31:0]ALU_OUT_check,
    output logic [7:0]uart_reg,
    input logic status,
     output logic signal
);
    
      parameter [31:0]width=32;     //width in n bit
      parameter [31:0]depth=255;      //depth in n
     logic [31:0]data_mux_b_alu;
      logic BrEq;
      logic BrLt;
      logic [2:0]ImmSel;
      logic [width-1:0]PC_val;
      logic RegWEn;
    // Internal signals
    logic  [31:0]jump_addr, immGen_out, return_address;
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode;
    logic func_7_sig;
    logic [6:0] func_7;
    logic [2:0] func_3;
    logic PCSel, BrUn, BSel, ASel, MEMRW;
    logic [3:0] ALUSel;
    logic [31:0] ALU_OUT, data_2_alu,data_R2, mux_out_data, dataR, data_mux_a_out;
    logic [31:0]data_R1;
    logic [1:0] WBSel;
    logic [31:0]mux_out;
logic [31:0]abc;
 assign abc=(PCSel)?(ALU_OUT):(PC_val);
    // Program Counter
    PC #(width)pc_inst (
        .reset(reset),
        .cpu_clk(cpu_clk),
        .PCSel(PCSel),
        .alu_out(ALU_OUT),
        .count(PC_val)
    );

    // Instruction Memory
    instruction_memory #(width,depth) IM (
        .count(PC_val),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .func_3(func_3),
        .func_7_sig(func_7_sig),
        .func_7(func_7)
    );

    // Immediate Generator
    imm_gen immgen_inst(
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .func_7(func_7),
        .func_3(func_3),
        .ImmSel(ImmSel),
        .immGen_out(immGen_out)
    );

   //  Register File
    reg_file reg_file_inst (
        .cpu_clk(cpu_clk),
        .RegWEn(RegWEn),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .mux_out(mux_out),
        .data_R1(data_R1),
        .data_R2(data_R2),.uart_reg(uart_reg)
    );
//    reg_file reg_file_inst (
//        .cpu_clk(cpu_clk),
//        .RegWEn(RegWEn),
//        .rs1(rs1),
//        .rs2(rs2),
//        .rd(rd),
//        .mux_out(mux_out),
//        .data_R1(data_R1),
//        .data_R2(data_R2)
//    );

    // ALU Input MUX (mux_B)
    mux_B mux_b_inst (
        .BSel(BSel),
        .ImmGen_out(immGen_out),
        .data_R2(data_R2),
        .data_mux_b_alu(data_mux_b_alu)
    );

    // ALU
    ALU alu_inst (
        .data_mux_a_out(data_mux_a_out),
        .data_mux_b_alu(data_mux_b_alu),
        .ALUSel(ALUSel),
        .ALU_OUT(ALU_OUT)
    );

    // Data Memory
    data_mem data_mem_inst (
        .cpu_clk(cpu_clk),
        .adr(ALU_OUT),
        .dataW(data_R2),
        .MEMRW(MEMRW),
        .func3(func_3[1:0]),
        .dataR(dataR),.status(status)
    );

    // Write Back MUX (mux_WB)
    mux_WB mux_wb_inst (
        .alu_out(ALU_OUT),
        .dataR(dataR),
        .count(PC_val),
        .WBSel(WBSel),
        .mux_out(mux_out)
    );

    // Control Unit
    control_unit control_unit_inst (
        .func_3(func_3),
        .opcode(opcode[6:2]),
        .func_7(func_7_sig),
        .BrEq(BrEq),
        .BrLt(BrLt),
        .PCSel(PCSel),
        .ImmSel(ImmSel),
        .BrUn(BrUn),
        .ASel(ASel),
        .BSel(BSel),
        .ALUSel(ALUSel),
        .MemRW(MEMRW),
        .RegWEn(RegWEn),
        .WBSel(WBSel),.signal(signal)
    );

    // Branch Comparator
    Branch_comp branch_comp_inst (
        .data_R1(data_R1),
        .data_R2(data_R2),
        .BrUn(BrUn),
        .BrLT(BrLt),
        .BrEQ(BrEq)
    );

    // MUX_A for ALU source A selection
    mux_A mux_a_inst (
        .ASel(ASel),
        .count(PC_val),
        .data_R1(data_R1),
        .data_mux_a_out(data_mux_a_out)
    );


//tracer tracer_ip (
//    .clk_i(cpu_clk),                  
//    .rst_ni(reset),                 
//    .hart_id_i(32'b0),                  
//    .rvfi_valid(1'b1),                  
//   // .rvfi_insn_t({opcode, func_3, func_7}), 
//    .rvfi_insn_t({func_7,rs2,rs1,func_3,rd,opcode}), 
//    .rvfi_rs1_addr_t(rs1),              
//    .rvfi_rs2_addr_t(rs2),              
//    .rvfi_rs1_rdata_t(data_R1),      
//    .rvfi_rs2_rdata_t(data_R2),        
//    .rvfi_rd_addr_t(rd),                
//    .rvfi_rd_wdata_t(mux_out),          // Write-back data (what is written to rd)
//    .rvfi_pc_rdata_t(PC_val),           // Current program counter value
//    .rvfi_pc_wdata_t(abc),          // Next program counter value (ALU result)  /// pc mux
//    .rvfi_mem_addr(0),            // Memory address is the ALU output  ///aluout
//    .rvfi_mem_rmask(4'b0),              // Memory read mask, assuming no memory operation in this case
//    .rvfi_mem_wmask(4'b0),              // Memory write mask, assuming no memory operation
//    .rvfi_mem_rdata(32'b0),             // Memory read data, assuming no memory read in this case
//    .rvfi_mem_wdata(32'b0)              // Memory write data, assuming no memory write in this case
//);

  assign ALU_OUT_check=ALU_OUT;  

endmodule
