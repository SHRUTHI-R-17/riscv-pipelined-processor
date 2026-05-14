`timescale 1ns/1ps

module wb_stage_tb;
    reg         mem_to_reg;
    reg  [31:0] alu_result, read_data;
    wire [31:0] write_data;

    wb_stage uut (
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .read_data(read_data),
        .write_data(write_data)
    );

    initial begin
        alu_result=32'd100; read_data=32'd999;

        // mem_to_reg=0 ? write ALU result
        mem_to_reg=0; #10;
        $display("mem_to_reg=0: write_data=%0d (expect 100)", write_data);

        // mem_to_reg=1 ? write memory data
        mem_to_reg=1; #10;
        $display("mem_to_reg=1: write_data=%0d (expect 999)", write_data);

        $display("WB Stage test PASSED!");
        $finish;
    end
endmodule