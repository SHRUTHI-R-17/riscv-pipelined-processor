`timescale 1ns/1ps

module instruction_memory_tb;

    reg  [31:0] pc;
    wire [31:0] instr;

    instruction_memory uut (
        .pc(pc),
        .instr(instr)
    );

    initial begin
        // Read instruction at address 0
        pc = 32'd0; #10;
        $display("PC=0:  instr = %h (expect 00000093)", instr);

        // Read instruction at address 4
        pc = 32'd4; #10;
        $display("PC=4:  instr = %h (expect 00100113)", instr);

        // Read instruction at address 8
        pc = 32'd8; #10;
        $display("PC=8:  instr = %h (expect 00208133)", instr);

        // Read instruction at address 12
        pc = 32'd12; #10;
        $display("PC=12: instr = %h (expect 402081b3)", instr);

        // Read instruction at address 16
        pc = 32'd16; #10;
        $display("PC=16: instr = %h (expect 0020a233)", instr);

        $display("Instruction Memory test PASSED!");
        $finish;
    end

endmodule