`timescale 1ns / 1ps
module reg_file(
    input logic cpu_clk,
    input logic RegWEn,
    input logic [4:0]rs1,
    input logic [4:0]rs2,
    input logic [4:0]rd,
    input logic [31:0]mux_out,
    output logic [31:0]data_R1,
    output logic [31:0]data_R2,
   output logic  [7:0]uart_reg
);

logic [31:0]reg_file[31:0];
assign  uart_reg=reg_file[5][7:0];

assign data_R2 = reg_file[rs2][31:0];
assign data_R1 = reg_file[rs1][31:0];
always @(posedge cpu_clk) begin
    if (RegWEn&&rd!=0) begin
        reg_file[rd] <= mux_out;
    end
end

initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
    if(i!=7)begin   reg_file[i] = 32'b0;end
       
    end
end
endmodule
