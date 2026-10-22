`include "opcode.v"

module branch_comparator(
    input wire [63:0] a,
    input wire [63:0] b,
    input wire [2:0] branch_ctrl, //come from control unit of branch_ctrl
    output reg branch_taken
    
);
    always @(*) begin
        case (branch_ctrl)
            `BR_BEQ:  branch_taken = (a == b);                        // BEQ
            `BR_BNE:  branch_taken = (a != b);                        // BNE
            `BR_BLT:  branch_taken = ($signed(a) <  $signed(b));       // BLT
            `BR_BGE:  branch_taken = ($signed(a) >=$signed(b));       // BGE
            `BR_BLTU: branch_taken = (a < b);                         // BLTU (unsigned)
            `BR_BGEU: branch_taken = (a >= b);
            default: branch_taken = 1'b0;
        endcase
    end
endmodule