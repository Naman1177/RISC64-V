`timescale 1ns / 1ps

module tb_regfile;

    reg         clk;
    reg         reset;
    reg         write_en;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [63:0] rd_data;
    reg         shadow_mode;

    wire [63:0] rs1_data, rs2_data;
    integer     errors;

    // Instantiate your regfile (ports match regfile.v)
    regfile dut (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .shadow_mode(shadow_mode)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile_waveform.vcd");
        $dumpvars(0, tb_regfile);

        clk = 0;
        reset = 1;
        write_en = 0;
        shadow_mode = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 64'd0;
        errors = 0;

        #15 reset = 0;
        #10;

        $display("\n==============================================");
        $display("         RUNNING REGFILE TESTBENCH            ");
        $display("==============================================");

        // Test 1: Write to x1 and x2
        @(posedge clk);
        write_en = 1; rd_addr = 5'd1; rd_data = 64'h1111_2222_3333_4444;
        @(posedge clk);
        write_en = 1; rd_addr = 5'd2; rd_data = 64'h5555_6666_7777_8888;
        @(posedge clk);
        write_en = 0;

        // Verify concurrent dual read
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #1;
        if (rs1_data !== 64'h1111_2222_3333_4444 || rs2_data !== 64'h5555_6666_7777_8888) begin
            $display("[-] FAIL: Concurrent read x1/x2 mismatch");
            errors = errors + 1;
        end else begin
            $display("[+] PASS: Concurrent Read of x1 and x2 Verified");
        end

        // Test 2: x0 Immutability (Attempt to write to x0)
        @(posedge clk);
        write_en = 1; rd_addr = 5'd0; rd_data = 64'hFFFF_FFFF_FFFF_FFFF;
        @(posedge clk);
        write_en = 0;

        rs1_addr = 5'd0;
        #1;
        if (rs1_data !== 64'd0) begin
            $display("[-] FAIL: Register x0 was modified to 0x%h!", rs1_data);
            errors = errors + 1;
        end else begin
            $display("[+] PASS: x0 Hardwired to Zero Verified (reads 0x0)");
        end

        // Test 3: Same-Cycle RAW (Read-After-Write) Bypass
        @(posedge clk);
        write_en = 1; rd_addr = 5'd5; rd_data = 64'hDEAD_BEEF_CAFE_BABE;
        rs1_addr = 5'd5; // Read in same cycle before clock latch
        #1;
        if (rs1_data !== 64'hDEAD_BEEF_CAFE_BABE) begin
            $display("[-] FAIL: RAW Forwarding / Bypass failed on x5");
            errors = errors + 1;
        end else begin
            $display("[+] PASS: Same-Cycle RAW Bypass Verified (Forwarded 0x%h)", rs1_data);
        end
        @(posedge clk);
        write_en = 0;

        // Test 4: Reset check
        #10 reset = 1; #10 reset = 0;
        rs1_addr = 5'd1;
        #1;
        if (rs1_data !== 64'd0) begin
            $display("[-] FAIL: Reset failed to clear registers");
            errors = errors + 1;
        end else begin
            $display("[+] PASS: Asynchronous Reset Array Clear Verified");
        end

        $display("==============================================");
        if (errors == 0) $display("    ALL REGFILE TESTS PASSED! (0 ERRORS)");
        else             $display("    REGFILE FAILED WITH %0d ERROR(S)", errors);
        $display("==============================================\n");

        $finish;
    end

endmodule