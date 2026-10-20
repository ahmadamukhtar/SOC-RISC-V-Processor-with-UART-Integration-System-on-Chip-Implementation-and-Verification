// Author: Ahmad Mukhtar
// Role: Holds the address of the current instruction and supplies instruction fetch.
// Inputs: reset asynchronously returns to 0x80000000; cpu_clk advances the state;
//         PCSel selects alu_out as a branch/jump target instead of sequential PC+4.
// Output: count is the current 32-bit instruction address.

`timescale 1ns / 1ps
module PC #(parameter width=32)(
    input logic reset,
    input logic cpu_clk,
    input logic PCSel,         // Select between sequential PC+4 and jump/branch address
    input logic [31:0] alu_out, // Address for jump instructions
    output logic [width-1:0] count=32'h80000000    // Program counter
);

always @(posedge cpu_clk or posedge reset) begin
    if (reset)
        count <= 32'h80000000;
    else if (PCSel)
        count <= alu_out;  // Set PC to jump address if PCSel is high
    else
        count <= count + 4;  // RV32I instructions are 32 bits (4 bytes) in this core.
end
endmodule
