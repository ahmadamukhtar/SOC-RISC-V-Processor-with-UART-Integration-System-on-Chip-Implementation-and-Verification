// Author: Ahmad Mukhtar
// Role: Provides comparison results used by the control unit to decide conditional branches.
// Inputs: data_R1/data_R2 are rs1/rs2 values; BrUn selects unsigned (1) or signed (0) ordering.
// Outputs: BrLT reports less-than and BrEQ reports equality for the selected interpretation.

`timescale 1ns / 1ps
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
