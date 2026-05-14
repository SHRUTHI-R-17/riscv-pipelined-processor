`timescale 1ns/1ps

module program_counter (
    input         clk,
    input         rst,
    input         pc_write,   // 1 = update PC, 0 = stall (freeze)
    input  [31:0] pc_next,    // next PC value to load
    output reg [31:0] pc      // current PC value
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;       // reset to address 0
        else if (pc_write)
            pc <= pc_next;     // update to next address
        // if pc_write=0, pc stays same (stall)
    end

endmodule