
module hazard_unit (
    input  wire [4:0]  id_ex_rs1,          
    input  wire [4:0]  id_ex_rs2,           
    input  wire [4:0]  ex_mem_rd,           
    input  wire        ex_mem_reg_write,    
    input  wire [4:0]  mem_wb_rd,           
    input  wire        mem_wb_reg_write,    

    input  wire        id_ex_mem_read,   
    input  wire [4:0]  id_ex_rd,            
    input  wire [4:0]  if_id_rs1,           
    input  wire [4:0]  if_id_rs2,          

    input  wire        branch_or_jump_taken,//high if branch or jump is taken

    output reg  [1:0]  forward_a,           //00 - register value, 01 - MEM/WB, 10 - EX/MEM
    output reg  [1:0]  forward_b,           //00 - register value, 01 - MEM/WB, 10 - EX/MEM
    output wire        pc_write,            //high to allow PC update, low to stall
    output wire        if_id_write,         //high to allow IF/ID update, low to stall
    output wire        if_id_flush,         //high to flush IF/ID register
    output wire        id_ex_flush          //high to flush ID/EX register 
);

    // 1 for alu 
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10; 
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01; 
        end else begin
            forward_a = 2'b00; 
        end

        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01; 
        end else begin
            forward_b = 2'b00; 
        end
    end

    // 2 when instruction in EX stage is a load and instruction in ID stage needs its result 
    wire load_use_hazard = id_ex_mem_read && 
                           ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) && 
                           (id_ex_rd != 5'd0);

    assign pc_write    = !load_use_hazard;
    assign if_id_write = !load_use_hazard;

    // Flush logic for branch/jump and load-use hazards

    assign if_id_flush = branch_or_jump_taken;
    assign id_ex_flush = load_use_hazard || branch_or_jump_taken;

endmodule