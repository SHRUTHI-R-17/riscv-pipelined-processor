`timescale 1ns/1ps

module if_id_reg (
    input         clk, rst,
    input         stall,
    input         flush,
    input  [31:0] pc_plus4_in,
    input  [31:0] instruction_in,
    input  [31:0] pc_in,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] instruction_out,
    output reg [31:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_plus4_out    <= 0;
            instruction_out <= 32'h00000013; // NOP
            pc_out          <= 0;
        end else if (!stall) begin
            pc_plus4_out    <= pc_plus4_in;
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
        end
    end
endmodule