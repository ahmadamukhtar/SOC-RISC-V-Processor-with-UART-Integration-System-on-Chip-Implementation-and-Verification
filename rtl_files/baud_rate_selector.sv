`timescale 1ns / 1ps
module baud_rate_selector(
    input logic clk_in,
    input logic reset,
    input logic [1:0] S,
    output logic clk_out
);

    logic clk_out_1, clk_out_2, clk_out_3;

   //  clock_divider m_1(.clk_in(clk_in), .reset(reset), .clk_out(clk_out_0), .DIV_FACTOR(000_000_001));  //only for simulation
   // clock_divider m_1(.clk_in(clk_in), .reset(reset), .clk_out(clk_out_0), .DIV_FACTOR(000_010_417));  //9600
    clock_divider m_2(.clk_in(clk_in), .reset(reset), .clk_out(clk_out_1), .DIV_FACTOR(000_020_833));  //4800
    clock_divider m_3(.clk_in(clk_in), .reset(reset), .clk_out(clk_out_2), .DIV_FACTOR(000_000_868));  //115200 
    clock_divider m_4(.clk_in(clk_in), .reset(reset), .clk_out(clk_out_3), .DIV_FACTOR(100_000_000));
   logic clk_out_0;
   assign clk_out_0=clk_in;
//    always_comb begin
//        case (S)
//            2'b00: clk_out = clk_out_0;
//            2'b01: clk_out = clk_out_1;
//            2'b10: clk_out = clk_out_2;
//            2'b11: clk_out = clk_out_3;
//            default: clk_out = clk_out_3; 
//        endcase
//    end
 //always_ff @(posedge clk_in)
 always_comb
 begin
        case (S)
            2'b00: clk_out = clk_out_0;
            2'b01: clk_out = clk_out_1;
            2'b10: clk_out = clk_out_2;
            2'b11: clk_out = clk_out_3;
            default: clk_out = clk_in; 
        endcase
    end
endmodule
