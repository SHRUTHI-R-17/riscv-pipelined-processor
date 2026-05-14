`timescale 1ns/1ps

module hazard_unit (
    input      [4:0] id_ex_rs1, id_ex_rs2,
    input      [4:0] if_id_rs1, if_id_rs2,
    input      [4:0] id_ex_rd,
    input            id_ex_mem_read,
    input            branch_taken,
    output reg       stall,
    output reg       flush
);
    always @(*) begin
        stall = 0;
        flush = 0;

        // Load-use hazard: stall one cycle
        if (id_ex_mem_read &&
            (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
            stall = 1;
        end

        // Branch taken: flush IF/ID and ID/EX
        if (branch_taken) begin
            flush = 1;
        end
    end
endmodule