
`include "opcode.v"

module riscv_core_top #(
    parameter RESET_ADDR = 64'd0,
    parameter DM_SIZE    = 65536  // 64 KB Data Memory
)(
    input  wire        clk,
    input  wire        reset,
    //testbench
    output wire [63:0] debug_pc,
    output wire [31:0] debug_instruction,
    output wire [63:0] debug_alu_out,
    output wire [63:0] debug_write_data,
    output wire        debug_reg_write,
    output wire        debug_cpu_stop
);
    wire [63:0] pc_current;
    reg  [63:0] pc_next;
    wire [31:0] instruction;
    //control wires
    wire        reg_write;
    wire [1:0]  mem_to_reg;
    wire        mem_read;
    wire        mem_write;
    wire        branch;
    wire        jump;
    wire        jump_r;
    wire        alu_src_a;
    wire        alu_src_b;
    wire [4:0]  alu_ctrl;
    wire        is_w_operation;
    wire [2:0]  branch_ctrl;
    //registers
    wire [63:0] rs1_data;
    wire [63:0] rs2_data;
    reg  [63:0] rd_data;
    //immediate
    wire [63:0] imm_out;
    wire        branch_taken;
    wire        take_branch;
    //alu
    wire [63:0] alu_in_a;
    wire [63:0] alu_in_b;
    wire [63:0] alu_out;
    wire        alu_zero;
    //memeory
    wire [63:0] mem_read_data;
    wire        cpu_stall;

    wire [2:0]  funct3out;
    wire        pc_misaligned;
    wire        illegal_instr;

    //pc
    assign cpu_stall = pc_misaligned | illegal_instr;
    PC #(
        .RESET_ADDR(RESET_ADDR)
    ) u_pc (
        .clk                            (clk),
        .reset                          (reset),
        .pc_write_en                    (!cpu_stall),
        .pc_next                        (pc_next),
        .pc_current                     (pc_current),
        .pc_misaligned                  (pc_misaligned)
    );
    //instruction memory
    instruction_mem u_imem (
        .addr (pc_current),
        .instruction (instruction)
    );
    //control unit
    control_unit u_control (
        .instruction    (instruction),
        .reg_write      (reg_write),
        .mem_to_reg     (mem_to_reg),
        .mem_read       (mem_read),
        .mem_write      (mem_write),
        .branch         (branch),
        .jump           (jump),
        .jump_r         (jump_r),
        .alu_src_a      (alu_src_a),
        .alu_src_b      (alu_src_b),
        .alu_ctrl       (alu_ctrl),
        .illegal_instr  (illegal_instr),
        .is_w_operation (is_w_operation),
        .branch_ctrl    (branch_ctrl),
        .funct3out       (funct3out)
    );
    //immediate generator
    imm_gen u_imm_gen (
        .instruction    (instruction),
        .immediate (imm_out)
    );
    //register file
    regfile u_regfile (
        .clk      (clk),
        .reset    (reset),
        .write_en (reg_write & !cpu_stall),
        .rs1_addr (instruction[19:15]),
        .rs2_addr (instruction[24:20]),
        .rd_addr  (instruction[11:7]),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );
    //comparator
    branch_comparator u_branch_comp (
        .a            (rs1_data),
        .b            (rs2_data),
        .branch_ctrl  (branch_ctrl),
        .branch_taken (branch_taken)
    );

    assign take_branch = branch & branch_taken;
    //alu
    assign alu_in_a = (alu_src_a) ? pc_current : rs1_data;
    assign alu_in_b = (alu_src_b) ? imm_out    : rs2_data;

    alu64 u_alu (
        .a    (alu_in_a),
        .b    (alu_in_b),
        .ctrl (alu_ctrl),
        .out  (alu_out),
        .zero (alu_zero)
    );
    //data ram
    data_mem #(
        .MEM_SIZE (DM_SIZE)
    ) u_dmem (
        .clk        (clk),
        .mem_read   (mem_read & !cpu_stall),
        .mem_write  (mem_write  & !cpu_stall),
        .funct3     (funct3out),
        .addr       (alu_out),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );
    //mem to reg mux
    always @(*) begin
        case (mem_to_reg)
            2'b00:   rd_data = alu_out;
            2'b01:   rd_data = mem_read_data;
            2'b10:   rd_data = pc_current + 64'd4;
            2'b11:   rd_data = imm_out;
            default: rd_data = alu_out;
        endcase
    end
    //next pc mux
    always @(*) begin
        if (jump) begin
            pc_next = pc_current + imm_out;
        end else if (jump_r) begin
            pc_next = (rs1_data + imm_out) & ~64'd1;
        end else if (take_branch) begin
            pc_next = pc_current + imm_out;
        end else begin
            pc_next = pc_current + 64'd4;
        end
    end
    //debug
    assign debug_pc          = pc_current;
    assign debug_instruction = instruction;
    assign debug_alu_out     = alu_out;
    assign debug_write_data  = rd_data;
    assign debug_reg_write   = reg_write;
    assign debug_cpu_stop    = cpu_stall;

endmodule