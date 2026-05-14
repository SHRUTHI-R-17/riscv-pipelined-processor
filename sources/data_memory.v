`timescale 1ns/1ps

module data_memory (
    input         clk,
    input         mem_write,  // 1 = write to memory
    input         mem_read,   // 1 = read from memory
    input  [31:0] address,    // memory address
    input  [31:0] write_data, // data to write
    output [31:0] read_data   // data read out
);

    // 64 words of 32-bit data memory
    reg [31:0] mem [63:0];

    integer i;

    // Initialize memory to 0
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
    end

    // Write on rising clock edge
    always @(posedge clk) begin
        if (mem_write)
            mem[address >> 2] <= write_data;
    end

    // Read - combinational
    assign read_data = (mem_read) ? mem[address >> 2] : 32'b0;

endmodule