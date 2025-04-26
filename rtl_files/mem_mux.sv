`timescale 1ns / 1ps
module mux_WB #(parameter width=32)(
    input logic [31:0]alu_out,
    input logic [31:0]dataR,
    input logic [width-1:0]count,
    input logic [1:0]WBSel,              // Write-back select signal (1 = data memory, 0 = ALU result)
    output logic [31:0]mux_out
);
   always_comb
   begin
    case(WBSel)
   2'b00: begin mux_out=dataR; end
   2'b01: begin mux_out=alu_out; end
   2'b10: begin   mux_out=count; end
    default: begin  end
    endcase
   end
endmodule
