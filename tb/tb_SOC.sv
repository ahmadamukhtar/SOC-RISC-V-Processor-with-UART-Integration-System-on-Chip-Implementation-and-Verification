// Author: Ahmad Mukhtar
// Description: Self-checking integration tests for RV32I execution, memories, control flow, and MMIO.
// Test flow: Install a short encoded program, reset the SoC, run it, then check architectural registers.
// Inputs: Testbench-generated clock/reset. UART TX is traced; this bench checks CPU architectural register results.
// Coverage: ALU operations, x0, load/store sizes and extensions, all conditional branches, JAL/JALR, MMIO, and repeated word transfers.

`timescale 1ns / 1ps
module SOC_riscv_uart_tb;
    localparam logic [31:0] RESET_PC = 32'h8000_0000;

    logic clk = 1'b0;
    logic reset = 1'b1;
    logic ser_out;
    int checks = 0;
    int errors = 0;

    SOC_riscv_uart dut (.clk(clk), .reset(reset), .ser_out(ser_out));
    always #5 clk = ~clk;

    // Instruction encoders build small programs in the same bit layout used by the RV32I ISA.
    function automatic logic [31:0] enc_i(
        input integer imm, input integer rs1, input integer funct3,
        input integer rd, input integer opcode
    );
        enc_i = {imm[11:0], rs1[4:0], funct3[2:0], rd[4:0], opcode[6:0]};
    endfunction

    function automatic logic [31:0] enc_r(
        input integer funct7, input integer rs2, input integer rs1,
        input integer funct3, input integer rd, input integer opcode
    );
        enc_r = {funct7[6:0], rs2[4:0], rs1[4:0], funct3[2:0], rd[4:0], opcode[6:0]};
    endfunction

    function automatic logic [31:0] enc_s(
        input integer imm, input integer rs2, input integer rs1, input integer funct3
    );
        enc_s = {imm[11:5], rs2[4:0], rs1[4:0], funct3[2:0], imm[4:0], 7'h23};
    endfunction

    function automatic logic [31:0] enc_b(
        input integer imm, input integer rs2, input integer rs1, input integer funct3
    );
        enc_b = {imm[12], imm[10:5], rs2[4:0], rs1[4:0], funct3[2:0],
                 imm[4:1], imm[11], 7'h63};
    endfunction

    function automatic logic [31:0] enc_u(
        input integer imm20, input integer rd, input integer opcode
    );
        enc_u = {imm20[19:0], rd[4:0], opcode[6:0]};
    endfunction

    function automatic logic [31:0] enc_j(
        input integer imm, input integer rd
    );
        enc_j = {imm[20], imm[10:1], imm[11], imm[19:12], rd[4:0], 7'h6f};
    endfunction

    task automatic put(input integer index, input logic [31:0] instruction);
        if (index < 0 || index >= dut.processor_inst.instruction_memory_inst.depth)
            $fatal(1, "Test program index %0d is outside instruction memory", index);
        dut.processor_inst.instruction_memory_inst.inst[index] = instruction;
    endtask

    task automatic clear_program;
        integer index;
        begin
            for (index = 0; index < dut.processor_inst.instruction_memory_inst.depth; index++)
                put(index, 32'h0000_0013); // ADDI x0,x0,0 (NOP)
        end
    endtask

    // Each test replaces the instruction image before resetting PC/registers to a clean state.
    task automatic restart_core;
        begin
            @(negedge clk);
            reset = 1'b1;
            repeat (2) @(negedge clk);
            reset = 1'b0;
        end
    endtask

    task automatic run_cycles(input integer cycles);
        repeat (cycles) @(negedge clk);
    endtask

    task automatic expect_reg(
        input integer reg_index, input logic [31:0] expected,
        input string label_text
    );
        begin
            checks++;
            if (dut.processor_inst.register_file.registers[reg_index] !== expected) begin
                errors++;
                $error("%s: x%0d expected %08x, observed %08x", label_text,
                       reg_index, expected,
                       dut.processor_inst.register_file.registers[reg_index]);
            end
        end
    endtask

    // RV32I ALU, register-zero, byte/half/word memory, and MMIO checks.
    task automatic test_alu_and_memory;
        begin
            clear_program();
            put(0,  enc_i(-1, 0, 0, 1, 19));                // addi x1,x0,-1
            put(1,  enc_i(127, 0, 0, 2, 19));               // addi x2,x0,127
            put(2,  enc_r(0, 2, 1, 0, 3, 51));              // add x3,x1,x2
            put(3,  enc_r(32, 1, 2, 0, 4, 51));              // sub x4,x2,x1
            put(4,  enc_r(0, 2, 1, 2, 5, 51));              // slt x5,x1,x2
            put(5,  enc_r(0, 2, 1, 3, 6, 51));              // sltu x6,x1,x2
            put(6,  enc_i(255, 2, 4, 7, 19));               // xori x7,x2,255
            put(7,  enc_i(255, 1, 7, 8, 19));               // andi x8,x1,255
            put(8,  enc_i(256, 0, 6, 9, 19));               // ori x9,x0,256
            put(9,  enc_i(1, 2, 1, 10, 19));                // slli x10,x2,1
            put(10, enc_i(4, 1, 5, 11, 19));                // srli x11,x1,4
            put(11, enc_i(1028, 1, 5, 12, 19));             // srai x12,x1,4
            put(12, enc_s(0, 1, 9, 2));                     // sw x1,0(x9)
            put(13, enc_i(0, 9, 0, 13, 3));                // lb x13,0(x9)
            put(14, enc_i(0, 9, 4, 14, 3));                // lbu x14,0(x9)
            put(15, enc_s(1, 2, 9, 0));                     // sb x2,1(x9)
            put(16, enc_i(0, 9, 2, 15, 3));                // lw x15,0(x9)
            put(17, enc_s(2, 2, 9, 1));                     // sh x2,2(x9)
            put(18, enc_i(2, 9, 1, 16, 3));                 // lh x16,2(x9)
            put(19, enc_i(2, 9, 5, 17, 3));                 // lhu x17,2(x9)
            put(20, enc_u('h12345, 18, 55));                // lui x18,0x12345
            put(21, enc_u('h00001, 19, 23));                // auipc x19,0x1
            put(22, enc_i(55, 0, 0, 0, 19));                // attempted write to x0
            put(23, enc_i(1604, 0, 2, 20, 3));              // lw x20,UART_STATUS
            put(24, enc_j(0, 0));                           // jal x0,0 (stop)

            restart_core();
            run_cycles(35);

            expect_reg(0,  32'd0,          "x0 hardwired zero");
            expect_reg(3,  32'd126,        "ADD");
            expect_reg(4,  32'd128,        "SUB");
            expect_reg(5,  32'd1,          "signed SLT");
            expect_reg(6,  32'd0,          "unsigned SLTU");
            expect_reg(7,  32'd128,        "XORI");
            expect_reg(8,  32'd255,        "ANDI");
            expect_reg(9,  32'd256,        "ORI and address base");
            expect_reg(10, 32'd254,        "SLLI");
            expect_reg(11, 32'h0fff_ffff,  "SRLI");
            expect_reg(12, 32'hffff_ffff,  "SRAI");
            expect_reg(13, 32'hffff_ffff,  "LB sign extension");
            expect_reg(14, 32'd255,        "LBU zero extension");
            expect_reg(15, 32'hffff_7fff,  "SB followed by LW");
            expect_reg(16, 32'd127,        "LH");
            expect_reg(17, 32'd127,        "LHU");
            expect_reg(18, 32'h1234_5000,  "LUI");
            expect_reg(19, RESET_PC + 32'd21*4 + 32'h1000, "AUIPC uses current PC");
            expect_reg(20, 32'd1,          "UART ready status MMIO read");
        end
    endtask

    // Exercise taken and not-taken branch decisions. A skipped marker register
    // must remain zero while the target or fall-through marker is written.
    task automatic test_all_branches;
        begin
            clear_program();
            put(0,  enc_i(-1, 0, 0, 1, 19));             // x1 = -1
            put(1,  enc_i(1, 0, 0, 2, 19));              // x2 = 1
            put(2,  enc_i(-1, 0, 0, 3, 19));             // x3 = -1
            put(3,  enc_b(8, 3, 1, 0));                     // BEQ taken
            put(4,  enc_i(1, 0, 0, 10, 19));             // must skip
            put(5,  enc_i(5, 0, 0, 11, 19));             // target
            put(6,  enc_b(8, 2, 1, 0));                     // BEQ not taken
            put(7,  enc_i(7, 0, 0, 12, 19));             // fall-through
            put(8,  enc_b(8, 2, 1, 1));                     // BNE taken
            put(9,  enc_i(1, 0, 0, 13, 19));             // must skip
            put(10, enc_i(10, 0, 0, 14, 19));            // target
            put(11, enc_b(8, 3, 1, 1));                     // BNE not taken
            put(12, enc_i(12, 0, 0, 15, 19));            // fall-through
            put(13, enc_b(8, 2, 1, 4));                     // signed BLT taken (-1 < 1)
            put(14, enc_i(1, 0, 0, 16, 19));             // must skip
            put(15, enc_i(15, 0, 0, 17, 19));            // target
            put(16, enc_b(8, 1, 2, 5));                     // signed BGE taken (1 >= -1)
            put(17, enc_i(1, 0, 0, 18, 19));             // must skip
            put(18, enc_i(18, 0, 0, 19, 19));            // target
            put(19, enc_b(8, 1, 2, 6));                     // unsigned BLTU taken (1 < ffffffff)
            put(20, enc_i(1, 0, 0, 20, 19));             // must skip
            put(21, enc_i(21, 0, 0, 21, 19));            // target
            put(22, enc_b(8, 2, 1, 7));                     // unsigned BGEU taken (ffffffff >= 1)
            put(23, enc_i(1, 0, 0, 22, 19));             // must skip
            put(24, enc_i(24, 0, 0, 23, 19));            // target
            put(25, enc_j(0, 0));                           // stop

            restart_core();
            run_cycles(35);
            expect_reg(10, 32'd0,  "BEQ taken skips instruction");
            expect_reg(11, 32'd5,  "BEQ target executes");
            expect_reg(12, 32'd7,  "BEQ not-taken fall-through");
            expect_reg(13, 32'd0,  "BNE taken skips instruction");
            expect_reg(14, 32'd10, "BNE target executes");
            expect_reg(15, 32'd12, "BNE not-taken fall-through");
            expect_reg(16, 32'd0,  "BLT taken skips instruction");
            expect_reg(17, 32'd15, "BLT target executes");
            expect_reg(18, 32'd0,  "BGE taken skips instruction");
            expect_reg(19, 32'd18, "BGE target executes");
            expect_reg(20, 32'd0,  "BLTU taken skips instruction");
            expect_reg(21, 32'd21, "BLTU target executes");
            expect_reg(22, 32'd0,  "BGEU taken skips instruction");
            expect_reg(23, 32'd24, "BGEU target executes");
        end
    endtask

    // Additional register-register ALU and signed/unsigned immediate cases.
    task automatic test_remaining_alu_ops;
        begin
            clear_program();
            put(0,  enc_i(-128, 0, 0, 1, 19));              // addi x1,x0,-128
            put(1,  enc_i(3, 0, 0, 2, 19));                 // addi x2,x0,3
            put(2,  enc_r(0, 2, 1, 4, 3, 51));              // xor x3,x1,x2
            put(3,  enc_r(0, 2, 1, 6, 4, 51));              // or x4,x1,x2
            put(4,  enc_r(0, 2, 1, 7, 5, 51));              // and x5,x1,x2
            put(5,  enc_r(0, 2, 2, 1, 6, 51));              // sll x6,x2,x2
            put(6,  enc_r(0, 2, 1, 5, 7, 51));              // srl x7,x1,x2
            put(7,  enc_r(32, 2, 1, 5, 8, 51));             // sra x8,x1,x2
            put(8,  enc_i(0, 1, 2, 9, 19));                 // slti x9,x1,0
            put(9,  enc_i(0, 1, 3, 10, 19));                // sltiu x10,x1,0
            put(10, enc_i(-1, 1, 3, 11, 19));               // sltiu x11,x1,-1
            put(11, enc_j(0, 0));                           // stop

            restart_core();
            run_cycles(20);
            expect_reg(3, 32'hffff_ff83, "register XOR");
            expect_reg(4, 32'hffff_ff83, "register OR");
            expect_reg(5, 32'd0,         "register AND");
            expect_reg(6, 32'd24,        "register SLL");
            expect_reg(7, 32'h1fff_fff0, "register SRL");
            expect_reg(8, 32'hffff_fff0, "register SRA");
            expect_reg(9, 32'd1,         "signed SLTI");
            expect_reg(10, 32'd0,        "unsigned SLTIU against zero");
            expect_reg(11, 32'd1,        "unsigned SLTIU against -1 immediate");
        end
    endtask

    // Verify direct and indirect jumps, skipped sequential instructions, and PC+4 links.
    task automatic test_jumps;
        begin
            clear_program();
            put(0, enc_u(0, 1, 23));                     // auipc x1,0
            put(1, enc_i(32, 1, 0, 1, 19));              // target is instruction 8
            put(2, enc_j(12, 4));                           // jal x4,+12 to instruction 5
            put(3, enc_i(1, 0, 0, 3, 19));                  // skipped by JAL
            put(4, enc_i(2, 0, 0, 3, 19));                  // skipped by JAL
            put(5, enc_i(0, 1, 0, 2, 103));                 // jalr x2,x1,0
            put(6, enc_i(6, 0, 0, 5, 19));                  // skipped by JALR
            put(7, enc_i(7, 0, 0, 5, 19));                  // skipped by JALR
            put(8, enc_i(8, 0, 0, 6, 19));                  // target reached by JALR
            put(9, enc_j(0, 0));                            // stop

            restart_core();
            run_cycles(20);
            expect_reg(2, RESET_PC + 32'd24, "JALR return address");
            expect_reg(3, 32'd0, "JALR skips sequential instructions");
            expect_reg(4, RESET_PC + 32'd12, "JAL return address");
            expect_reg(5, 32'd0, "JALR skips sequential instructions");
            expect_reg(6, 32'd8, "jump target executes");
        end
    endtask

    // Deterministically varied data-store/load sequence; each value is
    // written to RAM and checked after being read back through the CPU.
    task automatic test_varied_word_memory;
        logic [31:0] expected [0:7];
        logic [31:0] value;
        integer n;
        begin
            clear_program();
            // Initialize x1 with base address 0x200; x2 is loaded per generated pair.
            put(0, enc_i('h200, 0, 0, 1, 19));
            for (n = 0; n < 8; n++) begin
                value = 32'h91e1_0da5 ^ (32'h1020_4081 * (n + 1));
                expected[n] = value;
                put(1 + n*2, enc_u((value >> 12), 2, 55));
                put(2 + n*2, enc_s(n*4, 2, 1, 2));
            end
            // Read back all eight words into x10-x17.
            for (n = 0; n < 8; n++)
                put(17 + n, enc_i(n*4, 1, 2, 10+n, 3));
            put(25, enc_j(0, 0));

            restart_core();
            run_cycles(40);
            for (n = 0; n < 8; n++) begin
                expect_reg(10+n, expected[n] & 32'hffff_f000,
                           "randomized upper-immediate word store/load");
            end
        end
    endtask

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars(0, SOC_riscv_uart_tb);
        repeat (3) @(negedge clk);
        reset = 1'b0;

        // Run independent programs in sequence. restart_core() asserts reset
        // between programs so state from one scenario cannot mask another.
        test_alu_and_memory();
        test_remaining_alu_ops();
        test_all_branches();
        test_jumps();
        test_varied_word_memory();

        if (errors != 0)
            $fatal(1, "TESTS FAILED: %0d of %0d checks failed", errors, checks);
        $display("PASS: %0d checks across ALU, memory, branches, jumps, and MMIO", checks);
        $finish;
    end

    // Catch hangs or broken control flow rather than silently ending a run.
    initial begin
        #20000;
        $fatal(1, "Global testbench timeout");
    end
endmodule
