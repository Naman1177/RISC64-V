`include "opcode.v"


module control_unit(
    input wire [31:0] instruction,
    output reg reg_write,  //goes to write enable of regfile
    output reg [1:0] mem_to_reg,//what goes in rd ,00- ALU, 01- data memory, 10- PC+4, 11- immediate
    output reg mem_read, //read operation from data memory
    output reg mem_write, //write operation to data memory
    output reg branch, //branch instruction and PC = PC + immediate
    output reg jump, //Jal Pc = PC + immediate_j
    output reg jump_r, //jalr
    output reg alu_src_a, //0- rs1, 1- pc_current
    output reg alu_src_b, //0-rs2, 1- immediate
    output reg [4:0] alu_ctrl, //5 bit code for alu operation defined in opcode.v
    output reg illegal_instr, //illegal instruction
    output reg is_w_operation, //tells if w or not
    output reg [2:0] branch_ctrl,
    output reg [2:0] funct3out //for branch comparator
);
    
    
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire funct7_5 = instruction[30]; //as only 31 bit is changed 
    wire funct7_0 = instruction[25]; //as only 31 bit is changed
    
    always @(*) begin
        // default
        funct3out = funct3;
        reg_write = 0;
        mem_to_reg = 2'b00;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        jump = 0;
        jump_r = 0;
        alu_src_a = 0;
        alu_src_b = 0;
        alu_ctrl = `ALU_ADD; 
        illegal_instr = 0;
        is_w_operation = 0;
        branch_ctrl = 3'b000;

        case(opcode)
            `OP_R: begin
                reg_write = 1;
                alu_src_b = 0;
                case(funct3)
                    3'b000: begin
                        if (funct7_0 && !funct7_5) begin
                        alu_ctrl = `ALU_MUL;
                        end else begin
                        alu_ctrl = (funct7_5) ? `ALU_SUB : `ALU_ADD;
                        end
                    end
                    3'b001: alu_ctrl = `ALU_SLL;
                    3'b010: alu_ctrl = `ALU_SLT;
                    3'b011: alu_ctrl = `ALU_SLTU;
                    3'b100: alu_ctrl = `ALU_XOR;
                    3'b101: alu_ctrl = (funct7_5) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_ctrl = `ALU_OR;
                    3'b111: alu_ctrl = `ALU_AND;
                endcase
            end
            `OP_I: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1; // use immediate
                case (funct3)
                    3'b000: alu_ctrl = `ALU_ADD;
                    3'b001: alu_ctrl = `ALU_SLL;
                    3'b010: alu_ctrl = `ALU_SLT;
                    3'b011: alu_ctrl = `ALU_SLTU;
                    3'b100: alu_ctrl = `ALU_XOR;
                    3'b101: alu_ctrl = (funct7_5) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_ctrl = `ALU_OR;
                    3'b111: alu_ctrl = `ALU_AND;
                endcase
            end
            `OP_W: begin
                reg_write = 1'b1;
                alu_src_b = 1'b0; // Use rs2
                is_w_operation = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = (funct7_5) ? `ALU_SUBW : `ALU_ADDW;
                    3'b001: alu_ctrl = `ALU_SLLW;
                    3'b101: alu_ctrl = (funct7_5) ? `ALU_SRAW : `ALU_SRLW;
                    default: alu_ctrl = `ALU_ADDW;
                endcase
            end
            `OP_IW: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1; // Use immediate
                is_w_operation = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = `ALU_ADDW;
                    3'b001: alu_ctrl = `ALU_SLLW;
                    3'b101: alu_ctrl = (funct7_5) ? `ALU_SRAW : `ALU_SRLW;
                    default: alu_ctrl = `ALU_ADDW;
                endcase
            end
            `OP_LOAD: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1; 
                alu_ctrl = `ALU_ADD;
                mem_read = 1'b1;
                mem_to_reg = 2'b01;

            end
            `OP_STORE: begin
                alu_src_b   = 1'b1;     
                alu_ctrl = `ALU_ADD;
                mem_write   = 1'b1;
            end
            `OP_BRANCH: begin
                branch      = 1'b1;    
                reg_write   = 1'b0;    
                mem_read    = 1'b0;     
                mem_write   = 1'b0;     
                alu_ctrl    = `ALU_ADD;
                case (funct3)
                    3'b000: branch_ctrl = `BR_BEQ;
                    3'b001: branch_ctrl = `BR_BNE;
                    3'b100: branch_ctrl = `BR_BLT;
                    3'b101: branch_ctrl = `BR_BGE;
                    3'b110: branch_ctrl = `BR_BLTU;
                    3'b111: branch_ctrl = `BR_BGEU;
                    default: branch_ctrl = 3'b000;
                endcase
            end
            `OP_JAL: begin
                jump        = 1'b1;
                reg_write   = 1'b1;
                mem_to_reg  = 2'b10;    
            end
            `OP_JALR: begin
                jump_r      = 1'b1;
                reg_write   = 1'b1;
                mem_to_reg  = 2'b10;    
                alu_src_b   = 1'b1;     
                alu_ctrl = `ALU_ADD;
            end
            `OP_LUI: begin
                reg_write   = 1'b1;
                mem_to_reg  = 2'b11;    
            end
            `OP_AUIPC: begin
                reg_write   = 1'b1;
                alu_src_a   = 1'b1;    
                alu_src_b   = 1'b1;     
                alu_ctrl = `ALU_ADD;
            end
            default: begin
                illegal_instr = 1'b1;
            end
        endcase
    end
endmodule



        