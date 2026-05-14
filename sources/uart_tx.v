`timescale 1ns/1ps

module uart_tx (
    input        clk,
    input        rst,
    input        send,
    input  [7:0] data_in,
    output reg   tx,
    output reg   busy,
    output reg   done
);
    // 115200 baud @ 100MHz clock
    // Clocks per bit = 100,000,000 / 115200 = 868
    parameter CLKS_PER_BIT = 868;

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;

    reg [2:0]  state;
    reg [9:0]  clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;
            busy      <= 0;
            done      <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 0;
                    if (send) begin
                        data_reg  <= data_in;
                        busy      <= 1;
                        state     <= START;
                        clk_count <= 0;
                    end
                end
                START: begin
                    tx <= 1'b0; // start bit
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state     <= DATA;
                    end
                end
                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end
                STOP: begin
                    tx <= 1'b1; // stop bit
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        done      <= 1;
                        busy      <= 0;
                        clk_count <= 0;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule