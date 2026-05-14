`timescale 1ns/1ps

module if_stage (
    input         clk,
    input         rst,
    input         pc_write,
    input  [31:0] pc_next,
    input         pc_src,
    output [31:0] pc_out,
    output [31:0] pc_plus4,
    output [31:0] instruction
);
    wire [31:0] pc_in;
    assign pc_plus4 = pc_out + 4;
    assign pc_in    = (pc_src) ? pc_next : pc_plus4;

    program_counter pc_reg (
        .clk(clk), .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_in),
        .pc(pc_out)
    );

    instruction_memory imem (
        .pc(pc_out),
        .instr(instruction)
    );
endmodule