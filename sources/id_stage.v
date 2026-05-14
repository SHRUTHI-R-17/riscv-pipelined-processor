`timescale 1ns/1ps

module id_stage (
    input         clk,
    input         rst,
    input  [31:0] instruction,
    input  [31:0] pc_plus4,

    // Write back inputs
    input         reg_write,
    input  [4:0]  rd_wb,
    input  [31:0] write_data,

    // Outputs to EX stage
    output [31:0] rd1,
    output [31:0] rd2,
    output [31:0] imm_ext,
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd,
    output [6:0]  opcode,
    output [2:0]  funct3,
    output [6:0]  funct7,

    // Control signals
    output        alu_src,
    output        mem_write,
    output        mem_read,
    output        mem_to_reg,
    output        branch,
    output [3:0]  alu_ctrl_out
);

    // Extract fields from instruction
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Immediate generator
    reg [31:0] imm;
    always @(*) begin
        case (opcode)
            7'b0010011: // I-type (ADDI, etc)
                imm = {{20{instruction[31]}}, instruction[31:20]};
            7'b0000011: // Load
                imm = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S-type (Store)
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type (Branch)
                imm = {{19{instruction[31]}}, instruction[31], instruction[7],
                        instruction[30:25], instruction[11:8], 1'b0};
            7'b0110111: // U-type (LUI)
                imm = {instruction[31:12], 12'b0};
            7'b1101111: // J-type (JAL)
                imm = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                        instruction[20], instruction[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end
    assign imm_ext = imm;

    // Register File
    register_file rf (
        .clk(clk), .rst(rst),
        .rs1(rs1), .rs2(rs2),
        .rd1(rd1), .rd2(rd2),
        .reg_write(reg_write),
        .rd(rd_wb),
        .write_data(write_data)
    );

    // Control Unit
    reg alu_src_r, mem_write_r, mem_read_r, mem_to_reg_r, branch_r;
    reg [3:0] alu_ctrl_r;

    always @(*) begin
        // defaults
        alu_src_r    = 0;
        mem_write_r  = 0;
        mem_read_r   = 0;
        mem_to_reg_r = 0;
        branch_r     = 0;
        alu_ctrl_r   = 4'b0000; // ADD

        case (opcode)
            7'b0110011: begin // R-type
                case ({funct7, funct3})
                    10'b0000000_000: alu_ctrl_r = 4'b0000; // ADD
                    10'b0100000_000: alu_ctrl_r = 4'b0001; // SUB
                    10'b0000000_111: alu_ctrl_r = 4'b0010; // AND
                    10'b0000000_110: alu_ctrl_r = 4'b0011; // OR
                    10'b0000000_100: alu_ctrl_r = 4'b0100; // XOR
                    10'b0000000_010: alu_ctrl_r = 4'b0111; // SLT
                    default:         alu_ctrl_r = 4'b0000;
                endcase
            end
            7'b0010011: begin // I-type ALU
                alu_src_r = 1;
                case (funct3)
                    3'b000: alu_ctrl_r = 4'b0000; // ADDI
                    3'b111: alu_ctrl_r = 4'b0010; // ANDI
                    3'b110: alu_ctrl_r = 4'b0011; // ORI
                    3'b010: alu_ctrl_r = 4'b0111; // SLTI
                    default: alu_ctrl_r = 4'b0000;
                endcase
            end
            7'b0000011: begin // Load
                alu_src_r    = 1;
                mem_read_r   = 1;
                mem_to_reg_r = 1;
                alu_ctrl_r   = 4'b0000; // ADD
            end
            7'b0100011: begin // Store
                alu_src_r   = 1;
                mem_write_r = 1;
                alu_ctrl_r  = 4'b0000; // ADD
            end
            7'b1100011: begin // Branch
                branch_r   = 1;
                alu_ctrl_r = 4'b0001; // SUB for comparison
            end
        endcase
    end

    assign alu_src    = alu_src_r;
    assign mem_write  = mem_write_r;
    assign mem_read   = mem_read_r;
    assign mem_to_reg = mem_to_reg_r;
    assign branch     = branch_r;
    assign alu_ctrl_out = alu_ctrl_r;

endmodule