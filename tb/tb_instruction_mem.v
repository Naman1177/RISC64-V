`timescale 1ns / 1ps

module tb_instruction_mem;

    // Parameters matching instruction_mem.v
    parameter MEM_DEPTH = 65536;

    // Testbench signals
    reg  [63:0] tb_addr;
    wire [31:0] tb_instruction;

    integer i;

    // Instantiate the Unit Under Test (UUT)
    instruction_mem #(
        .MEM_DEPTH(MEM_DEPTH)
    ) uut (
        .addr        (tb_addr),
        .instruction (tb_instruction)
    );

    initial begin
        // Setup simulation dump file for waveform viewing (GTKWave)
        $dumpfile("instruction_mem_waveform.vcd");
        $dumpvars(0, tb_instruction_mem);

        $display("==================================================================");
        $display("   TESTBENCH: Instruction Memory Verification with program.hex    ");
        $display("==================================================================");

        tb_addr = 64'd0;
        #5;

        // 1. Sequentially read the first 30 instructions (Byte addresses: 0, 4, 8, 12, ...)
        $display("\n--- Step 1: Testing Sequential Program Reads (30 Instructions) ---");
        for (i = 0; i < 30; i = i + 1) begin
            tb_addr = i * 4; // Step by 4 bytes per instruction
            #5;              // Wait for combinational logic propagation
            $display("[Time %0t ns] Byte Addr: 0x%08h | Word Index: %02d | Hex Code: 0x%08h", 
                     $time, tb_addr, uut.word_idx, tb_instruction);
        end

        // 2. Test unaligned PC / byte offset behavior (Should slice addr[17:2] ignoring bottom 2 bits)
        $display("\n--- Step 2: Testing Address Slicing (Byte Offsets within Word 0) ---");
        tb_addr = 64'h00000000_00000000; #5;
        $display("Addr 0x0 -> Instruction: 0x%08h (Word idx: %0d)", tb_instruction, uut.word_idx);
        tb_addr = 64'h00000000_00000001; #5;
        $display("Addr 0x1 -> Instruction: 0x%08h (Word idx: %0d)", tb_instruction, uut.word_idx);
        tb_addr = 64'h00000000_00000002; #5;
        $display("Addr 0x2 -> Instruction: 0x%08h (Word idx: %0d)", tb_instruction, uut.word_idx);
        tb_addr = 64'h00000000_00000003; #5;
        $display("Addr 0x3 -> Instruction: 0x%08h (Word idx: %0d)", tb_instruction, uut.word_idx);

        // 3. Test Out-of-Bounds Memory Protection (Must return NOP: 32'h00000013)
        $display("\n--- Step 3: Testing Out-of-Bounds Protection (Expect NOP: 0x00000013) ---");
        // MEM_DEPTH * 4 = 65536 * 4 = 262144 bytes = 0x00040000
        tb_addr = 64'h00000000_00040000; // Exact boundary limit
        #5;
        $display("Addr at Limit (0x00040000) -> Instruction: 0x%08h", tb_instruction);
        if (tb_instruction === 32'h00000013)
            $display("[PASS] Correctly defaulted to NOP on boundary limit!");
        else
            $display("[FAIL] Did not return NOP on boundary limit!");

        tb_addr = 64'h00000000_FFFF0000; // Far out-of-bounds address
        #5;
        $display("Addr Far Out (0xFFFF0000)   -> Instruction: 0x%08h", tb_instruction);
        if (tb_instruction === 32'h00000013)
            $display("[PASS] Correctly defaulted to NOP on out-of-bounds address!");
        else
            $display("[FAIL] Did not return NOP on out-of-bounds address!");

        $display("\n==================================================================");
        $display("                    ALL MEMORY TESTS COMPLETED                    ");
        $display("==================================================================");
        #10;
        $finish;
    end

endmodule