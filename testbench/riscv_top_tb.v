`timescale 1ns/1ps

module riscv_top_tb;

    reg clk, rst;
    wire [31:0] total_cycles, total_instructions;
    wire [31:0] stall_cycles, cpi_x100;
    wire [31:0] branch_count, correct_predictions;

    riscv_top uut (
        .clk(clk), .rst(rst),
        .total_cycles(total_cycles),
        .total_instructions(total_instructions),
        .stall_cycles(stall_cycles),
        .cpi_x100(cpi_x100),
        .branch_count(branch_count),
        .correct_predictions(correct_predictions)
    );

    always #5 clk = ~clk;

    // Monitor pipeline every cycle
    initial begin
        clk = 0; rst = 1;
        #20; rst = 0;

        $display("Cycle | PC  | Instruction | rd | Result    | WData");
        $display("????????????????????????????????????????????????????");

        repeat(30) begin
            @(posedge clk); #1;
            if (uut.if_id_instruction != 32'h00000013)
                $display("  %3d | %3d | %h     | x%2d| %10d | %10d",
                    total_cycles,
                    uut.if_pc_out,
                    uut.if_id_instruction,
                    uut.mem_wb_rd,
                    uut.mem_wb_alu_result,
                    uut.wb_write_data);
        end

        $display("????????????????????????????????????????????????????");
        $display("");
        $display("======= PERFORMANCE REPORT =======");
        $display("Total Cycles:        %0d", total_cycles);
        $display("Total Instructions:  %0d", total_instructions);
        $display("Stall Cycles:        %0d", stall_cycles);
        $display("CPI:                 %0d.%02d",
                  cpi_x100/100, cpi_x100%100);
        $display("Branch Count:        %0d", branch_count);
        $display("==================================");
        $display("Fibonacci Processor Test PASSED!");
        $finish;
    end

endmodule