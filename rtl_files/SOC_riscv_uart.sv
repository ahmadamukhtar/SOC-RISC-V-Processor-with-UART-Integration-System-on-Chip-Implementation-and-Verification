// Author: Ahmad Mukhtar
// Role: Top-level SoC wrapper connecting the CPU, UART transmitter, and memory-mapped handshake.
// Inputs: clk clocks the processor and UART; reset initializes the CPU, UART, and transmit request.
// Output: ser_out is the UART TX serial line (idle high, 8 data bits, one start and one stop bit).
// Integration: A decoded store with effective address 0x640 captures x6[7:0] for UART;
//              reads at 0x644 expose ready/busy status.

`timescale 1ns / 1ps
module SOC_riscv_uart(
    input logic clk,      // System clock
    input logic reset,    // System reset
    output logic ser_out  // UART serial output
);
    // Internal signals
    logic [31:0] ALU_OUT_check;
    logic [7:0] uart_reg;
    logic load_signal;
    logic [7:0] uart_data;
    logic [1:0] baud_rate_sel = 2'b00; //Adjust based on desired baud rate
    logic check_signal;
    logic status;
logic signal;
    // Instantiate the RISC-V processor
    RISC_V_Base_data_path processor_inst (
        .cpu_clk(clk),
        .reset(reset),
        .ALU_OUT_check(ALU_OUT_check),
        .uart_reg(uart_reg),.status(status),.signal(signal)
    );

    // Instantiate the UART transmitter
    transmitter_controller uart_tx (
        .clk_in(clk),
        .reset(reset),
        .S(baud_rate_sel),
        .Load(load_signal),
        .data_board(uart_data),
        .ser_out(ser_out),
        .check(check_signal),.status(status)
    );

    // Control logic to trigger UART transmission
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            load_signal <= 1'b0;
            uart_data <= 8'b0;
        end else begin
            if (ALU_OUT_check == 32'd1600&&signal) begin
                load_signal <= 1'b1;
                uart_data <= uart_reg; // Transmit lower 8 bits of data_R1
            end else begin
                load_signal <= 1'b0;
            end
        end
    end

endmodule
