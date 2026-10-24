module ex_mem_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire [63:0] ex_alu_out,
    input  wire [63:0] ex_rs2_data,  //stored for next stage     
    input  wire [63:0] ex_pc_plus_4,
    input  wire [63:0] ex_imm,
    input  wire [4:0]  ex_rd_addr,
    input  wire [2:0]  ex_funct3,

    input  wire        ex_reg_write,
    input  wire [1:0]  ex_mem_to_reg,
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,

    output reg  [63:0] mem_alu_out,
    output reg  [63:0] mem_rs2_data,
    output reg  [63:0] mem_pc_plus_4,
    output reg  [63:0] mem_imm,
    output reg  [4:0]  mem_rd_addr,
    output reg  [2:0]  mem_funct3,

    output reg         mem_reg_write,
    output reg  [1:0]  mem_mem_to_reg,
    output reg         mem_mem_read,
    output reg         mem_mem_write

);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_alu_out    <= 64'd0;
            mem_rs2_data   <= 64'd0;
            mem_pc_plus_4  <= 64'd0;
            mem_imm        <= 64'd0;
            mem_rd_addr    <= 5'd0;
            mem_funct3     <= 3'd0;
            mem_reg_write  <= 1'b0;
            mem_mem_to_reg <= 2'b00;
            mem_mem_read   <= 1'b0;
            mem_mem_write  <= 1'b0;
        end else begin
            mem_alu_out    <= ex_alu_out;
            mem_rs2_data   <= ex_rs2_data;
            mem_pc_plus_4  <= ex_pc_plus_4;
            mem_imm        <= ex_imm;
            mem_rd_addr    <= ex_rd_addr;
            mem_funct3     <= ex_funct3;
            mem_reg_write  <= ex_reg_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
        end
    end

endmodule