// Author: Ahmad Mukhtar
// Role: Generates a square-wave clock by toggling after half of DIV_FACTOR input cycles.
// Inputs: clk_in is the source clock, reset clears the divider state, DIV_FACTOR sets the period.
// Output: clk_out toggles at the divided frequency; with a 100 MHz source, period is DIV_FACTOR cycles.

module clock_divider(
    input logic clk_in,
    input logic reset,
    output logic clk_out = 1'b1,
    input logic [31:0] DIV_FACTOR
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
