`timescale 1ns / 1ps
`include "opcode.v"

module tb_alu;

    reg  [63:0] a;
    reg  [63:0] b;
    reg  [4:0]  ctrl;
    wire [63:0] out;
    wire        zero;
    integer     errors;

    alu64 dut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .out(out),
        .zero(zero)
    );

    task check;
        input [63:0]  expected_out;
        input         expected_zero;
        input [127:0] op_name;
        begin
            #1;
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
        $dumpfile("alu_waveform.vcd");
        $dumpvars(0, tb_alu);
        errors = 0;

        $display("\n==============================================");
        $display("          RUNNING ALU64 TESTBENCH             ");
        $display("==============================================");

        // 1. ADD
        a = 64'd45; b = 64'd15; ctrl = `ALU_ADD;
        check(64'd60, 1'b0, "ADD");

        // 2. SUB & Zero Flag
        a = 64'hFACE_1234_5678_9ABC; b = 64'hFACE_1234_5678_9ABC; ctrl = `ALU_SUB;
        check(64'd0, 1'b1, "SUB (zero flag set)");

        // 3. AND, OR, XOR
        a = 64'hF0F0_AAAA_1234_5678; b = 64'h0F0F_FFFF_0000_FFFF; ctrl = `ALU_AND;
        check(64'h0000_AAAA_0000_5678, 1'b0, "AND");

        a = 64'hF000_0000_0000_0000; b = 64'h0000_0000_0000_000F; ctrl = `ALU_OR;
        check(64'hF000_0000_0000_000F, 1'b0, "OR");

        a = 64'hFFFF_0000_AAAA_5555; b = 64'hFFFF_FFFF_5555_AAAA; ctrl = `ALU_XOR;
        check(64'h0000_FFFF_FFFF_FFFF, 1'b0, "XOR");

        // 4. Comparisons (SLT signed vs SLTU unsigned)
        a = -64'sd10; b = 64'sd5; ctrl = `ALU_SLT;
        check(64'd1, 1'b0, "SLT (-10 < 5 is true)");

        a = -64'sd10; b = 64'sd5; ctrl = `ALU_SLTU;
        check(64'd0, 1'b1, "SLTU (0xFF...F6 < 5 is false)");

        // 5. 64-bit Shifts (SLL, SRL, SRA)
        a = 64'd1; b = 64'd4; ctrl = `ALU_SLL;
        check(64'h0000_0000_0000_0010, 1'b0, "SLL (1 << 4)");

        a = 64'h8000_0000_0000_0000; b = 64'd1; ctrl = `ALU_SRL;
        check(64'h4000_0000_0000_0000, 1'b0, "SRL (0x80.. >> 1)");

        a = 64'h8000_0000_0000_0000; b = 64'd1; ctrl = `ALU_SRA;
        check(64'hC000_0000_0000_0000, 1'b0, "SRA (0x80.. >>> 1, sign preserved)");

        // 6. Multiplication
        a = 64'd13; b = 64'd7; ctrl = `ALU_MUL;
        check(64'd91, 1'b0, "MUL (13 * 7)");

        // 7. 32-bit Word (*W) Operations with Sign Extension
        a = 64'h0000_0000_7FFF_FFFF; b = 64'h0000_0000_0000_0001; ctrl = `ALU_ADDW;
        check(64'hFFFF_FFFF_8000_0000, 1'b0, "ADDW (0x7FFF_FFFF + 1 -> sign ext)");

        a = 64'd10; b = 64'd20; ctrl = `ALU_SUBW;
        check(64'hFFFF_FFFF_FFFF_FFF6, 1'b0, "SUBW (10 - 20 = -10 -> sign ext)");

        a = 64'h0000_0000_0000_0001; b = 64'd31; ctrl = `ALU_SLLW;
        check(64'hFFFF_FFFF_8000_0000, 1'b0, "SLLW (bit 31 replicated)");

        a = 64'h0000_0000_0000_0080; b = 64'd3; ctrl = `ALU_SRLW;
        check(64'h0000_0000_0000_0010, 1'b0, "SRLW (0x80 >> 3)");

        a = 64'h0000_0000_8000_0000; b = 64'd1; ctrl = `ALU_SRAW;
        check(64'hFFFF_FFFF_C000_0000, 1'b0, "SRAW (sign bit replicated)");

        $display("==============================================");
        if (errors == 0) $display("    ALL ALU TESTS PASSED! (0 ERRORS)");
        else             $display("    ALU FAILED WITH %0d ERROR(S)", errors);
        $display("==============================================\n");

        $finish;
    end

endmodule