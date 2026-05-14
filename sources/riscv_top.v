`timescale 1ns/1ps

module riscv_top (
    input clk, rst,
    // Performance outputs (visible for testbench)
    output [31:0] total_cycles,
    output [31:0] total_instructions,
    output [31:0] stall_cycles,
    output [31:0] cpi_x100,
    output [31:0] branch_count,
    output [31:0] correct_predictions
);

    // ?? IF Stage wires ??
    wire [31:0] if_pc_out, if_pc_plus4, if_instruction;
    wire        pc_src_final;
    wire [31:0] branch_target_final;
    wire        stall, flush;

    // ?? IF/ID Register wires ??
    wire [31:0] if_id_pc, if_id_pc_plus4, if_id_instruction;

    // ?? ID Stage wires ??
    wire [31:0] id_rd1, id_rd2, id_imm;
    wire [4:0]  id_rs1, id_rs2, id_rd;
    wire [6:0]  id_opcode;
    wire [2:0]  id_funct3;
    wire [6:0]  id_funct7;
    wire        id_alu_src, id_mem_write, id_mem_read;
    wire        id_mem_to_reg, id_branch, id_reg_write;
    wire [3:0]  id_alu_ctrl;

    // ?? ID/EX Register wires ??
    wire [31:0] id_ex_pc, id_ex_rd1, id_ex_rd2, id_ex_imm;
    wire [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [3:0]  id_ex_alu_ctrl;
    wire        id_ex_alu_src, id_ex_mem_write, id_ex_mem_read;
    wire        id_ex_mem_to_reg, id_ex_branch, id_ex_reg_write;

    // ?? Forwarding wires ??
    wire [1:0]  forward_a, forward_b;
    wire [31:0] alu_in_a, alu_in_b;

    // ?? EX Stage wires ??
    wire [31:0] ex_alu_result, ex_branch_target;
    wire        ex_zero;

    // ?? EX/MEM Register wires ??
    wire [31:0] ex_mem_alu_result, ex_mem_rd2, ex_mem_branch_target;
    wire [4:0]  ex_mem_rd;
    wire        ex_mem_zero, ex_mem_mem_write, ex_mem_mem_read;
    wire        ex_mem_mem_to_reg, ex_mem_branch, ex_mem_reg_write;

    // ?? MEM Stage wires ??
    wire [31:0] mem_read_data;
    wire        mem_pc_src;

    // ?? MEM/WB Register wires ??
    wire [31:0] mem_wb_alu_result, mem_wb_read_data;
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_mem_to_reg, mem_wb_reg_write;

    // ?? WB Stage wires ??
    wire [31:0] wb_write_data;

    // ?? Branch predictor wires ??
    wire        bp_predicted_taken;
    wire [31:0] bp_predicted_target;
    wire        bp_correct;
    wire [31:0] bp_total, bp_correct_count;

    // ??? PC source selection ???
    assign pc_src_final      = mem_pc_src;
    assign branch_target_final = ex_mem_branch_target;

    // ??? IF Stage ???
    if_stage IF (
        .clk(clk), .rst(rst),
        .pc_write(!stall),
        .pc_next(branch_target_final),
        .pc_src(pc_src_final),
        .pc_out(if_pc_out),
        .pc_plus4(if_pc_plus4),
        .instruction(if_instruction)
    );

    // ??? IF/ID Pipeline Register ???
    if_id_reg IF_ID (
        .clk(clk), .rst(rst),
        .stall(stall), .flush(flush),
        .pc_in(if_pc_out),
        .pc_plus4_in(if_pc_plus4),
        .instruction_in(if_instruction),
        .pc_out(if_id_pc),
        .pc_plus4_out(if_id_pc_plus4),
        .instruction_out(if_id_instruction)
    );

    // ??? ID Stage ???
    id_stage ID (
        .clk(clk), .rst(rst),
        .instruction(if_id_instruction),
        .pc_plus4(if_id_pc_plus4),
        .reg_write(mem_wb_reg_write),
        .rd_wb(mem_wb_rd),
        .write_data(wb_write_data),
        .rd1(id_rd1), .rd2(id_rd2),
        .imm_ext(id_imm),
        .rs1(id_rs1), .rs2(id_rs2), .rd(id_rd),
        .opcode(id_opcode),
        .funct3(id_funct3), .funct7(id_funct7),
        .alu_src(id_alu_src),
        .mem_write(id_mem_write),
        .mem_read(id_mem_read),
        .mem_to_reg(id_mem_to_reg),
        .branch(id_branch),
        .alu_ctrl_out(id_alu_ctrl)
    );

    // ??? Hazard Detection Unit ???
    hazard_unit HZD (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .branch_taken(mem_pc_src),
        .stall(stall),
        .flush(flush)
    );

    // ??? ID/EX Pipeline Register ???
    id_ex_reg ID_EX (
        .clk(clk), .rst(rst), .flush(flush),
        .pc_in(if_id_pc), .rd1_in(id_rd1), .rd2_in(id_rd2),
        .imm_in(id_imm), .rs1_in(id_rs1), .rs2_in(id_rs2),
        .rd_in(id_rd), .alu_ctrl_in(id_alu_ctrl),
        .alu_src_in(id_alu_src), .mem_write_in(id_mem_write),
        .mem_read_in(id_mem_read), .mem_to_reg_in(id_mem_to_reg),
        .branch_in(id_branch), .reg_write_in(id_reg_write),
        .pc_out(id_ex_pc), .rd1_out(id_ex_rd1), .rd2_out(id_ex_rd2),
        .imm_out(id_ex_imm), .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd), .alu_ctrl_out(id_ex_alu_ctrl),
        .alu_src_out(id_ex_alu_src), .mem_write_out(id_ex_mem_write),
        .mem_read_out(id_ex_mem_read), .mem_to_reg_out(id_ex_mem_to_reg),
        .branch_out(id_ex_branch), .reg_write_out(id_ex_reg_write)
    );

    // ??? Forwarding Unit ???
    forwarding_unit FWD (
        .ex_rs1(id_ex_rs1), .ex_rs2(id_ex_rs2),
        .mem_rd(ex_mem_rd), .wb_rd(mem_wb_rd),
        .mem_reg_write(ex_mem_reg_write),
        .wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // ??? Forwarding MUXes ???
    assign alu_in_a = (forward_a == 2'b10) ? ex_mem_alu_result :
                      (forward_a == 2'b01) ? wb_write_data : id_ex_rd1;

    assign alu_in_b = (forward_b == 2'b10) ? ex_mem_alu_result :
                      (forward_b == 2'b01) ? wb_write_data :
                      id_ex_alu_src ? id_ex_imm : id_ex_rd2;

    // ??? EX Stage (ALU only) ???
    alu ALU (
        .a(alu_in_a),
        .b(alu_in_b),
        .alu_ctrl(id_ex_alu_ctrl),
        .result(ex_alu_result),
        .zero(ex_zero)
    );
    assign ex_branch_target = id_ex_pc + (id_ex_imm << 1);

    // ??? EX/MEM Pipeline Register ???
    ex_mem_reg EX_MEM (
        .clk(clk), .rst(rst),
        .alu_result_in(ex_alu_result), .rd2_in(id_ex_rd2),
        .branch_target_in(ex_branch_target), .rd_in(id_ex_rd),
        .zero_in(ex_zero), .mem_write_in(id_ex_mem_write),
        .mem_read_in(id_ex_mem_read), .mem_to_reg_in(id_ex_mem_to_reg),
        .branch_in(id_ex_branch), .reg_write_in(id_ex_reg_write),
        .alu_result_out(ex_mem_alu_result), .rd2_out(ex_mem_rd2),
        .branch_target_out(ex_mem_branch_target), .rd_out(ex_mem_rd),
        .zero_out(ex_mem_zero), .mem_write_out(ex_mem_mem_write),
        .mem_read_out(ex_mem_mem_read), .mem_to_reg_out(ex_mem_mem_to_reg),
        .branch_out(ex_mem_branch), .reg_write_out(ex_mem_reg_write)
    );

    // ??? MEM Stage ???
    mem_stage MEM (
        .clk(clk),
        .mem_write(ex_mem_mem_write),
        .mem_read(ex_mem_mem_read),
        .branch(ex_mem_branch),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rd2(ex_mem_rd2),
        .branch_target(ex_mem_branch_target),
        .read_data(mem_read_data),
        .pc_src(mem_pc_src)
    );

    // ??? MEM/WB Pipeline Register ???
    mem_wb_reg MEM_WB (
        .clk(clk), .rst(rst),
        .alu_result_in(ex_mem_alu_result),
        .read_data_in(mem_read_data),
        .rd_in(ex_mem_rd),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .reg_write_in(ex_mem_reg_write),
        .alu_result_out(mem_wb_alu_result),
        .read_data_out(mem_wb_read_data),
        .rd_out(mem_wb_rd),
        .mem_to_reg_out(mem_wb_mem_to_reg),
        .reg_write_out(mem_wb_reg_write)
    );

    // ??? WB Stage ???
    wb_stage WB (
        .mem_to_reg(mem_wb_mem_to_reg),
        .alu_result(mem_wb_alu_result),
        .read_data(mem_wb_read_data),
        .write_data(wb_write_data)
    );

    // ??? Branch Predictor ???
    branch_predictor BP (
        .clk(clk), .rst(rst),
        .branch(ex_mem_branch),
        .actual_taken(mem_pc_src),
        .pc(if_pc_out),
        .predicted_taken(bp_predicted_taken),
        .predicted_target(bp_predicted_target),
        .prediction_correct(bp_correct),
        .total_predictions(bp_total),
        .correct_predictions(bp_correct_count)
    );
    assign correct_predictions = bp_correct_count;

    // ??? Performance Counter ???
    performance_counter PERF (
        .clk(clk), .rst(rst),
        .stall(stall),
        .branch_taken(mem_pc_src),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .instruction(if_id_instruction),
        .total_cycles(total_cycles),
        .total_instructions(total_instructions),
        .stall_cycles(stall_cycles),
        .branch_count(branch_count),
        .mem_access_count(),
        .cpi_x100(cpi_x100)
    );

    // ??? ID reg_write fix ???
    assign id_reg_write = ~id_mem_write & ~id_branch;

endmodule