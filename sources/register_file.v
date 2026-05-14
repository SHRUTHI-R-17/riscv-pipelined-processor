module register_file (
    input         clk,
    input         rst,
    
    // Read port 1
    input  [4:0]  rs1,
    output [31:0] rd1,
    
    // Read port 2
    input  [4:0]  rs2,
    output [31:0] rd2,
    
    // Write port
    input         reg_write,
    input  [4:0]  rd,
    input  [31:0] write_data
);

    // 32 registers each 32 bits wide
    reg [31:0] registers [31:0];
    
    integer i;
    
    // Reset and write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Clear all registers on reset
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && rd != 5'b0) begin
            // Write data to register
            // x0 is always 0, never write to it
            registers[rd] <= write_data;
        end
    end

    // Read ports - combinational (instant)
    // x0 always returns 0
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

endmodule