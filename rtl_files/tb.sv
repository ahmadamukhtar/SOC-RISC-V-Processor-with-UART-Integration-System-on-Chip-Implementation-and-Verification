// Author: Ahmad Mukhtar
// Role: Isolated unit-level testbench for transmitter_controller, separate from the CPU/SoC test.
// Test flow: Reset the UART, pulse Load with 0xA5, sample start/data[7:0]/stop in current RTL order, then check ready.
// Inputs: Locally generated clock/reset, baud select, load pulse, and test byte; output checked: ser_out/status.

`timescale 1ns / 1ps
module tb_transmitter_controller;
    logic clk_in = 1'b0;
    logic reset = 1'b1;
    logic [1:0] S = 2'b00;
    logic Load = 1'b0;
    logic [7:0] data_board = 8'hA5;
    logic ser_out, check, status;

    transmitter_controller uut (
        .clk_in(clk_in), .reset(reset), .S(S), .Load(Load),
        .data_board(data_board), .ser_out(ser_out),
        .check(check), .status(status)
    );

    always #5 clk_in = ~clk_in;

    initial begin
        repeat (2) @(posedge clk_in);
        reset = 1'b0;
        @(negedge clk_in);
        Load = 1'b1;
        @(negedge clk_in);
        Load = 1'b0;

        // This test currently checks the RTL's bit-7-to-bit-0 data order.
        @(posedge clk_in); if (ser_out !== 1'b0) $fatal(1, "UART start bit failed");
        @(posedge clk_in); if (ser_out !== data_board[7]) $fatal(1, "UART bit 7 failed");
        @(posedge clk_in); if (ser_out !== data_board[6]) $fatal(1, "UART bit 6 failed");
        @(posedge clk_in); if (ser_out !== data_board[5]) $fatal(1, "UART bit 5 failed");
        @(posedge clk_in); if (ser_out !== data_board[4]) $fatal(1, "UART bit 4 failed");
        @(posedge clk_in); if (ser_out !== data_board[3]) $fatal(1, "UART bit 3 failed");
        @(posedge clk_in); if (ser_out !== data_board[2]) $fatal(1, "UART bit 2 failed");
        @(posedge clk_in); if (ser_out !== data_board[1]) $fatal(1, "UART bit 1 failed");
        @(posedge clk_in); if (ser_out !== data_board[0]) $fatal(1, "UART bit 0 failed");
        @(posedge clk_in); if (ser_out !== 1'b1) $fatal(1, "UART stop bit failed");
        @(posedge clk_in);
        if (status !== 1'b1) $fatal(1, "UART did not return to idle");
        $display("PASS: UART 8N1 frame");
        $finish;
    end
endmodule
