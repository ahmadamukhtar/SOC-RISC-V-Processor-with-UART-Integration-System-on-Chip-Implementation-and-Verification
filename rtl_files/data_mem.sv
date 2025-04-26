`timescale 1ns / 1ps
module data_mem (
    input cpu_clk,
    input logic [31:0] adr,       // Address from ALU (word-aligned)
    input logic [31:0]dataW,     // Data to be written (for store instructions)
    input logic MEMRW,            // Memory Read/Write control (1 = write, 0 = read)
    input logic [1:0] func3,      // To differentiate between byte/half-word/word access
    output logic [31:0] dataR,     // Data read for load instructions
    input logic status
);

    // Defining a simple memory array of 32-bit wide and 256 words deep (32KB)
    
    logic [31:0] memory_array [401:0];
    assign  memory_array [401][31:0]=status;
    // Memory read and write operation based on load/store size
    always_comb begin
        if (MEMRW == 1'b0) begin
            case (func3)
                2'b00: begin // Load Byte (LB)
                    case (adr[1:0])
                        2'b00: dataR = {24'b0, memory_array[adr[31:2]][7:0]};
                        2'b01: dataR = {24'b0, memory_array[adr[31:2]][15:8]};
                        2'b10: dataR = {24'b0, memory_array[adr[31:2]][23:16]};
                        2'b11: dataR = {24'b0, memory_array[adr[31:2]][31:24]};
                    endcase
                end
                2'b01: begin // Load Halfword (LH)
                    if (adr[1] == 1'b0)
                        dataR = {16'b0, memory_array[adr[31:2]][15:0]}; // Lower halfword
                    else
                        dataR = {16'b0, memory_array[adr[31:2]][31:16]}; // Upper halfword
                end
                2'b10: begin // Load Word (LW)
                    dataR = memory_array[adr[31:2]]; // Word-aligned access
                end
                default: dataR = 32'b0; // Default to zero if unhandled case
            endcase
        end
    end

    // Memory write operation for store instructions
    always_ff @(posedge cpu_clk) begin
        if (MEMRW == 1'b1) begin
            case (func3)
                2'b00: begin // Store Byte (SB)
                    case (adr[1:0])
                        2'b00: memory_array[adr[31:2]][7:0] <= dataW[7:0];    // Store lower byte
                        2'b01: memory_array[adr[31:2]][15:8] <= dataW[7:0];   // Store second byte
                        2'b10: memory_array[adr[31:2]][23:16] <= dataW[7:0];  // Store third byte
                        2'b11: memory_array[adr[31:2]][31:24] <= dataW[7:0];  // Store upper byte
                    endcase
                end
                2'b01: begin // Store Halfword (SH)
                    if (adr[1] == 1'b0)
                        memory_array[adr[31:2]][15:0] <= dataW[15:0]; // Store lower halfword
                    else
                        memory_array[adr[31:2]][31:16] <= dataW[15:0]; // Store upper halfword
                end
                2'b10: begin // Store Word (SW)
                    memory_array[adr[31:2]] <= dataW; // Store full word
                end
            endcase
        end
    end
    // Initialize memory to zeros
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            memory_array[i] = 32'b0;  // Set all memory locations to zero
        end
    end
endmodule
