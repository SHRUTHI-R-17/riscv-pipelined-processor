`timescale 1ns/1ps

module id_ex_reg (
    input         clk, rst,
    input         flush,
    input  [31:0] pc_in, rd1_in, rd2_in, imm_in,
    input  [4:0]  rs1_in, rs2_in, rd_in,
    input  [3:0]  alu_ctrl_in,
    input         alu_src_in, mem_write_in, mem_read_in,
    input         mem_to_reg_in, branch_in, reg_write_in,
    output reg [31:0] pc_out, rd1_out, rd2_out, imm_out,
    output reg [4:0]  rs1_out, rs2_out, rd_out,
    output reg [3:0]  alu_ctrl_out,
    output reg        alu_src_out, mem_write_out, mem_read_out,
    output reg        mem_to_reg_out, branch_out, reg_write_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_out <= 0; rd1_out <= 0; rd2_out <= 0; imm_out <= 0;
            rs1_out <= 0; rs2_out <= 0; rd_out <= 0;
            alu_ctrl_out <= 0; alu_src_out <= 0;
            mem_write_out <= 0; mem_read_out <= 0;
            mem_to_reg_out <= 0; branch_out <= 0; reg_write_out <= 0;
        end else begin
            pc_out <= pc_in; rd1_out <= rd1_in; rd2_out <= rd2_in;
            imm_out <= imm_in; rs1_out <= rs1_in; rs2_out <= rs2_in;
            rd_out <= rd_in; alu_ctrl_out <= alu_ctrl_in;
            alu_src_out <= alu_src_in; mem_write_out <= mem_write_in;
            mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
            branch_out <= branch_in; reg_write_out <= reg_write_in;
        end
    end
endmodule