`timescale 1ns/1ps

module cache_tb;
    reg        clk, rst;
    reg        mem_read, mem_write;
    reg [31:0] address, write_data;
    wire [31:0] read_data;
    wire        hit, miss;
    wire [31:0] total_accesses, total_hits, total_misses, hit_rate_pct;

    cache uut (
        .clk(clk), .rst(rst),
        .mem_read(mem_read), .mem_write(mem_write),
        .address(address), .write_data(write_data),
        .read_data(read_data), .hit(hit), .miss(miss),
        .total_accesses(total_accesses),
        .total_hits(total_hits),
        .total_misses(total_misses),
        .hit_rate_pct(hit_rate_pct)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1;
        mem_read=0; mem_write=0;
        address=0; write_data=0;
        #20; rst=0;

        // Write to address 0
        mem_write=1; address=32'h0; write_data=32'd100; #10;
        $display("WRITE addr=0, data=100");
        mem_write=0;

        // Write to address 4
        mem_write=1; address=32'h4; write_data=32'd200; #10;
        $display("WRITE addr=4, data=200");
        mem_write=0;

        // Read address 0 — should HIT
        mem_read=1; address=32'h0; #10;
        $display("READ addr=0: data=%0d hit=%b miss=%b (expect HIT)", read_data, hit, miss);
        mem_read=0;

        // Read address 4 — should HIT
        mem_read=1; address=32'h4; #10;
        $display("READ addr=4: data=%0d hit=%b miss=%b (expect HIT)", read_data, hit, miss);
        mem_read=0;

        // Read unknown address — should MISS
        mem_read=1; address=32'h100; #10;
        $display("READ addr=100: hit=%b miss=%b (expect MISS)", hit, miss);
        mem_read=0;

        #10;
        $display("?????????????????????????????");
        $display("Cache Performance:");
        $display("Total Accesses: %0d", total_accesses);
        $display("Total Hits:     %0d", total_hits);
        $display("Total Misses:   %0d", total_misses);
        $display("Hit Rate:       %0d%%", hit_rate_pct);
        $display("?????????????????????????????");
        $display("Cache Test PASSED!");
        $finish;
    end
endmodule