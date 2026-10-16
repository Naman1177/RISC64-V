`timescale 1ns / 1ps
`include "opcode.v"

module tb_alu;

    // Inputs to DUT (Device Under Test)
    reg  [63:0] a;
    reg  [63:0] b;
    reg  [4:0]  ctrl;

    // Outputs from DUT
    wire [63:0] out;
    wire        zero;

    // Error tracking
    integer errors;

    // Instantiate the 64-bit ALU
    alu64 dut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .out(out),
        .zero(zero)
    );

    // Task to automatically check results
    task check_result;
        input [63:0] expected_out;
        input        expected_zero;
        input [127:0] op_name;
        begin
            #1; // Allow combinational logic to settle
            if (out !== expected_out || zero !== expected_zero) begin
                $display("[-] FAIL: %0s | a=0x%h, b=0x%h, ctrl=%0d", op_name, a, b, ctrl);
                $display("    Expected: out=0x%h, zero=%b", expected_out, expected_zero);
                $display("    Got:      out=0x%h, zero=%b", out, zero);
                errors = errors + 1;
            end else begin
                $display("[+] PASS: %0s | out=0x%h, zero=%b", op_name, out, zero);
            end
        end
    endtask

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("alu_waveform.vcd");
        $dumpvars(0, tb_alu);

        errors = 0;
        $display("\n==============================================");
        $display("       STARTING RV64 ALU TESTBENCH            ");
        $display("==============================================");

        // 1. ADD
        a = 64'd25; b = 64'd15; ctrl = `ALU_ADD;
        check_result(64'd40, 1'b0, "ADD");

        // 2. SUB (Non-zero)
        a = 64'd50; b = 64'd20; ctrl = `ALU_SUB;
        check_result(64'd30, 1'b0, "SUB (positive)");

        // 3. SUB resulting in ZERO (Testing zero_flag)
        a = 64'hAAAA_BBBB_CCCC_DDDD; b = 64'hAAAA_BBBB_CCCC_DDDD; ctrl = `ALU_SUB;
        check_result(64'd0, 1'b1, "SUB (zero flag)");

        // 4. AND
        a = 64'hF0F0_FFFF_0000_1234; b = 64'h0F0F_FFFF_FFFF_0000; ctrl = `ALU_AND;
        check_result(64'h0000_FFFF_0000_0000, 1'b0, "AND");

        // 5. OR
        a = 64'hF0F0_0000_0000_0000; b = 64'h0F0F_0000_0000_FFFF; ctrl = `ALU_OR;
        check_result(64'hFFFF_0000_0000_FFFF, 1'b0, "OR");

        // 6. XOR
        a = 64'hFFFF_0000_AAAA_5555; b = 64'hFFFF_FFFF_5555_AAAA; ctrl = `ALU_XOR;
        check_result(64'h0000_FFFF_FFFF_FFFF, 1'b0, "XOR");

        // 7. SLT (Signed comparison: -10 < 5 is TRUE)
        a = -64'sd10; b = 64'sd5; ctrl = `ALU_SLT;
        check_result(64'd1, 1'b0, "SLT (-10 < 5)");

        // 8. SLTU (Unsigned comparison: -10 is 0xFFFFFFFFFFFFFFF6 > 5, so FALSE)
        a = -64'sd10; b = 64'sd5; ctrl = `ALU_SLTU;
        check_result(64'd0, 1'b1, "SLTU (0xFF...F6 < 5)");

        // 9. SLL (Shift Left Logical: 1 shifted by 4)
        a = 64'd1; b = 64'd4; ctrl = `ALU_SLL;
        check_result(64'h0000_0000_0000_0010, 1'b0, "SLL (1 << 4)");

        // 10. SRL (Shift Right Logical: high 1 shifts right with 0s filling in)
        a = 64'h8000_0000_0000_0000; b = 64'd1; ctrl = `ALU_SRL;
        check_result(64'h4000_0000_0000_0000, 1'b0, "SRL (0x80.. >> 1)");

        // 11. SRA (Shift Right Arithmetic: negative sign bit preserved)
        a = 64'h8000_0000_0000_0000; b = 64'd1; ctrl = `ALU_SRA;
        check_result(64'hC000_0000_0000_0000, 1'b0, "SRA (0x80.. >>> 1)");

        // 12. MUL (Multiply lower 64b)
        a = 64'd12; b = 64'd11; ctrl = `ALU_MUL;
        check_result(64'd132, 1'b0, "MUL (12 * 11)");

        // 13. ADDW (Word add with negative sign extension: 0x7FFFFFFF + 1 = 0x80000000 -> sign-extended to 64b)
        a = 64'h0000_0000_7FFF_FFFF; b = 64'h0000_0000_0000_0001; ctrl = `ALU_ADDW;
        check_result(64'hFFFF_FFFF_8000_0000, 1'b0, "ADDW (sign-ext)");

        // 14. SUBW (Word sub: 10 - 20 = -10 -> sign-extended)
        a = 64'd10; b = 64'd20; ctrl = `ALU_SUBW;
        check_result(64'hFFFF_FFFF_FFFF_FFF6, 1'b0, "SUBW (10 - 20)");

        // 15. SLLW (Word shift left: 5-bit shift mask)
        a = 64'h0000_0000_0000_0001; b = 64'd31; ctrl = `ALU_SLLW;
        check_result(64'hFFFF_FFFF_8000_0000, 1'b0, "SLLW (bit 31 sign-ext)");

        // 16. SRLW (Word shift right logical: zeros fill upper 32 bits after sign-extension of MSB)
        a = 64'h0000_0000_0000_0080; b = 64'd3; ctrl = `ALU_SRLW;
        check_result(64'h0000_0000_0000_0010, 1'b0, "SRLW (0x80 >> 3)");

        // 17. SRAW (Word shift right arithmetic: preserves sign of lower 32b)
        a = 64'h0000_0000_8000_0000; b = 64'd1; ctrl = `ALU_SRAW;
        check_result(64'hFFFF_FFFF_C000_0000, 1'b0, "SRAW (sign-ext preserved)");

        $display("==============================================");
        if (errors == 0) begin
            $display("    ALL TESTS PASSED SUCCESSFULLY! (0 ERRORS) ");
        end else begin
            $display("    TESTS FINISHED WITH %0d ERROR(S)         ", errors);
        end
        $display("==============================================\n");

        $finish;
    end

endmodule