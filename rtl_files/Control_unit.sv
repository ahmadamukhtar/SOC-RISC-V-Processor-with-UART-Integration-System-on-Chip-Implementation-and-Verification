// Author: Ahmad Mukhtar
// Role: Turns the fetched instruction fields and branch comparison flags into core control signals.
// Inputs: opcode/funct fields identify the operation; BrEq/BrLt provide branch comparison results.
// Outputs: select PC/immediate/ALU/memory/register-write controls and the SoC store strobe `signal`.
// Scope: Supports the RV32I integer instructions implemented by this datapath; unsupported encodings act as NOPs.

module control_unit(
    input  logic [2:0] func_3,
    input  logic [4:0] opcode,
    input  logic       func_7,
    input  logic       BrEq,
    input  logic       BrLt,
    output logic       PCSel,
    output logic [2:0] ImmSel,
    output logic       BrUn,
    output logic       ASel,
    output logic       BSel,
    output logic [3:0] ALUSel,
    output logic       MemRW,
    output logic       RegWEn,
    output logic [1:0] WBSel,
    output logic       signal
);

    localparam logic [3:0] ALU_ADD = 4'd0, ALU_SUB = 4'd1,
                           ALU_AND = 4'd2, ALU_OR = 4'd3,
                           ALU_XOR = 4'd4, ALU_SLL = 4'd5,
                           ALU_SRL = 4'd6, ALU_SRA = 4'd7,
                           ALU_SLT = 4'd8, ALU_SLTU = 4'd9,
                           ALU_AUIPC = 4'd10, ALU_LUI = 4'd11,
                           ALU_JALR = 4'd12;
    localparam logic [2:0] IMM_I = 3'd0, IMM_U = 3'd1,
                           IMM_S = 3'd2, IMM_B = 3'd3, IMM_J = 3'd4;
    localparam logic [1:0] WB_MEM = 2'd0, WB_ALU = 2'd1, WB_PC4 = 2'd2;

    always_comb begin
        // Safe defaults make unsupported instructions behave as NOPs.
        PCSel = 1'b0; ImmSel = IMM_I; BrUn = 1'b0; ASel = 1'b0;
        BSel = 1'b0; ALUSel = ALU_ADD; MemRW = 1'b0; RegWEn = 1'b0;
        WBSel = WB_ALU; signal = 1'b0;

        case (opcode)
            5'b00000: begin // LB, LH, LW, LBU, and LHU.
                if (func_3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101}) begin
                    BSel = 1'b1; RegWEn = 1'b1; WBSel = WB_MEM;
                end
            end
            5'b00100: begin // ADDI, shifts, comparisons, and logic immediates.
                BSel = 1'b1; RegWEn = 1'b1; WBSel = WB_ALU;
                case (func_3)
                    3'b000: ALUSel = ALU_ADD;
                    3'b001: ALUSel = ALU_SLL;
                    3'b010: ALUSel = ALU_SLT;
                    3'b011: ALUSel = ALU_SLTU;
                    3'b100: ALUSel = ALU_XOR;
                    3'b101: ALUSel = func_7 ? ALU_SRA : ALU_SRL;
                    3'b110: ALUSel = ALU_OR;
                    3'b111: ALUSel = ALU_AND;
                    default: RegWEn = 1'b0;
                endcase
            end
            5'b00101: begin // AUIPC: PC plus upper immediate.
                ASel = 1'b1; BSel = 1'b1; ImmSel = IMM_U;
                ALUSel = ALU_AUIPC; RegWEn = 1'b1; WBSel = WB_ALU;
            end
            5'b01101: begin // LUI: load upper immediate.
                BSel = 1'b1; ImmSel = IMM_U; ALUSel = ALU_LUI;
                RegWEn = 1'b1; WBSel = WB_ALU;
            end
            5'b01000: begin // SB, SH, and SW.
                if (func_3 inside {3'b000, 3'b001, 3'b010}) begin
                    BSel = 1'b1; ImmSel = IMM_S; MemRW = 1'b1; signal = 1'b1;
                end
            end
            5'b01100: begin // ADD/SUB, shifts, comparisons, and logic registers.
                RegWEn = 1'b1; WBSel = WB_ALU;
                case (func_3)
                    3'b000: ALUSel = func_7 ? ALU_SUB : ALU_ADD;
                    3'b001: ALUSel = ALU_SLL;
                    3'b010: ALUSel = ALU_SLT;
                    3'b011: ALUSel = ALU_SLTU;
                    3'b100: ALUSel = ALU_XOR;
                    3'b101: ALUSel = func_7 ? ALU_SRA : ALU_SRL;
                    3'b110: ALUSel = ALU_OR;
                    3'b111: ALUSel = ALU_AND;
                    default: RegWEn = 1'b0;
                endcase
            end
            5'b11000: begin // BEQ, BNE, BLT, BGE, BLTU, and BGEU.
                ASel = 1'b1; BSel = 1'b1; ImmSel = IMM_B; ALUSel = ALU_ADD;
                case (func_3)
                    3'b000: PCSel = BrEq;
                    3'b001: PCSel = !BrEq;
                    3'b100: PCSel = BrLt;
                    3'b101: PCSel = !BrLt || BrEq;
                    3'b110: begin PCSel = BrLt; BrUn = 1'b1; end
                    3'b111: begin PCSel = !BrLt || BrEq; BrUn = 1'b1; end
                    default: begin PCSel = 1'b0; ASel = 1'b0; BSel = 1'b0; end
                endcase
            end
            5'b11001: begin // JALR: rs1 plus immediate, aligned to 2 bytes.
                PCSel = 1'b1; BSel = 1'b1; ALUSel = ALU_JALR;
                RegWEn = (func_3 == 3'b000); WBSel = WB_PC4;
            end
            5'b11011: begin // JAL: PC plus J-immediate.
                PCSel = 1'b1; ASel = 1'b1; BSel = 1'b1; ImmSel = IMM_J;
                RegWEn = 1'b1; WBSel = WB_PC4;
            end
            default: begin
                // Safe NOP defaults remain active.
            end
        endcase
    end
endmodule
