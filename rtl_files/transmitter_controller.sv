// Author: Ahmad Mukhtar
// Role: Converts one parallel byte into an asynchronous serial UART frame.
// Inputs: clk_in/reset drive the baud selector; S chooses its rate; Load requests a byte on data_board.
// Outputs: ser_out idles high and emits start/data/stop bits; status is high in IDLE (ready), low while busy.
//          check is a diagnostic toggle that changes on each active UART-clock edge.
// Timing: The FSM advances once per rising edge of clk_out; current RTL emits data_reg[7] down to data_reg[0].

`timescale 1ns / 1ps
module transmitter_controller(
    input  logic       clk_in,
    input  logic       reset,
    input  logic [1:0] S,
    input  logic       Load,
    input  logic [7:0] data_board,
    output logic       ser_out,
    output logic       check,
    output logic       status
);
    typedef enum logic [3:0] {IDLE, START, DATA7, DATA6, DATA5, DATA4,
                              DATA3, DATA2, DATA1, DATA0, STOP} state_t;
    state_t state;
    logic [7:0] data_reg;
    logic clk_out;

    baud_rate_selector baud_selector (
        .clk_in(clk_in), .reset(reset), .S(S), .clk_out(clk_out)
    );

    // UART output is idle-high, followed by one start bit, eight data bits
    // in the current controller order (bit 7 down to bit 0), and one stop bit.
    always_comb begin
        status = (state == IDLE);
        case (state)
            IDLE, STOP: ser_out = 1'b1;
            START:     ser_out = 1'b0;
            DATA7:     ser_out = data_reg[7];
            DATA6:     ser_out = data_reg[6];
            DATA5:     ser_out = data_reg[5];
            DATA4:     ser_out = data_reg[4];
            DATA3:     ser_out = data_reg[3];
            DATA2:     ser_out = data_reg[2];
            DATA1:     ser_out = data_reg[1];
            DATA0:     ser_out = data_reg[0];
            default:   ser_out = 1'b1;
        endcase
    end

    always_ff @(posedge clk_out or posedge reset) begin
        if (reset) begin
            state    <= IDLE;
            data_reg <= 8'b0;
            check    <= 1'b0;
        end else begin
            check <= ~check;
            case (state)
                IDLE:  if (Load) begin data_reg <= data_board; state <= START; end
                START: state <= DATA7;
                DATA7: state <= DATA6;
                DATA6: state <= DATA5;
                DATA5: state <= DATA4;
                DATA4: state <= DATA3;
                DATA3: state <= DATA2;
                DATA2: state <= DATA1;
                DATA1: state <= DATA0;
                DATA0: state <= STOP;
                STOP:  state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end
endmodule
