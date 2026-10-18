module instruction_mem #(
    parameter MEM_DEPTH = 65536 //256kb can be incresed
)
(
    input  wire [63:0] addr,      
    output wire [31:0] instruction
);
    localparam ADDR_BITS = $clog2(MEM_DEPTH); //here aadr_bits is 16 
    reg [31:0] mem [0:MEM_DEPTH-1];
    wire [ADDR_BITS-1:0] word_idx = addr[ADDR_BITS+1 : 2];

    //protection
    assign instruction = (addr < (MEM_DEPTH * 4)) ? mem[word_idx] : 32'h00000013; //addi x0,x0,0

    initial begin
        $readmemh("program.hex", mem);
    end

endmodule