module PC #(
    parameter [63:0] RESET_ADDR = 64'h00000000_00000000
)(
    input wire clk,
    input wire reset,
    input wire pc_write_en,
    input wire [63:0] pc_next,
    output reg [63:0] pc_current
    output wire pc_misaligned
);
    assign pc_misaligned = pc_write_en && (pc_next[1:0] != 2'b00);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_current <= RESET_ADDR;
        end else if (pc_write_en) begin
            pc_current <= pc_next;
        end
    end
endmodule