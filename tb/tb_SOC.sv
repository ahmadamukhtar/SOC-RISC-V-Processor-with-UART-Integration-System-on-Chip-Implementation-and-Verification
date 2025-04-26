`timescale 1ns / 1ps

module SOC_riscv_uart_tb;

  
    reg clk;       // System clock
    reg reset;     // System reset
    wire ser_out;  // UART serial output

    
    SOC_riscv_uart dut (
        .clk(clk),
        .reset(reset),
        .ser_out(ser_out)
    );

  
    always #5 clk = ~clk; 


    initial begin

        clk = 0;
        reset = 1;

        #15;
        reset = 0;

   
        #20;



        #1000;
        $stop;
    end

endmodule
