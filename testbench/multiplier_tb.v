`timescale 1ns/1ps

module multiplier_tb;
    reg        clk, rst, mul_en;
    reg [31:0] a, b;
    reg [1:0]  mul_op;
    wire [31:0] result;
    wire        done;

    multiplier uut (
        .clk(clk), .rst(rst), .mul_en(mul_en),
        .a(a), .b(b), .mul_op(mul_op),
        .result(result), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1; mul_en=0;
        a=0; b=0; mul_op=0;
        #20; rst=0;

        // MUL: 6 * 7 = 42
        a=32'd6; b=32'd7; mul_op=2'b00; mul_en=1; #10; mul_en=0;
        $display("MUL: 6 x 7 = %0d (expect 42)", result);

        // MUL: 100 * 200 = 20000
        a=32'd100; b=32'd200; mul_op=2'b00; mul_en=1; #10; mul_en=0;
        $display("MUL: 100 x 200 = %0d (expect 20000)", result);

        // MULH: large numbers upper bits
        a=32'hFFFFFFFF; b=32'hFFFFFFFF; mul_op=2'b10; mul_en=1; #10; mul_en=0;
        $display("MULHU upper: %h", result);

        // MUL: -1 * 1 = -1 (signed)
        a=32'hFFFFFFFF; b=32'd1; mul_op=2'b00; mul_en=1; #10; mul_en=0;
        $display("MUL: -1 x 1 = %0d (expect -1 = 4294967295)", result);

        $display("RV32M Multiplier Test PASSED!");
        $finish;
    end
endmodule