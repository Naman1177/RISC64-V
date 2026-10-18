`timescale 1ns / 1ps
`include "opcode.v"

module tb_imm_gen;

    reg  [31:0] instruction;
    wire [63:0] immediate;
    integer     errors;

    // Instantiate your imm_gen (ports match imm_gen.v)
    imm_gen dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    task check;
        input [63:0]  expected;
        input [127:0] format_name;
        begin
            #1;
            if (immediate !== expected) begin
                $display("[-] FAIL: %0s | inst=0x%h", format_name, instruction);
                $display("    Expected: 0x%h", expected);
                $display("    Got:      0x%h", immediate);
                errors = errors + 1;
            end else begin
                $display("[+] PASS: %0s | immediate=0x%h", format_name, immediate);
            end
        end
    endtask

    initial begin
        $dumpfile("imm_gen_waveform.vcd");
        $dumpvars(0, tb_imm_gen);
        errors = 0;

        $display("\n==============================================");
        $display("        RUNNING IMM_GEN TESTBENCH             ");
        $display("==============================================");

        // 1. I-type Positive: addi x5, x1, +15 (imm = 0x00F)
        instruction = 32'h00F08293;
        check(64'h0000_0000_0000_000F, "I-Type (+15)");

        // 2. I-type Negative: addi x5, x1, -1 (imm = 0xFFF -> sign-extended)
        instruction = 32'hFFF08293;
        check(64'hFFFF_FFFF_FFFF_FFFF, "I-Type (-1 sign-extended)");

        // 3. S-type: sd x2, 8(x1) -> imm = 8
        instruction = 32'h0020BA23;
        check(64'h0000_0000_0000_0008, "S-Type (+8 store offset)");

        // 4. B-type: beq x1, x2, offset (-4)
        instruction = 32'hFE208EE3;
        check(64'hFFFF_FFFF_FFFF_FFFC, "B-Type (-4 branch offset)");

        // 5. U-type: lui x5, 0x12345 (imm = 0x12345000)
        instruction = 32'h123452B7;
        check(64'h0000_0000_1234_5000, "U-Type (LUI 0x12345)");

        // 6. J-type: jal x1, +16
        instruction = 32'h010000EF;
        check(64'h0000_0000_0000_0010, "J-Type (JAL +16 jump offset)");

        // 7. R-type: add x3, x1, x2 (has NO immediate, must output 0)
        instruction = 32'h002081B3;
        check(64'd0, "R-Type (No immediate = 0)");

        $display("==============================================");
        if (errors == 0) $display("    ALL IMM_GEN TESTS PASSED! (0 ERRORS)");
        else             $display("    IMM_GEN FAILED WITH %0d ERROR(S)", errors);
        $display("==============================================\n");

        $finish;
    end

endmodule