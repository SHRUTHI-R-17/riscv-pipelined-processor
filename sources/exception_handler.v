`timescale 1ns/1ps

module exception_handler (
    input        clk,
    input        rst,
    input [31:0] instruction,
    input [31:0] pc,
    input        mem_access_fault,
    output reg   exception_detected,
    output reg [31:0] exception_pc,
    output reg [3:0]  exception_code,
    output reg        pipeline_flush
);
    // Exception codes
    localparam EXC_NONE        = 4'd0;
    localparam EXC_ILLEGAL_INS = 4'd2;
    localparam EXC_MEM_FAULT   = 4'd5;
    localparam EXC_MISALIGN    = 4'd6;

    wire [6:0] opcode = instruction[6:0];
    wire is_illegal = (opcode != 7'b0110011) && // R-type
                      (opcode != 7'b0010011) && // I-type
                      (opcode != 7'b0000011) && // Load
                      (opcode != 7'b0100011) && // Store
                      (opcode != 7'b1100011) && // Branch
                      (opcode != 7'b1101111) && // JAL
                      (opcode != 7'b0110111) && // LUI
                      (opcode != 7'b0000000);   // NOP

    wire is_misaligned = (pc[1:0] != 2'b00);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            exception_detected <= 0;
            exception_pc       <= 0;
            exception_code     <= EXC_NONE;
            pipeline_flush     <= 0;
        end else begin
            pipeline_flush     <= 0;
            exception_detected <= 0;

            if (is_illegal && instruction != 32'h0) begin
                exception_detected <= 1;
                exception_pc       <= pc;
                exception_code     <= EXC_ILLEGAL_INS;
                pipeline_flush     <= 1;
                $display("EXCEPTION: Illegal instruction 0x%h at PC=%0d",
                          instruction, pc);
            end else if (mem_access_fault) begin
                exception_detected <= 1;
                exception_pc       <= pc;
                exception_code     <= EXC_MEM_FAULT;
                pipeline_flush     <= 1;
                $display("EXCEPTION: Memory fault at PC=%0d", pc);
            end else if (is_misaligned) begin
                exception_detected <= 1;
                exception_pc       <= pc;
                exception_code     <= EXC_MISALIGN;
                pipeline_flush     <= 1;
                $display("EXCEPTION: PC misaligned at PC=%0d", pc);
            end
        end
    end
endmodule