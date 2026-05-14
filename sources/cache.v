`timescale 1ns/1ps

module cache #(
    parameter CACHE_SIZE = 16  // 16 cache lines
)(
    input         clk,
    input         rst,
    input         mem_read,
    input         mem_write,
    input  [31:0] address,
    input  [31:0] write_data,
    output reg [31:0] read_data,
    output reg    hit,
    output reg    miss,
    // Stats
    output reg [31:0] total_accesses,
    output reg [31:0] total_hits,
    output reg [31:0] total_misses,
    output reg [31:0] hit_rate_pct
);
    // Cache structure: valid bit + tag + data
    reg        valid [CACHE_SIZE-1:0];
    reg [27:0] tag   [CACHE_SIZE-1:0];
    reg [31:0] data  [CACHE_SIZE-1:0];

    wire [3:0]  index = address[5:2];  // 4-bit index
    wire [27:0] addr_tag = address[31:4]; // tag

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid[i] <= 0;
                tag[i]   <= 0;
                data[i]  <= 0;
            end
            total_accesses <= 0;
            total_hits     <= 0;
            total_misses   <= 0;
            hit_rate_pct   <= 0;
            hit  <= 0;
            miss <= 0;
        end else begin
            if (mem_read || mem_write) begin
                total_accesses <= total_accesses + 1;

                if (valid[index] && tag[index] == addr_tag) begin
                    // HIT
                    hit  <= 1;
                    miss <= 0;
                    total_hits <= total_hits + 1;

                    if (mem_read)
                        read_data <= data[index];
                    if (mem_write)
                        data[index] <= write_data;
                end else begin
                    // MISS — load from memory
                    hit  <= 0;
                    miss <= 1;
                    total_misses <= total_misses + 1;
                    valid[index] <= 1;
                    tag[index]   <= addr_tag;
                    data[index]  <= write_data;

                    if (mem_read)
                        read_data <= write_data; // simplified: direct load
                end

                // Hit rate = hits * 100 / total
                if (total_accesses > 0)
                    hit_rate_pct <= (total_hits * 100) / total_accesses;
            end
        end
    end
endmodule