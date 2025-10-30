
# Uses Icarus Verilog and GTKWave

# Compiler and simulator
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files
RTL_SOURCES = rtl/arithmetic_core.v rtl/logic_unit.v rtl/flag_unit.v rtl/alu_4bit.v
TB_SOURCE = tb/tb_alu_4bit.v
ALL_SOURCES = $(RTL_SOURCES) $(TB_SOURCE)

# Output files
SIM_OUT = sim/alu_4bit.vvp
VCD_OUT = sim/alu_4bit.vcd

# Directories
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
DOC_DIR = docs

# Default target
all: compile simulate

# Create directories
dirs:
	@mkdir -p $(RTL_DIR) $(TB_DIR) $(SIM_DIR) $(DOC_DIR)

# Compile the design
compile: dirs
	@echo "Compiling Verilog sources..."
	$(IVERILOG) -o $(SIM_OUT) -s tb_alu_4bit $(ALL_SOURCES)
	@echo "Compilation complete."

# Run simulation
simulate: compile
	@echo "Running simulation..."
	cd $(SIM_DIR) && $(VVP) alu_4bit.vvp
	@echo "Simulation complete. VCD file generated."

# View waveforms
wave: simulate
	@echo "Opening GTKWave..."
	$(GTKWAVE) $(VCD_OUT) &

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f $(SIM_OUT) $(VCD_OUT)
	rm -f *.vcd *.vvp
	@echo "Clean complete."

# Clean everything including directories
distclean: clean
	@echo "Removing simulation directory..."
	rm -rf $(SIM_DIR)

# Help
help:
	@echo "4-bit ALU Makefile"
	@echo "=================="
	@echo "Targets:"
	@echo "  all       - Compile and simulate (default)"
	@echo "  compile   - Compile Verilog sources"
	@echo "  simulate  - Run simulation and generate VCD"
	@echo "  wave      - Open waveform in GTKWave"
	@echo "  clean     - Remove generated files"
	@echo "  distclean - Remove all generated files and directories"
	@echo "  help      - Show this help message"

.PHONY: all compile simulate wave clean distclean help dirs