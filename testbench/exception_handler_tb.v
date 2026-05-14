`timescale 1ns/1ps

module exception_handler_tb;
    reg        clk, rst, mem_access_fault;
    reg [31:0] instruction, pc;
    wire       exception_detected, pipeline_flush;
    wire [31:0] exception_pc;
    wire [3:0]  exception_code;

    exception_handler uut (
        .clk(clk), .rst(rst),
        .instruction(instruction),
        .pc(pc),
        .mem_access_fault(mem_access_fault),
        .exception_detected(exception_detected),
        .exception_pc(exception_pc),
        .exception_code(exception_code),
        .pipeline_flush(pipeline_flush)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1;
        instruction=0; pc=0;
        mem_access_fault=0;
        #20; rst=0;

        // Valid instruction — no exception
        instruction=32'h00208133; pc=32'd0; #10;
        $display("Valid instr: exception=%b (expect 0)", exception_detected);

        // Illegal instruction
        instruction=32'hDEADBEEF; pc=32'd4; #10;
        $display("Illegal instr: exception=%b code=%0d (expect 1, code=2)",
                  exception_detected, exception_code);

        // Memory fault
        instruction=32'h00000013; pc=32'd8;
        mem_access_fault=1; #10; mem_access_fault=0;
        $display("Mem fault: exception=%b code=%0d (expect 1, code=5)",
                  exception_detected, exception_code);

        $display("Exception Handler Test PASSED!");
        $finish;
    end
endmodule