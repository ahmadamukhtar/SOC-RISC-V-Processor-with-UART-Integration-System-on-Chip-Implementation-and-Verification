//`timescale 1ns / 1ps
//module instruction_memory #(
//    parameter width =32,
//    parameter depth =300
//)(
//    input logic [width-1:0]count,
//    output logic [4:0] rs1,
//    output logic [4:0] rs2,
//    output logic [4:0] rd,
//    output logic [6:0] opcode,
//    output logic [2:0] func_3,
//    output logic func_7_sig,
//    output logic [6:0] func_7
//);
//    logic [31:0]inst[depth-1:0];
//    initial
//     begin
//        $readmemh("memory_data.mem",inst); 
//    end    
//    assign rs1 = inst[count[width-1:2]-32'h20000000][19:15];
//    assign rs2 = inst[count[width-1:2]-32'h20000000][24:20];
//    assign rd = inst[count[width-1:2]-32'h20000000][11:7];
//    assign opcode = inst[count[width-1:2]-32'h20000000][6:0];
//    assign func_7_sig = inst[count[width-1:2]-32'h20000000][30];
//    assign func_7 = inst[count[width-1:2]-32'h20000000][31:25];
//    assign func_3 = inst[count[width-1:2]-32'h20000000][14:12];
//endmodule
`timescale 1ns / 1ps
module instruction_memory #(
    parameter width =32,
    parameter depth =30
)(
    input logic [width-1:0]count,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [6:0] opcode,
    output logic [2:0] func_3,
    output logic func_7_sig,
    output logic [6:0] func_7
);
    logic [31:0]inst[0:depth-1];
    initial
     begin
        $readmemh("data.mem",inst); 
    end    
    assign rs1 = inst[count[width-1:2]-32'h20000000][19:15];
    assign rs2 = inst[count[width-1:2]-32'h20000000][24:20];
    assign rd = inst[count[width-1:2]-32'h20000000][11:7];
    assign opcode = inst[count[width-1:2]-32'h20000000][6:0];
    assign func_7_sig = inst[count[width-1:2]-32'h20000000][30];
    assign func_7 = inst[count[width-1:2]-32'h20000000][31:25];
    assign func_3 = inst[count[width-1:2]-32'h20000000][14:12];
endmodule
