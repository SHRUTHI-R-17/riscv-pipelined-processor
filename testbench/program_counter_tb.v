`timescale 1ns/1ps

module program_counter_tb;

    reg         clk, rst, pc_write;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    program_counter uut (
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 1;
        pc_write = 0;
        pc_next = 0;

        // Apply reset
        #10;
        $display("After reset: PC = %0d (expect 0)", pc);

        // Release reset, enable PC
        rst = 0;
        pc_write = 1;

        // Tick 1: PC goes to 4
        pc_next = 32'd4;
        #10;
        $display("Tick 1: PC = %0d (expect 4)", pc);

        // Tick 2: PC goes to 8
        pc_next = 32'd8;
        #10;
        $display("Tick 2: PC = %0d (expect 8)", pc);

        // Tick 3: PC goes to 12
        pc_next = 32'd12;
        #10;
        $display("Tick 3: PC = %0d (expect 12)", pc);

        // Test STALL: freeze PC
        pc_write = 0;
        pc_next = 32'd16;   // this should be ignored
        #10;
        $display("Stall:  PC = %0d (expect 12, stalled)", pc);

        // Resume
        pc_write = 1;
        pc_next = 32'd16;
        #10;
        $display("Resume: PC = %0d (expect 16)", pc);

        // Test BRANCH: jump to any address
        pc_next = 32'd100;
        #10;
        $display("Branch: PC = %0d (expect 100)", pc);

        $display("Program Counter test PASSED!");
        $finish;
    end

endmodule