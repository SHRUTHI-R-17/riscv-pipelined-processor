`timescale 1ns/1ps

module mem_stage (
    input         clk,
    input         mem_write,
    input         mem_read,
    input         branch,
    input         zero,
    input  [31:0] alu_result,
    input  [31:0] rd2,
    input  [31:0] branch_target,
    output [31:0] read_data,
    output        pc_src
);
    assign pc_src = branch & zero;

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_result),
        .write_data(rd2),
        .read_data(read_data)
    );
endmodule