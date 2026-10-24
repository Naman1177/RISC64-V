

//control unit id_ex_reg.v
module id_ex_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    input  wire [63:0] id_pc,
    input  wire [63:0] id_pc_plus4,
    input  wire [63:0] id_rs1_data,
    input  wire [63:0] id_rs2_data,
    input  wire [63:0] id_imm,
    input  wire [4:0]  id_rs1_addr,
    input  wire [4:0]  id_rs2_addr,
    input  wire [4:0]  id_rd_addr,
    input  wire [2:0]  id_funct3,

    input  wire        id_reg_write,
    input  wire [1:0]  id_mem_to_reg,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire        id_alu_src_a,
    input  wire        id_alu_src_b,
    input  wire [4:0]  id_alu_ctrl,
    input  wire        id_branch,
    input  wire [2:0]  id_branch_ctrl,
    input  wire        id_jump,
    input  wire        id_jump_r,

    output reg  [63:0] ex_pc,
    output reg  [63:0] ex_pc_plus4,
    output reg  [63:0] ex_rs1_data,
    output reg  [63:0] ex_rs2_data,
    output reg  [63:0] ex_imm,
    output reg  [4:0]  ex_rs1_addr,
    output reg  [4:0]  ex_rs2_addr,
    output reg  [4:0]  ex_rd_addr,
    output reg  [2:0]  ex_funct3,

    output reg         ex_reg_write,
    output reg  [1:0]  ex_mem_to_reg,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg         ex_alu_src_a,
    output reg         ex_alu_src_b,
    output reg  [4:0]  ex_alu_ctrl,
    output reg         ex_branch,
    output reg  [2:0]  ex_branch_ctrl,
    output reg         ex_jump,
    output reg         ex_jump_r
);

    always @(posedge clk or posedge reset) begin
        if (flush || reset) begin
            ex_pc          <= 64'd0;
            ex_pc_plus4   <= 64'd0;
            ex_rs1_data    <= 64'd0;
            ex_rs2_data    <= 64'd0;
            ex_imm         <= 64'd0;
            ex_rs1_addr    <= 5'd0;
            ex_rs2_addr    <= 5'd0;
            ex_rd_addr     <= 5'd0;
            ex_funct3      <= 3'd0;

            ex_reg_write   <= 1'b0;
            ex_mem_to_reg  <= 2'b00;
            ex_mem_read    <= 1'b0;
            ex_mem_write   <= 1'b0;
            ex_alu_src_a   <= 1'b0;
            ex_alu_src_b   <= 1'b0;
            ex_alu_ctrl    <= 5'd0;
            ex_branch      <= 1'b0;
            ex_branch_ctrl <= 3'd0;
            ex_jump        <= 1'b0;
            ex_jump_r      <= 1'b0;

        end else begin
            ex_pc          <= id_pc;
            ex_pc_plus4   <= id_pc_plus_4;
            ex_rs1_data    <= id_rs1_data;
            ex_rs2_data    <= id_rs2_data;
            ex_imm         <= id_imm;
            ex_rs1_addr    <= id_rs1_addr;
            ex_rs2_addr    <= id_rs2_addr;
            ex_rd_addr     <= id_rd_addr;
            ex_funct3      <= id_funct3;

            ex_reg_write   <= id_reg_write;
            ex_mem_to_reg  <= id_mem_to_reg;
            ex_mem_read    <= id_mem_read;
            ex_mem_write   <= id_mem_write;
            ex_alu_src_a   <= id_alu_src_a;
            ex_alu_src_b   <= id_alu_src_b;
            ex_alu_ctrl    <= id_alu_ctrl;
            ex_branch      <= id_branch;
            ex_branch_ctrl <= id_branch_ctrl;
            ex_jump        <= id_jump;
            ex_jump_r      <= id_jump_r;
        end
    end
endmodule