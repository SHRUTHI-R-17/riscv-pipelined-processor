
module alu_tb;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        // ADD: 10 + 5 = 15
        a = 32'd10; b = 32'd5; alu_ctrl = 4'b0000;
        #10;
        $display("ADD: %0d + %0d = %0d", a, b, result);

        // SUB: 10 - 5 = 5
        a = 32'd10; b = 32'd5; alu_ctrl = 4'b0001;
        #10;
        $display("SUB: %0d - %0d = %0d", a, b, result);

        // AND
        a = 32'hF0; b = 32'h0F; alu_ctrl = 4'b0010;
        #10;
        $display("AND: %h & %h = %h", a, b, result);

        // OR
        a = 32'hF0; b = 32'h0F; alu_ctrl = 4'b0011;
        #10;
        $display("OR:  %h | %h = %h", a, b, result);

        // ZERO flag test
        a = 32'd5; b = 32'd5; alu_ctrl = 4'b0001;
        #10;
        $display("ZERO flag: %0d - %0d = %0d, zero=%b", a, b, result, zero);

        $finish;
    end

endmodule