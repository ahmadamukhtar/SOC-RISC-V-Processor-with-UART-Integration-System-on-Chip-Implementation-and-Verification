`timescale 1ns / 1ps
module PC #(parameter width=32)(
    input logic reset,
    input logic cpu_clk,
    input logic PCSel,         // Select between PC + 1 and jump address
    input logic [31:0] alu_out, // Address for jump instructions
    output logic [width-1:0] count=32'h80000000    // Program counter
);

always @(posedge cpu_clk or posedge reset) begin
    if (reset)
        count <= 32'h80000000;
    else if (PCSel)
        count <= alu_out;  // Set PC to jump address if PCSel is high
    else
        count <= count + 4;  // Default: increment PC by 1
end
endmodule
