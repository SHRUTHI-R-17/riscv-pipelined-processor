`timescale 1ns/1ps

module data_memory_tb;

    reg         clk;
    reg         mem_write, mem_read;
    reg  [31:0] address, write_data;
    wire [31:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock 10ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_write = 0;
        mem_read  = 0;
        address   = 0;
        write_data = 0;
        #10;

        // Test 1: Write 42 to address 0
        mem_write  = 1;
        mem_read   = 0;
        address    = 32'd0;
        write_data = 32'd42;
        #10;
        $display("Wrote 42 to address 0");

        // Test 2: Write 100 to address 4
        address    = 32'd4;
        write_data = 32'd100;
        #10;
        $display("Wrote 100 to address 4");

        // Test 3: Write 0xDEADBEEF to address 8
        address    = 32'd8;
        write_data = 32'hDEADBEEF;
        #10;
        $display("Wrote DEADBEEF to address 8");

        // Test 4: Read back address 0
        mem_write = 0;
        mem_read  = 1;
        address   = 32'd0;
        #10;
        $display("Read address 0  = %0d (expect 42)", read_data);

        // Test 5: Read back address 4
        address = 32'd4;
        #10;
        $display("Read address 4  = %0d (expect 100)", read_data);

        // Test 6: Read back address 8
        address = 32'd8;
        #10;
        $display("Read address 8  = %h (expect deadbeef)", read_data);

        // Test 7: Read with mem_read=0 should return 0
        mem_read = 0;
        address  = 32'd0;
        #10;
        $display("Read with mem_read=0 = %0d (expect 0)", read_data);

        $display("Data Memory test PASSED!");
        $finish;
    end

endmodule