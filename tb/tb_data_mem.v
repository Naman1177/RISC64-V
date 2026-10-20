`timescale 1ns / 1ps

module tb_data_mem;

    parameter MEM_SIZE = 16384;   // 16 KB

    reg         clk;
    reg         mem_read;
    reg         mem_write;
    reg  [2:0]  funct3;
    reg  [63:0] addr;
    reg  [63:0] write_data;
    wire [63:0] read_data;

    integer errors;

    data_mem #(.MEM_SIZE(MEM_SIZE)) uut (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .funct3     (funct3),
        .addr       (addr),
        .write_data (write_data),
        .read_data  (read_data)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Watchdog: abort if the simulation ever hangs
    initial begin
        #5000;
        $display("[-] TIMEOUT: simulation did not finish");
        $finish;
    end

    // Store: inputs change on negedge, write is captured on the posedge in between
    task store;
        input [2:0]  f3;
        input [63:0] a;
        input [63:0] d;
        begin
            @(negedge clk);
            mem_read   = 0;
            addr       = a;
            write_data = d;
            funct3     = f3;
            mem_write  = 1;
            @(negedge clk);
            mem_write  = 0;
        end
    endtask

    // Load and compare (combinational read, small delay to settle)
    task load_check;
        input [2:0]      f3;
        input [63:0]     a;
        input [64*8-1:0] name;
        input [63:0]     expected;
        begin
            mem_read = 1;
            funct3   = f3;
            addr     = a;
            #1;
            if (read_data !== expected) begin
                $display("[-] FAIL: %0s | Expected: 0x%016h | Got: 0x%016h", name, expected, read_data);
                errors = errors + 1;
            end else begin
                $display("[+] PASS: %0s | Got: 0x%016h", name, read_data);
            end
            mem_read = 0;
        end
    endtask

    initial begin
        $dumpfile("data_mem_waveform.vcd");
        $dumpvars(0, tb_data_mem);

        mem_read   = 0;
        mem_write  = 0;
        funct3     = 3'b000;
        addr       = 64'd0;
        write_data = 64'd0;
        errors     = 0;

        $display("\n==================================================================");
        $display("          RUNNING DATA MEMORY TESTBENCH (LOAD/STORE)              ");
        $display("==================================================================");

        #12;

        // Test 1: SB, LB, LBU
        store(3'b000, 64'h10, 64'hFE);
        load_check(3'b000, 64'h10, "LB  (Signed Byte 0xFE)",        64'hFFFFFFFF_FFFFFFFE);
        load_check(3'b100, 64'h10, "LBU (Unsigned Byte 0xFE)",      64'h00000000_000000FE);

        // Test 2: SH, LH, LHU
        store(3'b001, 64'h20, 64'h8ABC);
        load_check(3'b001, 64'h20, "LH  (Signed Halfword 0x8ABC)",  64'hFFFFFFFF_FFFF8ABC);
        load_check(3'b101, 64'h20, "LHU (Unsigned Halfword 0x8ABC)",64'h00000000_00008ABC);

        // Test 3: SW, LW, LWU
        store(3'b010, 64'h30, 64'h89ABCDEF);
        load_check(3'b010, 64'h30, "LW  (Signed Word 0x89ABCDEF)",  64'hFFFFFFFF_89ABCDEF);
        load_check(3'b110, 64'h30, "LWU (Unsigned Word 0x89ABCDEF)",64'h00000000_89ABCDEF);

        // Test 4: SD, LD
        store(3'b011, 64'h40, 64'h01234567_89ABCDEF);
        load_check(3'b011, 64'h40, "LD  (64-bit Doubleword)",       64'h01234567_89ABCDEF);

        // Test 5: little-endian byte layout
        load_check(3'b100, 64'h40, "Byte 0 Little-Endian (0xEF)",   64'h00000000_000000EF);
        load_check(3'b100, 64'h47, "Byte 7 Little-Endian (0x01)",   64'h00000000_00000001);

        $display("==================================================================");
        if (errors == 0)
            $display("              ALL DATA MEMORY TESTS PASSED! (0 ERRORS)            ");
        else
            $display("              DATA MEMORY TESTS FAILED WITH %0d ERROR(S)          ", errors);
        $display("==================================================================\n");

        #10;
        $finish;
    end

endmodule