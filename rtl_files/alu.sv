// Author: Ahmad Mukhtar
// Role: Executes the operation selected by the control unit for the current instruction.
// Inputs: data_mux_a_out/data_mux_b_alu are the selected operands; ALUSel chooses the operation.
// Output: ALU_OUT is the arithmetic/result value, effective data address, or branch/jump target.
// Scope: Includes base integer ALU ops plus dedicated AUIPC, LUI, and JALR result modes.

`timescale 1ns / 1ps
module ALU (
    input  logic [31:0] data_mux_a_out,
    input  logic [31:0] data_mux_b_alu,
    input  logic [3:0]  ALUSel,
    output logic [31:0] ALU_OUT
);
    always_comb begin
        case (ALUSel)
            4'd0:  ALU_OUT = data_mux_a_out + data_mux_b_alu;
            4'd1:  ALU_OUT = data_mux_a_out - data_mux_b_alu;
            4'd2:  ALU_OUT = data_mux_a_out & data_mux_b_alu;
            4'd3:  ALU_OUT = data_mux_a_out | data_mux_b_alu;
            4'd4:  ALU_OUT = data_mux_a_out ^ data_mux_b_alu;
            4'd5:  ALU_OUT = data_mux_a_out << data_mux_b_alu[4:0];
            4'd6:  ALU_OUT = data_mux_a_out >> data_mux_b_alu[4:0];
            4'd7:  ALU_OUT = $signed(data_mux_a_out) >>> data_mux_b_alu[4:0];
            4'd8:  ALU_OUT = ($signed(data_mux_a_out) < $signed(data_mux_b_alu)) ? 32'd1 : 32'd0;
            4'd9:  ALU_OUT = (data_mux_a_out < data_mux_b_alu) ? 32'd1 : 32'd0;
            4'd10: ALU_OUT = data_mux_a_out + data_mux_b_alu;
            4'd11: ALU_OUT = data_mux_b_alu;
            4'd12: ALU_OUT = (data_mux_a_out + data_mux_b_alu) & 32'hfffffffe;
            default: ALU_OUT = 32'b0;
        endcase
    end
endmodule
