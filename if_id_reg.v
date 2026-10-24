
//wired with pc
module if_id_reg(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire write_en,
    input wire [63:0] if_pc,
    input wire [63:0] if_pc_plus4,
    input wire [31:0] if_instruction,
    output reg [63:0] id_pc,
    output reg [63:0] id_pc_plus4,
    output reg [31:0] id_instruction
);

    localparam [31:0] RV64_NOP = 32'h00000013; //addi x0, x0, 0
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc <= 64'b0;
            id_pc_plus4 <= 64'b0;
            id_instruction <= RV64_NOP; //no operation 
        end else if (flush) begin
            id_pc <= 64'b0;
            id_pc_plus4 <= 64'b0;
            id_instruction <= RV64_NOP; 
        end else if (write_en) begin
            id_pc <= if_pc;
            id_pc_plus4 <= if_pc_plus4;
            id_instruction <= if_instruction;
        end
    end