`timescale 1ns / 1ps

module data_mem #(
    parameter MEM_SIZE = 65536  // 64 KB Data Memory
)(
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [63:0] addr,
    input  wire [63:0] write_data,
    output reg  [63:0] read_data
);

    localparam ADDR_WIDTH = $clog2(MEM_SIZE);   // 14 

    reg [7:0] mem [0:MEM_SIZE-1];

    wire [ADDR_WIDTH-1:0] a0 = addr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] a1 = a0 + 1'b1;
    wire [ADDR_WIDTH-1:0] a2 = a0 + 2'd2;
    wire [ADDR_WIDTH-1:0] a3 = a0 + 2'd3;
    wire [ADDR_WIDTH-1:0] a4 = a0 + 3'd4;
    wire [ADDR_WIDTH-1:0] a5 = a0 + 3'd5;
    wire [ADDR_WIDTH-1:0] a6 = a0 + 3'd6;
    wire [ADDR_WIDTH-1:0] a7 = a0 + 3'd7;

    integer idx;
    initial begin
        for (idx = 0; idx < MEM_SIZE; idx = idx + 1)
            mem[idx] = 8'd0;
    end

  //l
    always @(*) begin
        read_data = 64'd0;
        if (mem_read) begin
            case (funct3)
                3'b000: read_data = {{56{mem[a0][7]}}, mem[a0]};                              // LB
                3'b001: read_data = {{48{mem[a1][7]}}, mem[a1], mem[a0]};                     // LH
                3'b010: read_data = {{32{mem[a3][7]}}, mem[a3], mem[a2], mem[a1], mem[a0]};   // LW
                3'b011: read_data = {mem[a7], mem[a6], mem[a5], mem[a4],
                                     mem[a3], mem[a2], mem[a1], mem[a0]};                     // LD
                3'b100: read_data = {56'd0, mem[a0]};                                         // LBU
                3'b101: read_data = {48'd0, mem[a1], mem[a0]};                                // LHU
                3'b110: read_data = {32'd0, mem[a3], mem[a2], mem[a1], mem[a0]};              // LWU
                default: read_data = 64'd0;
            endcase
        end
    end

   //s
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                3'b000: begin                                   // SB
                    mem[a0] <= write_data[7:0];
                end
                3'b001: begin                                   // SH
                    mem[a0] <= write_data[7:0];
                    mem[a1] <= write_data[15:8];
                end
                3'b010: begin                                   // SW
                    mem[a0] <= write_data[7:0];
                    mem[a1] <= write_data[15:8];
                    mem[a2] <= write_data[23:16];
                    mem[a3] <= write_data[31:24];
                end
                3'b011: begin                                   // SD
                    mem[a0] <= write_data[7:0];
                    mem[a1] <= write_data[15:8];
                    mem[a2] <= write_data[23:16];
                    mem[a3] <= write_data[31:24];
                    mem[a4] <= write_data[39:32];
                    mem[a5] <= write_data[47:40];
                    mem[a6] <= write_data[55:48];
                    mem[a7] <= write_data[63:56];
                end
                default: ;
            endcase
        end
    end

endmodule