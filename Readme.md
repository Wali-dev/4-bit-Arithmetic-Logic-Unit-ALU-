4-bit ALU Project
A compact, synthesizable 4-bit Arithmetic Logic Unit (ALU) implemented in Verilog HDL with comprehensive verification.

Project Overview
This ALU supports extended arithmetic and logical operations with full status flag generation:

Arithmetic Operations: ADD, SUB, INC, DEC, CMP (Compare)
Logical Operations: AND, OR, XOR, NOT, NAND, NOR, XNOR
Special Operations: PASS A (pass-through)
Status Flags: Zero (Z), Carry (C), Overflow (V), Negative (N)
Total Operations: 15 (with room for 1 reserved operation)
Directory Structure
4bit_alu/
├── rtl/
│   ├── alu_4bit.v          # Top-level ALU module
│   ├── arithmetic_core.v   # Arithmetic unit
│   ├── logic_unit.v        # Logic unit
│   └── flag_unit.v         # Flag generation unit
├── tb/
│   └── tb_alu_4bit.v       # Comprehensive testbench
├── sim/
│   ├── alu_4bit.vvp        # Compiled simulation (generated)
│   └── alu_4bit.vcd        # Waveform dump (generated)
├── docs/
│   └── (documentation files)
├── Makefile                # Build automation
└── README.md              # This file
Opcode Map
The ALU now uses a 4-bit opcode for 16 possible operations:

Opcode	Operation	Type	Description
0000	ADD	Arithmetic	A + B
0001	SUB	Arithmetic	A - B
0010	INC	Arithmetic	A + 1
0011	DEC	Arithmetic	A - 1
0100	CMP	Arithmetic	Compare A with B (A - B)
0101	RESERVED	-	Reserved for future use
0110	RESERVED	-	Reserved for future use
0111	RESERVED	-	Reserved for future use
1000	AND	Logic	A & B (bitwise AND)
1001	OR	Logic	A | B (bitwise OR)
1010	XOR	Logic	A ^ B (bitwise XOR)
1011	NOT	Logic	~A (bitwise NOT)
1100	NAND	Logic	~(A & B) (bitwise NAND)
1101	NOR	Logic	~(A | B) (bitwise NOR)
1110	XNOR	Logic	~(A ^ B) (bitwise XNOR)
1111	PASS A	Special	Pass A through unchanged
Note: The MSB of the opcode (bit 3) determines operation type:

0xxx = Arithmetic operations
1xxx = Logic operations
Status Flags
Zero (Z): Set when result is 0
Carry (C): Set on carry out (arithmetic operations only)
Overflow (V): Set on signed overflow (arithmetic operations only)
Negative (N): Set when MSB of result is 1 (sign bit)
Prerequisites
Icarus Verilog (iverilog): Verilog compiler and simulator
GTKWave: Waveform viewer
Make: Build automation tool
Installation on Linux
bash
# Debian/Ubuntu
sudo apt-get install iverilog gtkwave make

# Fedora/RHEL
sudo dnf install iverilog gtkwave make

# Arch Linux
sudo pacman -S iverilog gtkwave make
Quick Start
1. Set Up the Project Structure
bash
# Create the directory structure
mkdir -p 4bit_alu/{rtl,tb,sim,docs}
cd 4bit_alu

# Copy the Verilog files to appropriate directories
# - Copy arithmetic_core.v, logic_unit.v, flag_unit.v, alu_4bit.v to rtl/
# - Copy tb_alu_4bit.v to tb/
# - Copy Makefile and README.md to root directory
2. Compile and Simulate
bash
# Compile and run simulation in one step
make all

# Or run steps individually
make compile    # Compile Verilog sources
make simulate   # Run simulation and generate VCD
3. View Waveforms
bash
# Open waveform viewer
make wave

# Or manually
gtkwave sim/alu_4bit.vcd
4. Clean Up
bash
make clean      # Remove generated files
make distclean  # Remove generated files and sim directory
Viewing Waveforms in GTKWave
When GTKWave opens:

In the left panel (SST), expand the hierarchy: tb_alu_4bit → dut
Select signals you want to view:
Input signals: A, B, opcode
Output signals: result, zero, carry, overflow, negative
Drag and drop selected signals to the waveform viewer (Signals panel)
Use zoom controls to adjust time scale
Click on signal names to change display format (binary, hex, decimal, unsigned)
Recommended Signal Groups
Group 1 - Inputs:

A[3:0]
B[3:0]
opcode[2:0]
Group 2 - Outputs:

result[3:0]
zero
carry
overflow
negative
Testbench Details
The testbench (tb_alu_4bit.v) includes:

Directed Tests
ADD: Basic addition, overflow cases (7+1), carry cases (15+1)
SUB: Basic subtraction, overflow cases (-8-1), borrow cases
INC: Increment with overflow detection
DEC: Decrement with overflow detection
CMP: Compare operation for equality and magnitude checks
AND/OR/XOR/NOT: Basic logic operations with zero flag testing
NAND/NOR/XNOR: Extended logic operations
PASS A: Pass-through operation
Randomized Tests
50 random test vectors covering all 15 operations
Helps uncover corner cases not covered by directed tests
Critical Test Cases
Overflow Detection:

7 + 1 = 8    (0111 + 0001 = 1000)  → Overflow set
-8 - 1 = 7   (1000 - 0001 = 0111)  → Overflow set
Carry Detection:

15 + 1 = 0   (1111 + 0001 = 0000)  → Carry set
3 - 5 = -2   (0011 - 0101 = 1110)  → Borrow set
Module Descriptions
alu_4bit (Top-level)
Integrates all sub-modules
Implements result multiplexing based on operation type
Manages arithmetic/logic operation selection
arithmetic_core
Implements ADD, SUB, INC, DEC, CMP operations
Generates carry and overflow flags
Uses two's complement arithmetic
CMP operation sets flags without storing result
logic_unit
Implements AND, OR, XOR, NOT, NAND, NOR, XNOR operations
Pure combinational logic
No flag generation (handled by flag_unit)
Complete set of 2-input logic gates
flag_unit
Generates Zero (Z), Carry (C), Overflow (V), Negative (N) flags
Carry and overflow only valid for arithmetic operations
Zero and negative flags valid for all operations
Design Features
Parameterized: WIDTH parameter allows easy scaling (default = 4)
Modular: Clean separation of arithmetic, logic, and flag generation
Synthesizable: No simulation-only constructs in RTL modules
Verified: Comprehensive testbench with directed and random tests
Synthesis Notes
This design is fully synthesizable for FPGA or ASIC targets:

bash
# Example for Xilinx (if you have Vivado)
# vivado -mode batch -source synthesis_script.tcl

# Example for Intel/Altera (if you have Quartus)
# quartus_sh --flow compile alu_4bit
Expected resource usage (4-bit implementation with extended operations):

~30-40 LUTs (increased from basic version)
~10-15 registers (for testbench)
Maximum frequency: >100 MHz on modern FPGAs
Troubleshooting
Simulation doesn't run
bash
# Check if iverilog is installed
which iverilog

# Verify file paths
ls -R rtl/ tb/

# Try manual compilation
iverilog -o sim/alu_4bit.vvp -s tb_alu_4bit rtl/*.v tb/tb_alu_4bit.v
No waveform in GTKWave
bash
# Verify VCD file was created
ls -lh sim/alu_4bit.vcd

# Check simulation output for errors
vvp sim/alu_4bit.vvp
Make command not found
bash
# Install make
sudo apt-get install make  # Debian/Ubuntu
sudo dnf install make      # Fedora/RHEL
Educational Outcomes
This project demonstrates:

RTL coding practices and modular design
Two's complement arithmetic and overflow detection
Verification methodologies (directed + randomized testing)
Simulation and waveform analysis
Basic synthesis concepts
Future Enhancements
Possible extensions for advanced learning:

Add shift operations (SHL, SHR, SAR, ROL, ROR) - use remaining 3 opcodes
Implement pipelining for higher frequency
Add conditional branch support with condition codes
Scale to 8-bit or 16-bit width
Add multiply/divide operations
Implement as part of a simple CPU datapath
Add carry-in for multi-precision arithmetic
License
This is an educational project. Feel free to use and modify for learning purposes.

Contact & Support
For questions or issues with the code, refer to the project documentation or HDL simulation logs.

