`timescale 1ns / 1ps
`include "opcode.v"

module tb_control_unit;

    reg  [31:0] tb_instruction;
    wire        tb_reg_write;
    wire [1:0]  tb_mem_to_reg;
    wire        tb_mem_read;
    wire        tb_mem_write;
    wire        tb_branch;
    wire        tb_jump;
    wire        tb_jump_r;
    wire        tb_alu_src_a;
    wire        tb_alu_src_b;
    wire [4:0]  tb_alu_ctrl;
    wire        tb_illegal_instr;
    wire        tb_is_w_operation;

    integer errors;

    control_unit uut (
        .instruction    (tb_instruction),
        .reg_write      (tb_reg_write),
        .mem_to_reg     (tb_mem_to_reg),
        .mem_read       (tb_mem_read),
        .mem_write      (tb_mem_write),
        .branch         (tb_branch),
        .jump           (tb_jump),
        .jump_r         (tb_jump_r),
        .alu_src_a      (tb_alu_src_a),
        .alu_src_b      (tb_alu_src_b),
        .alu_ctrl       (tb_alu_ctrl),
        .illegal_instr  (tb_illegal_instr),
        .is_w_operation (tb_is_w_operation)
    );

    task verify (
        input [256*8-1:0] test_name,
        input exp_reg_write,
        input [1:0] exp_mem_to_reg,
        input exp_mem_read,
        input exp_mem_write,
        input exp_branch,
        input exp_jump,
        input exp_jump_r,
        input exp_alu_src_a,
        input exp_alu_src_b,
        input [4:0] exp_alu_ctrl,
        input exp_illegal,
        input exp_is_w
    );
    begin
        #5; // Allow combinational logic to propagate
        if (tb_reg_write      !== exp_reg_write     ||
            tb_mem_to_reg     !== exp_mem_to_reg    ||
            tb_mem_read       !== exp_mem_read      ||
            tb_mem_write      !== exp_mem_write     ||
            tb_branch         !== exp_branch        ||
            tb_jump           !== exp_jump          ||
            tb_jump_r         !== exp_jump_r        ||
            tb_alu_src_a      !== exp_alu_src_a     ||
            tb_alu_src_b      !== exp_alu_src_b     ||
            tb_alu_ctrl       !== exp_alu_ctrl      ||
            tb_illegal_instr  !== exp_illegal       ||
            tb_is_w_operation !== exp_is_w) begin
            $display("[FAIL] %0s", test_name);
            $display("       Expected: reg_w=%0b, mem_to_reg=%0b, alu_ctrl=%0d, alu_src_b=%0b, illegal=%0b, is_w=%0b",
                     exp_reg_write, exp_mem_to_reg, exp_alu_ctrl, exp_alu_src_b, exp_illegal, exp_is_w);
            $display("       Got     : reg_w=%0b, mem_to_reg=%0b, alu_ctrl=%0d, alu_src_b=%0b, illegal=%0b, is_w=%0b",
                     tb_reg_write, tb_mem_to_reg, tb_alu_ctrl, tb_alu_src_b, tb_illegal_instr, tb_is_w_operation);
            errors = errors + 1;
        end else begin
            $display("[PASS] %0s | alu_ctrl=%0d", test_name, tb_alu_ctrl);
        end
    end
    endtask

    initial begin
        $dumpfile("control_unit_waveform.vcd");
        $dumpvars(0, tb_control_unit);

        errors = 0;
        $display("==================================================================");
        $display("            TESTBENCH: RV64I CONTROL UNIT VERIFICATION            ");
        $display("==================================================================");

        // 1. ADD: add x3, x1, x2 (R-type)
        tb_instruction = 32'h002081b3;
        verify("ADD (R-type)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_ADD, 1'b0, 1'b0);

        // 2. SUB: sub x4, x2, x1 (R-type)
        tb_instruction = 32'h40110233;
        verify("SUB (R-type)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_SUB, 1'b0, 1'b0);

        // 3. MUL: mul x3, x1, x2 (M-extension: funct7[0] = 1, funct3 = 000)
        tb_instruction = 32'h022081b3;
        verify("MUL (M-extension)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_MUL, 1'b0, 1'b0);

        // 4. ADDI: addi x1, x0, 5 (I-type)
        tb_instruction = 32'h00500093;
        verify("ADDI (I-type)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `ALU_ADD, 1'b0, 1'b0);

        // 5. ADDW: addw x3, x1, x2 (Word R-type)
        tb_instruction = 32'h002081bb;
        verify("ADDW (Word R-type)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_ADDW, 1'b0, 1'b1);

        // 6. ADDIW: addiw x1, x0, 5 (Word I-type)
        tb_instruction = 32'h0050009b;
        verify("ADDIW (Word I-type)", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `ALU_ADDW, 1'b0, 1'b1);

        // 7. LD: ld x5, 0(x1) (Load)
        tb_instruction = 32'h0000b283;
        verify("LD (Load)", 1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `ALU_ADD, 1'b0, 1'b0);

        // 8. SD: sd x5, 0(x1) (Store)
        tb_instruction = 32'h0050b023;
        verify("SD (Store)", 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `ALU_ADD, 1'b0, 1'b0);

        // 9. BEQ: beq x1, x2, 8 (Branch)
        tb_instruction = 32'h00208463;
        verify("BEQ (Branch)", 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_SUB, 1'b0, 1'b0);

        // 10. JAL: jal x0, 8 (Jump)
        tb_instruction = 32'h0080006f;
        verify("JAL (Jump)", 1'b1, 2'b10, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, `ALU_ADD, 1'b0, 1'b0);

        // 11. JALR: jalr x1, 0(x1) (Indirect Jump)
        tb_instruction = 32'h000080e7;
        verify("JALR (Jump Reg)", 1'b1, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, `ALU_ADD, 1'b0, 1'b0);

        // 12. AUIPC: auipc x1, 1
        tb_instruction = 32'h00001097;
        verify("AUIPC", 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, `ALU_ADD, 1'b0, 1'b0);

        // 13. Illegal Opcode: Undefined 7'b1111111
        tb_instruction = 32'hFFFFFFFF;
        verify("Illegal Opcode", 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `ALU_ADD, 1'b1, 1'b0);

        $display("==================================================================");
        if (errors == 0)
            $display("              ALL CONTROL UNIT TESTS PASSED (0 ERRORS)            ");
        else
            $display("              TESTS FAILED WITH %0d ERROR(S)                      ", errors);
        $display("==================================================================");

        #10;
        $finish;
    end

endmodule