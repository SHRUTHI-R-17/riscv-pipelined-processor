`timescale 1ns/1ps

module instruction_memory (
    input  [31:0] pc,
    output [31:0] instr
);

    reg [31:0] mem [63:0];

    initial begin
        $readmemh("instructions.mem", mem);
    end

    assign instr = mem[pc >> 2];

endmodule