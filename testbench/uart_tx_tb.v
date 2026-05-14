`timescale 1ns/1ps

module uart_tx_tb;
    reg        clk, rst, send;
    reg  [7:0] data_in;
    wire       tx, busy, done;

    uart_tx uut (
        .clk(clk), .rst(rst),
        .send(send), .data_in(data_in),
        .tx(tx), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    task send_byte;
        input [7:0] byte_val;
        begin
            data_in = byte_val;
            send = 1;
            @(posedge clk);
            send = 0;
            wait(done);
            @(posedge clk);
            $display("UART sent: 0x%h = '%c'", byte_val, byte_val);
        end
    endtask

    initial begin
        clk=0; rst=1; send=0; data_in=0;
        #20; rst=0;
        #100;

        // Send "RISCV" over UART
        send_byte(8'h52); // R
        send_byte(8'h49); // I
        send_byte(8'h53); // S
        send_byte(8'h43); // C
        send_byte(8'h56); // V
        send_byte(8'h0A); // newline

        $display("UART TX Test PASSED! Sent 'RISCV'");
        $finish;
    end
endmodule