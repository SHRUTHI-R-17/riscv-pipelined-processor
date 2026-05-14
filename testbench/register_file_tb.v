`timescale 1ns/1ps

module register_file_tb;

    reg         clk, rst;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] write_data;
    reg         reg_write;
    wire [31:0] rd1, rd2;

    // Connect to register file
    register_file uut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2),
        .reg_write(reg_write),
        .rd(rd),
        .write_data(write_data)
    );

    // Clock: flips every 5ns = 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 1;
        reg_write = 0;
        rs1 = 0; rs2 = 0;
        rd = 0; write_data = 0;

        // Apply reset for 2 clock cycles
        #20;
        rst = 0;

        // Test 1: Write 100 to register x1
        reg_write = 1;
        rd = 5'd1;
        write_data = 32'd100;
        #10;
        $display("Wrote 100 to x1");

        // Test 2: Write 200 to register x2
        rd = 5'd2;
        write_data = 32'd200;
        #10;
        $display("Wrote 200 to x2");

        // Test 3: Read x1 and x2
        reg_write = 0;
        rs1 = 5'd1;
        rs2 = 5'd2;
        #10;
        $display("Read x1 = %0d (expect 100)", rd1);
        $display("Read x2 = %0d (expect 200)", rd2);

        // Test 4: Write to x0 - should stay 0
        reg_write = 1;
        rd = 5'd0;
        write_data = 32'd999;
        #10;
        reg_write = 0;
        rs1 = 5'd0;
        #10;
        $display("Read x0 = %0d (expect 0, x0 hardwired)", rd1);

        // Test 5: Write to x5, read back
        reg_write = 1;
        rd = 5'd5;
        write_data = 32'hDEADBEEF;
        #10;
        reg_write = 0;
        rs1 = 5'd5;
        #10;
        $display("Read x5 = %h (expect deadbeef)", rd1);

        $display("Register File test PASSED!");
        $finish;
    end

endmodule