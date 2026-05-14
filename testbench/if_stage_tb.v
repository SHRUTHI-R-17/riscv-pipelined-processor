`timescale 1ns/1ps

module id_stage_tb;

    reg         clk, rst;
    reg  [31:0] instruction, pc_plus4;
    reg         reg_write;
    reg  [4:0]  rd_wb;
    reg  [31:0] write_data;

    wire [31:0] rd1, rd2, imm_ext;
    wire [4:0]  rs1, rs2, rd;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire        alu_src, mem_write, mem_read, mem_to_reg, branch;
    wire [3:0]  alu_ctrl_out;

    id_stage uut (
        .clk(clk), .rst(rst),
        .instruction(instruction),
        .pc_plus4(pc_plus4),
        .reg_write(reg_write),
        .rd_wb(rd_wb),
        .write_data(write_data),
        .rd1(rd1), .rd2(rd2),
        .imm_ext(imm_ext),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_ctrl_out(alu_ctrl_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1;
        instruction=0; pc_plus4=0;
        reg_write=0; rd_wb=0; write_data=0;
        #20; rst=0;

        // Write 42 to x1 and 100 to x2
        reg_write=1; rd_wb=5'd1; write_data=32'd42; #10;
        reg_write=1; rd_wb=5'd2; write_data=32'd100; #10;
        reg_write=0;

        // Test ADD x3, x1, x2 ? opcode=0110011, rd=3, rs1=1, rs2=2
        // Instruction: funct7=0, rs2=2, rs1=1, funct3=0, rd=3, opcode=0110011
        instruction = 32'b0000000_00010_00001_000_00011_0110011;
        pc_plus4 = 32'd4;
        #10;
        $display("ADD x3,x1,x2: opcode=%b, rs1=%0d, rs2=%0d, rd=%0d", opcode, rs1, rs2, rd);
        $display("rd1=%0d (expect 42), rd2=%0d (expect 100)", rd1, rd2);
        $display("alu_src=%b (expect 0), alu_ctrl=%b (expect 0000)", alu_src, alu_ctrl_out);

        // Test ADDI x4, x1, 5 ? I-type
        // imm=5, rs1=1, funct3=0, rd=4, opcode=0010011
        instruction = 32'b000000000101_00001_000_00100_0010011;
        #10;
        $display("ADDI x4,x1,5: imm=%0d (expect 5), alu_src=%b (expect 1)", imm_ext, alu_src);

        // Test LW x5, 8(x1) ? Load
        // imm=8, rs1=1, funct3=0, rd=5, opcode=0000011
        instruction = 32'b000000001000_00001_010_00101_0000011;
        #10;
        $display("LW: mem_read=%b (expect 1), mem_to_reg=%b (expect 1)", mem_read, mem_to_reg);

        // Test BEQ x1, x2, offset ? Branch
        // opcode=1100011
        instruction = 32'b0000000_00010_00001_000_00000_1100011;
        #10;
        $display("BEQ: branch=%b (expect 1)", branch);

        $display("ID Stage test PASSED!");
        $finish;
    end

endmodule