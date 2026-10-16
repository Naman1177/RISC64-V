# Tools
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# Directories and Files
BUILD_DIR = build
TB_DIR    = tb
RTL_SRCS  = $(wildcard *.v)
TB_SRCS   = $(wildcard $(TB_DIR)/*.v)
SIM_BIN   = $(BUILD_DIR)/sim.out
VCD_FILE  = $(BUILD_DIR)/alu_waveform.vcd

.PHONY: all run clean

# Default target
all: run

run:
	@echo "===> Creating temporary build directory..."
	@mkdir -p $(BUILD_DIR)

	@echo "===> Compiling all source and testbench files..."
	@$(IVERILOG) -I . -o $(SIM_BIN) $(TB_SRCS) $(RTL_SRCS)

	@echo "===> Running simulation..."
	@cd $(BUILD_DIR) && $(VVP) sim.out

	@echo "===> Launching GTKWave (close GTKWave window to continue)..."
	@if [ -f $(VCD_FILE) ]; then \
		$(GTKWAVE) $(VCD_FILE); \
	else \
		echo "Warning: $(VCD_FILE) not found."; \
	fi

	@echo "===> Removing build directory and temporary files..."
	@rm -rf $(BUILD_DIR)
	@echo "===> Done!"

# Manual clean target if needed
clean:
	@rm -rf $(BUILD_DIR) *.vcd *.out