`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 11:49:39 AM
// Design Name: 
// Module Name: Branch_comp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// This module compares two 32-bit values based on the BrUn signal.
// If BrUn is 0, the comparison is signed.
// If BrUn is 1, the comparison is unsigned.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Branch_comp(
    input logic [31:0] data_R1,
    input logic [31:0] data_R2,
    input logic BrUn,
    output logic BrLT,
    output logic BrEQ
);
    always_comb
    begin
        if (!BrUn) begin
            // Signed comparison
            BrLT = ($signed(data_R1) < $signed(data_R2));
            BrEQ = ($signed(data_R1) == $signed(data_R2));
        end else begin
            // Unsigned comparison
            BrLT = (data_R1 < data_R2);
            BrEQ = (data_R1 == data_R2);
        end
    end
endmodule
