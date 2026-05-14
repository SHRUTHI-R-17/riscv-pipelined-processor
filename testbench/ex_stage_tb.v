`timescale 1ns/1ps

module ex_stage_tb;
    reg  [31:0] rd1, rd2, imm_ext, pc_out;
    reg         alu_src;
    reg  [3:0]  alu_ctrl;
    wire [31:0] alu_result, branch_target;
    wire        zero;

    ex_stage uut (
        .rd1(rd1), .rd2(rd2),
        .imm_ext(imm_ext),
        .pc_out(pc_out),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .alu_result(alu_result),
        .zero(zero),
        .branch_target(branch_target)
    );

    initial begin
        // ADD: rd1 + rd2
        rd1=32'd10; rd2=32'd20; imm_ext=32'd5;
        pc_out=32'd100; alu_src=0; alu_ctrl=4'b0000;
        #10;
        $display("ADD: %0d + %0d = %0d (expect 30)", rd1, rd2, alu_result);

        // ADDI: rd1 + imm
        alu_src=1; alu_ctrl=4'b0000;
        #10;
        $display("ADDI: %0d + %0d = %0d (expect 15)", rd1, imm_ext, alu_result);

        // SUB: 10 - 10 = 0, zero flag
        rd1=32'd10; rd2=32'd10; alu_src=0; alu_ctrl=4'b0001;
        #10;
        $display("SUB: %0d - %0d = %0d, zero=%b (expect 0, zero=1)", rd1, rd2, alu_result, zero);

        // Branch target: pc + imm<<1
        imm_ext=32'd4; pc_out=32'd8;
        #10;
        $display("Branch target = %0d (expect 16)", branch_target);

        $display("EX Stage test PASSED!");
        $finish;
    end
endmodule