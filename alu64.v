`include "opcode.v"

module alu64(
    input wire [63:0] a,
    input wire [63:0] b,
    input wire [4:0] ctrl,
    output reg [63:0] out,
    output wire zero
);
    reg [31:0] res32;
    always @(*) begin
        case (ctrl)
            `ALU_ADD: out = a + b;
            `ALU_SUB: out = a - b;
            `ALU_AND: out = a & b;
            `ALU_OR:  out = a | b;
            `ALU_XOR: out = a ^ b;
            `ALU_SLT:  out = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0;
            `ALU_SLL: out = a << b[5:0];
            `ALU_SRL: out = a >> b[5:0];
            `ALU_SRA: out = $signed(a) >>> b[5:0];
            `ALU_SLTU: out = (a < b) ? 64'd1 : 64'd0;
            `ALU_MUL: out = a * b;
            
            `ALU_ADDW: begin
                res32 = a[31:0] + b[31:0];
                out   = {{32{res32[31]}}, res32};
            end
            `ALU_SUBW: begin
                res32 = a[31:0] - b[31:0];
                out   = {{32{res32[31]}}, res32};
            end
            `ALU_SLLW: begin
                res32 = a[31:0] << b[4:0];
                out   = {{32{res32[31]}}, res32};
            end
            `ALU_SRLW: begin
                res32 = a[31:0] >> b[4:0];
                out   = {{32{res32[31]}}, res32};
            end
            `ALU_SRAW: begin
                res32 = $signed(a[31:0]) >>> b[4:0];
                out   = {{32{res32[31]}}, res32};
            end
            
            default: out = 64'd0;
        endcase
    end
    assign zero = (out == 64'd0);
endmodule