IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave
BUILD_DIR = build
TB_DIR   = tb
IFLAGS   = -I .

.PHONY: all alu regfile imm clean

all: alu regfile imm instruction_mem control_unit

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)


alu: $(BUILD_DIR)
	@echo "===> Simulating ALU..."
	@$(IVERILOG) $(IFLAGS) -o $(BUILD_DIR)/alu_sim $(TB_DIR)/tb_alu.v alu64.v
	@cd $(BUILD_DIR) && $(VVP) alu_sim
	@$(GTKWAVE) $(BUILD_DIR)/alu_waveform.vcd &
	

regfile: $(BUILD_DIR)
	@echo "===> Simulating Regfile..."
	@$(IVERILOG) $(IFLAGS) -o $(BUILD_DIR)/regfile_sim $(TB_DIR)/tb_regfile.v regfile.v
	@cd $(BUILD_DIR) && $(VVP) regfile_sim
	@$(GTKWAVE) $(BUILD_DIR)/regfile_waveform.vcd &
	

imm: $(BUILD_DIR)
	@echo "===> Simulating Immediate Generator..."
	@$(IVERILOG) $(IFLAGS) -o $(BUILD_DIR)/imm_sim $(TB_DIR)/tb_imm_gen.v imm_gen.v
	@cd $(BUILD_DIR) && $(VVP) imm_sim
	@$(GTKWAVE) $(BUILD_DIR)/imm_gen_waveform.vcd &

instruction_mem: $(BUILD_DIR)
	@echo "===> Simulating Instruction Memory..."
	@cp program.hex $(BUILD_DIR)/
	@$(IVERILOG) $(IFLAGS) -o $(BUILD_DIR)/instruction_mem_sim $(TB_DIR)/tb_instruction_mem.v instruction_mem.v
	@cd $(BUILD_DIR) && $(VVP) instruction_mem_sim
	@$(GTKWAVE) $(BUILD_DIR)/instruction_mem_waveform.vcd &

control_unit: $(BUILD_DIR)
	@echo "===> Simulating Control Unit..."
	@$(IVERILOG) $(IFLAGS) -o $(BUILD_DIR)/control_unit_sim $(TB_DIR)/tb_control_unit.v control_unit.v
	@cd $(BUILD_DIR) && $(VVP) control_unit_sim
	@$(GTKWAVE) $(BUILD_DIR)/control_unit_waveform.vcd &

clean:
	@rm -rf $(BUILD_DIR) *.vcd