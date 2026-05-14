`timescale 1ns/1ps

module multiplier (
    input         clk,
    input         rst,
    input         mul_en,
    input  [31:0] a,
    input  [31:0] b,
    input  [1:0]  mul_op,   // 00=MUL, 01=MULH, 10=MULHU, 11=MULHSU
    output reg [31:0] result,
    output reg    done
);
    reg [63:0] product;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            done   <= 0;
            product<= 0;
        end else if (mul_en) begin
            case (mul_op)
                2'b00: begin // MUL — lower 32 bits
                    product <= $signed(a) * $signed(b);
                    result  <= product[31:0];
                end
                2'b01: begin // MULH — upper 32 bits signed
                    product <= $signed(a) * $signed(b);
                    result  <= product[63:32];
                end
                2'b10: begin // MULHU — upper 32 bits unsigned
                    product <= a * b;
                    result  <= product[63:32];
                end
                2'b11: begin // MULHSU — signed * unsigned upper
                    product <= $signed(a) * b;
                    result  <= product[63:32];
                end
            endcase
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule