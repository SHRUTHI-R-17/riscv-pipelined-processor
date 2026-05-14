`timescale 1ns/1ps

module ex_mem_reg (
    input         clk, rst,
    input  [31:0] alu_result_in, rd2_in, branch_target_in,
    input  [4:0]  rd_in,
    input         zero_in, mem_write_in, mem_read_in,
    input         mem_to_reg_in, branch_in, reg_write_in,
    output reg [31:0] alu_result_out, rd2_out, branch_target_out,
    output reg [4:0]  rd_out,
    output reg        zero_out, mem_write_out, mem_read_out,
    output reg        mem_to_reg_out, branch_out, reg_write_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 0; rd2_out <= 0; branch_target_out <= 0;
            rd_out <= 0; zero_out <= 0; mem_write_out <= 0;
            mem_read_out <= 0; mem_to_reg_out <= 0;
            branch_out <= 0; reg_write_out <= 0;
        end else begin
            alu_result_out <= alu_result_in; rd2_out <= rd2_in;
            branch_target_out <= branch_target_in; rd_out <= rd_in;
            zero_out <= zero_in; mem_write_out <= mem_write_in;
            mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
            branch_out <= branch_in; reg_write_out <= reg_write_in;
        end
    end
endmodule