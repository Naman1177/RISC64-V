module mem_wb_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire [63:0] mem_read_data,
    input  wire [63:0] mem_alu_out,
    input  wire [63:0] mem_pc_plus4,
    input  wire [63:0] mem_imm,
    input  wire [4:0]  mem_rd_addr,
    input  wire        mem_reg_write,
    input  wire [1:0]  mem_mem_to_reg,
    output reg  [63:0] wb_read_data,
    output reg  [63:0] wb_alu_out,
    output reg  [63:0] wb_pc_plus4,
    output reg  [63:0] wb_imm,
    output reg  [4:0]  wb_rd_addr,
    output reg         wb_reg_write,
    output reg  [1:0]  wb_mem_to_reg
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_read_data   <= 64'd0;
            wb_alu_out     <= 64'd0;
            wb_pc_plus_4   <= 64'd0;
            wb_imm         <= 64'd0;
            wb_rd_addr     <= 5'd0;
            wb_reg_write   <= 1'b0;
            wb_mem_to_reg  <= 2'b00;
        end else begin
            wb_read_data   <= mem_read_data;
            wb_alu_out     <= mem_alu_out;
            wb_pc_plus_4   <= mem_pc_plus_4;
            wb_imm         <= mem_imm;
            wb_rd_addr     <= mem_rd_addr;
            wb_reg_write   <= mem_reg_write;
            wb_mem_to_reg  <= mem_mem_to_reg;
        end
    end

endmodule