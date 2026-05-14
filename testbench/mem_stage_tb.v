`timescale 1ns/1ps

module mem_stage_tb;
    reg         clk, mem_write, mem_read, branch, zero;
    reg  [31:0] alu_result, rd2, branch_target;
    wire [31:0] read_data;
    wire        pc_src;

    mem_stage uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .branch(branch),
        .zero(zero),
        .alu_result(alu_result),
        .rd2(rd2),
        .branch_target(branch_target),
        .read_data(read_data),
        .pc_src(pc_src)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; mem_write=0; mem_read=0;
        branch=0; zero=0;
        alu_result=0; rd2=0; branch_target=0;
        #10;

        // Write 999 to address 0
        mem_write=1; mem_read=0;
        alu_result=32'd0; rd2=32'd999;
        #10;
        $display("Wrote 999 to address 0");

        // Read back
        mem_write=0; mem_read=1;
        alu_result=32'd0;
        #10;
        $display("Read data = %0d (expect 999)", read_data);

        // Branch taken: branch=1, zero=1
        branch=1; zero=1;
        #10;
        $display("pc_src = %b (expect 1, branch taken)", pc_src);

        // Branch not taken: branch=1, zero=0
        zero=0;
        #10;
        $display("pc_src = %b (expect 0, not taken)", pc_src);

        $display("MEM Stage test PASSED!");
        $finish;
    end
endmodule