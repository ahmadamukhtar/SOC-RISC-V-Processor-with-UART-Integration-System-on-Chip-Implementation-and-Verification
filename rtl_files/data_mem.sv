// Author: Ahmad Mukhtar
// Role: Supplies loads/stores for the CPU and implements the UART status memory-mapped input.
// Inputs: adr is a byte address, dataW is store data, MEMRW selects write/read, and func3 selects size/sign.
//         status is the UART ready bit; address 0x644 reads it as a 32-bit value.
// Output: dataR is the selected/sign- or zero-extended load value. RAM spans 401 words (0x000..0x643).
// Note: Store address 0x640 is ordinary RAM word 400 as well as the SoC UART transmit trigger address.

`timescale 1ns / 1ps
module data_mem #(
    parameter int WORDS = 401
)(
    input  logic        cpu_clk,
    input  logic [31:0] adr,
    input  logic [31:0] dataW,
    input  logic        MEMRW,
    input  logic [2:0]  func3,
    output logic [31:0] dataR,
    input  logic        status
);
    localparam logic [31:0] UART_DATA_ADDR   = 32'd1600;
    localparam logic [31:0] UART_STATUS_ADDR = 32'd1604;
    logic [31:0] memory_array [0:WORDS-1];
    integer i;

    // Combinational reads model the simple single-cycle core's data path.
    always_comb begin
        dataR = 32'b0;
        if (!MEMRW) begin
            if (adr == UART_STATUS_ADDR) begin
                dataR = {31'b0, status};
            end else if ((adr >> 2) < WORDS) begin
                case (func3)
                    3'b000: begin // LB: sign-extended byte.
                        case (adr[1:0])
                            2'd0: dataR = {{24{memory_array[adr >> 2][7]}}, memory_array[adr >> 2][7:0]};
                            2'd1: dataR = {{24{memory_array[adr >> 2][15]}}, memory_array[adr >> 2][15:8]};
                            2'd2: dataR = {{24{memory_array[adr >> 2][23]}}, memory_array[adr >> 2][23:16]};
                            default: dataR = {{24{memory_array[adr >> 2][31]}}, memory_array[adr >> 2][31:24]};
                        endcase
                    end
                    3'b001: dataR = adr[1] ? {{16{memory_array[adr >> 2][31]}}, memory_array[adr >> 2][31:16]}
                                             : {{16{memory_array[adr >> 2][15]}}, memory_array[adr >> 2][15:0]};
                    3'b010: dataR = memory_array[adr >> 2];
                    3'b100: begin // LBU: zero-extended byte.
                        case (adr[1:0])
                            2'd0: dataR = {24'b0, memory_array[adr >> 2][7:0]};
                            2'd1: dataR = {24'b0, memory_array[adr >> 2][15:8]};
                            2'd2: dataR = {24'b0, memory_array[adr >> 2][23:16]};
                            default: dataR = {24'b0, memory_array[adr >> 2][31:24]};
                        endcase
                    end
                    3'b101: dataR = adr[1] ? {16'b0, memory_array[adr >> 2][31:16]}
                                             : {16'b0, memory_array[adr >> 2][15:0]};
                    default: dataR = 32'b0;
                endcase
            end
        end
    end

    // Writes are ignored for the read-only UART status register.
    always_ff @(posedge cpu_clk) begin
        if (MEMRW && adr != UART_STATUS_ADDR && (adr >> 2) < WORDS) begin
            case (func3)
                3'b000: begin
                    case (adr[1:0])
                        2'd0: memory_array[adr >> 2][7:0]   <= dataW[7:0];
                        2'd1: memory_array[adr >> 2][15:8]  <= dataW[7:0];
                        2'd2: memory_array[adr >> 2][23:16] <= dataW[7:0];
                        default: memory_array[adr >> 2][31:24] <= dataW[7:0];
                    endcase
                end
                3'b001: begin
                    if (!adr[1]) memory_array[adr >> 2][15:0] <= dataW[15:0];
                    else        memory_array[adr >> 2][31:16] <= dataW[15:0];
                end
                3'b010: memory_array[adr >> 2] <= dataW;
                default: ;
            endcase
        end
    end

    initial begin
        for (i = 0; i < WORDS; i = i + 1) memory_array[i] = 32'b0;
    end
endmodule
