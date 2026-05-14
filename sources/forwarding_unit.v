`timescale 1ns/1ps

module forwarding_unit (
    input  [4:0] ex_rs1, ex_rs2,
    input  [4:0] mem_rd, wb_rd,
    input        mem_reg_write, wb_reg_write,
    output reg [1:0] forward_a, forward_b
);
    // forward_a/b:
    // 00 = use register file value (no forward)
    // 01 = forward from WB stage
    // 10 = forward from MEM stage

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // MEM forwarding (higher priority)
        if (mem_reg_write && mem_rd != 0 && mem_rd == ex_rs1)
            forward_a = 2'b10;
        if (mem_reg_write && mem_rd != 0 && mem_rd == ex_rs2)
            forward_b = 2'b10;

        // WB forwarding
        if (wb_reg_write && wb_rd != 0 && wb_rd == ex_rs1
            && !(mem_reg_write && mem_rd != 0 && mem_rd == ex_rs1))
            forward_a = 2'b01;
        if (wb_reg_write && wb_rd != 0 && wb_rd == ex_rs2
            && !(mem_reg_write && mem_rd != 0 && mem_rd == ex_rs2))
            forward_b = 2'b01;
    end
endmodule