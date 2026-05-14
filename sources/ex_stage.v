`timescale 1ns/1ps

module ex_stage (
    input  [31:0] rd1,
    input  [31:0] rd2,
    input  [31:0] imm_ext,
    input  [31:0] pc_out,
    input         alu_src,
    input  [3:0]  alu_ctrl,
    output [31:0] alu_result,
    output        zero,
    output [31:0] branch_target
);
    wire [31:0] alu_b;
    assign alu_b = (alu_src) ? imm_ext : rd2;
    assign branch_target = pc_out + (imm_ext << 1);

    alu alu_unit (
        .a(rd1),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );
endmodule