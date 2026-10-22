module regfile(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [63:0] rd_data,
    output wire [63:0] rs1_data,
    output wire [63:0] rs2_data,
    input wire shadow_mode
);
    reg [63:0] regs[31:0]; 
    integer i;

    assign rs1_data = (rs1_addr == 5'd0) ? 64'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 64'd0 : regs[rs2_addr];
    
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 64'd0;
            end
        end else if (write_en && rd_addr != 5'd0) begin
            regs[rd_addr] <= rd_data;
        end
    end

endmodule