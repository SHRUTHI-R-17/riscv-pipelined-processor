`timescale 1ns/1ps

module performance_counter (
    input        clk, rst,
    input        stall,
    input        branch_taken,
    input        mem_read, mem_write,
    input [31:0] instruction,
    output reg [31:0] total_cycles,
    output reg [31:0] total_instructions,
    output reg [31:0] stall_cycles,
    output reg [31:0] branch_count,
    output reg [31:0] mem_access_count,
    output reg [31:0] cpi_x100  // CPI * 100 (fixed point)
);
    wire is_nop = (instruction == 32'h00000013);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            total_cycles      <= 0;
            total_instructions<= 0;
            stall_cycles      <= 0;
            branch_count      <= 0;
            mem_access_count  <= 0;
            cpi_x100          <= 0;
        end else begin
            total_cycles <= total_cycles + 1;

            if (!stall && !is_nop)
                total_instructions <= total_instructions + 1;

            if (stall)
                stall_cycles <= stall_cycles + 1;

            if (branch_taken)
                branch_count <= branch_count + 1;

            if (mem_read || mem_write)
                mem_access_count <= mem_access_count + 1;

            // CPI = total_cycles / total_instructions * 100
            if (total_instructions > 0)
                cpi_x100 <= (total_cycles * 100) / total_instructions;
        end
    end
endmodule