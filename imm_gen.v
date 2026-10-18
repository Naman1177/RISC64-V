`include "opcode.v"


module imm_gen(
    input wire [31:0] instruction,
    output reg [63:0] immediate
);
    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            `OP_I,`OP_IW,`OP_LOAD,`OP_JALR: begin //I,IW,L,JALR
                immediate = {{52{instruction[31]}}, instruction[31:20]};
            end
            `OP_STORE: begin //s type
                immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            `OP_BRANCH: begin //b type
                immediate = {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            `OP_LUI,`OP_AUIPC: begin //lui,auipc
                immediate = {{32{instruction[31]}}, instruction[31:12], 12'b0};
            end
            `OP_JAL: begin //j type
                immediate = {{44{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            default: begin
                immediate = 64'b0;
            end
        endcase
    end

endmodule