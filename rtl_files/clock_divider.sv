module clock_divider(
    input logic clk_in,         // 100 MHz input clock
    input logic reset,          // Reset signal
    output logic clk_out=1'b1,       // 1 Hz output clock
    input logic [31:0]DIV_FACTOR
);

    // Parameter for the division factor
   // parameter DIV_FACTOR = 100_000_000;
    logic [31:0] counter;

    // Sequential block to divide the clock
    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 32'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == (DIV_FACTOR/2) - 1) begin
                clk_out <= ~clk_out;
                counter <= 32'b0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule