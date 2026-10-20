// Author: Ahmad Mukhtar
// Role: Stores architectural integer registers and supplies the CPU's two source operands.
// Inputs: rs1/rs2 select combinational reads; RegWEn/rd/mux_out control the clocked write; reset clears registers.
// Outputs: data_R1/data_R2 are source values; uart_reg exposes x6[7:0] to the SoC UART wrapper.
// Invariant: Reads of x0 always return zero and writes to x0 are ignored.

`timescale 1ns / 1ps
module reg_file(
    input  logic       cpu_clk,
    input  logic       reset,
    input  logic       RegWEn,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    input  logic [31:0] mux_out,
    output logic [31:0] data_R1,
    output logic [31:0] data_R2,
    output logic [7:0] uart_reg
);
    logic [31:0] registers [0:31];
    integer i;

    assign data_R1 = (rs1 == 0) ? 32'b0 : registers[rs1];
    assign data_R2 = (rs2 == 0) ? 32'b0 : registers[rs2];
    assign uart_reg = registers[6][7:0]; // x6 is the UART transmit data register.

    always_ff @(posedge cpu_clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
        end else if (RegWEn && (rd != 0)) begin
            registers[rd] <= mux_out;
        end
    end
endmodule
