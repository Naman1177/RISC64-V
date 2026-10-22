`timescale 1ns / 1ps

module tb_riscv_core_top;

    // Testbench signals
    reg clk;
    reg reset;

    // Debug wires exposed by riscv_core_top
    wire [63:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [63:0] debug_alu_out;
    wire [63:0] debug_write_data;
    wire        debug_reg_write;
    wire        debug_cpu_stop;

    // Instantiate the Unit Under Test (UUT)
    riscv_core_top uut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_out(debug_alu_out),
        .debug_write_data(debug_write_data),
        .debug_reg_write(debug_reg_write),
        .debug_cpu_stop(debug_cpu_stop)
    );

    // 100 MHz Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, tb_riscv_core_top);

        // Initialize and Reset
        clk = 0;
        reset = 1;

        // Load the provided test sequence into instruction memory.
        // NOTE: Verify that "mem" matches the internal array name inside your instruction_mem module.
        //$readmemh("program.hex", uut.u_imem.mem);

        // Hold reset for a few cycles, then release
        #25 reset = 0;

        // Failsafe timeout
        #50000;
        $display("Simulation timeout reached.");
        $finish;
    end

    // Monitor logic to determine test completion
    always @(posedge clk) begin
        if (!reset) begin
            // Halt condition 1: The CPU asserts debug_cpu_stop due to misaligned PC or illegal instruction
            if (debug_cpu_stop) begin
                $display("Simulation Halted: CPU triggered debug_cpu_stop at PC = %h", debug_pc);
                $finish;
            end

            // Halt condition 2: The test suite ends in a terminal infinite loop "jal x0, 0"
            // "jal x0, 0" translates to machine code 32'h0000006f[cite: 3]
            if (debug_instruction == 32'h0000006f) begin
                $display("Simulation Complete: Reached terminal loop (jal x0, 0) at PC = %h", debug_pc);
                $finish;
            end
        end
    end

endmodule