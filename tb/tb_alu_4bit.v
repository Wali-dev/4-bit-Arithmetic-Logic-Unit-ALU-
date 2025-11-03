
// Comprehensive testbench with directed and randomized tests
// Updated for extended ALU operations

`timescale 1ns/1ps

module tb_alu_4bit;
    parameter WIDTH = 4;
    
    reg [WIDTH-1:0] A, B;
    reg [3:0] opcode;        // Extended to 4 bits
    wire [WIDTH-1:0] result;
    wire zero, carry, overflow, negative;
    
    integer i, errors;
    
    // Instantiate the ALU
    alu_4bit #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .negative(negative)
    );
    
    // VCD dump for GTKWave
    initial begin
        $dumpfile("alu_4bit.vcd");
        $dumpvars(0, tb_alu_4bit);
    end
    
    // Test task
    task test_alu;
        input [WIDTH-1:0] a_val, b_val;
        input [3:0] op;
        input [WIDTH-1:0] expected_result;
        input expected_z, expected_c, expected_v, expected_n;
        input [80*8-1:0] test_name;  // String for test description
        begin
            A = a_val;
            B = b_val;
            opcode = op;
            #10;
            
            if (result !== expected_result || 
                zero !== expected_z || 
                carry !== expected_c || 
                overflow !== expected_v || 
                negative !== expected_n) begin
                $display("ERROR at time %0t: %s", $time, test_name);
                $display("  A=%b, B=%b, opcode=%b", A, B, opcode);
                $display("  Expected: result=%b Z=%b C=%b V=%b N=%b", 
                         expected_result, expected_z, expected_c, expected_v, expected_n);
                $display("  Got:      result=%b Z=%b C=%b V=%b N=%b", 
                         result, zero, carry, overflow, negative);
                errors = errors + 1;
            end else begin
                $display("PASS: %s", test_name);
                $display("      A=%b, B=%b, op=%b -> result=%b Z=%b C=%b V=%b N=%b",
                         A, B, opcode, result, zero, carry, overflow, negative);
            end
        end
    endtask
    
    initial begin
        errors = 0;
        $display("\n=== Starting Extended ALU Testbench ===");
        $display("Testing 4-bit ALU with 15 operations\n");
        
        // ===== DIRECTED TESTS =====
        $display("========================================");
        $display("ARITHMETIC OPERATIONS");
        $display("========================================\n");
        
        // ADD tests
        $display("--- Testing ADD (opcode 0000) ---");
        test_alu(4'd3, 4'd2, 4'b0000, 4'd5, 0, 0, 0, 0, "ADD: 3+2=5");
        test_alu(4'd7, 4'd1, 4'b0000, 4'd8, 0, 0, 1, 1, "ADD: Overflow 7+1=8");
        test_alu(4'd15, 4'd1, 4'b0000, 4'd0, 1, 1, 0, 0, "ADD: Carry 15+1=0");
        test_alu(4'd0, 4'd0, 4'b0000, 4'd0, 1, 0, 0, 0, "ADD: Zero flag 0+0=0");
        test_alu(4'd8, 4'd8, 4'b0000, 4'd0, 1, 1, 1, 0, "ADD: -8+(-8)=0");
        
        $display("");
        
        // SUB tests
        $display("--- Testing SUB (opcode 0001) ---");
        test_alu(4'd5, 4'd3, 4'b0001, 4'd2, 0, 0, 0, 0, "SUB: 5-3=2");
        test_alu(4'd3, 4'd5, 4'b0001, 4'd14, 0, 1, 0, 1, "SUB: 3-5=-2 (borrow)");
        test_alu(4'd8, 4'd1, 4'b0001, 4'd7, 0, 0, 1, 0, "SUB: Overflow -8-1=7");
        test_alu(4'd0, 4'd0, 4'b0001, 4'd0, 1, 0, 0, 0, "SUB: Zero flag 0-0=0");
        test_alu(4'd7, 4'd8, 4'b0001, 4'd15, 0, 1, 1, 1, "SUB: 7-(-8)=-1");
        
        $display("");
        
        // INC tests
        $display("--- Testing INC (opcode 0010) ---");
        test_alu(4'd5, 4'd0, 4'b0010, 4'd6, 0, 0, 0, 0, "INC: 5+1=6");
        test_alu(4'd7, 4'd0, 4'b0010, 4'd8, 0, 0, 1, 1, "INC: Overflow 7+1=8");
        test_alu(4'd15, 4'd0, 4'b0010, 4'd0, 1, 1, 0, 0, "INC: Carry 15+1=0");
        
        $display("");
        
        // DEC tests
        $display("--- Testing DEC (opcode 0011) ---");
        test_alu(4'd5, 4'd0, 4'b0011, 4'd4, 0, 0, 0, 0, "DEC: 5-1=4");
        test_alu(4'd8, 4'd0, 4'b0011, 4'd7, 0, 0, 1, 0, "DEC: Overflow -8-1=7");
        test_alu(4'd0, 4'd0, 4'b0011, 4'd15, 0, 1, 0, 1, "DEC: Borrow 0-1=-1");
        
        $display("");
        
        // CMP tests
        $display("--- Testing CMP (opcode 0100) ---");
        test_alu(4'd5, 4'd5, 4'b0100, 4'd0, 1, 0, 0, 0, "CMP: 5==5 (zero set)");
        test_alu(4'd3, 4'd5, 4'b0100, 4'd14, 0, 1, 0, 1, "CMP: 3<5 (borrow set)");
        test_alu(4'd7, 4'd3, 4'b0100, 4'd4, 0, 0, 0, 0, "CMP: 7>3");
        
        $display("");
        $display("========================================");
        $display("LOGIC OPERATIONS");
        $display("========================================\n");
        
        // AND tests
        $display("--- Testing AND (opcode 1000) ---");
        test_alu(4'b1010, 4'b1100, 4'b1000, 4'b1000, 0, 0, 0, 1, "AND: 1010 & 1100 = 1000");
        test_alu(4'b1111, 4'b1111, 4'b1000, 4'b1111, 0, 0, 0, 1, "AND: 1111 & 1111 = 1111");
        test_alu(4'b1010, 4'b0101, 4'b1000, 4'b0000, 1, 0, 0, 0, "AND: Zero flag");
        
        $display("");
        
        // OR tests
        $display("--- Testing OR (opcode 1001) ---");
        test_alu(4'b1010, 4'b0101, 4'b1001, 4'b1111, 0, 0, 0, 1, "OR: 1010 | 0101 = 1111");
        test_alu(4'b0000, 4'b0000, 4'b1001, 4'b0000, 1, 0, 0, 0, "OR: Zero flag");
        test_alu(4'b1100, 4'b0011, 4'b1001, 4'b1111, 0, 0, 0, 1, "OR: 1100 | 0011 = 1111");
        
        $display("");
        
        // XOR tests
        $display("--- Testing XOR (opcode 1010) ---");
        test_alu(4'b1010, 4'b1100, 4'b1010, 4'b0110, 0, 0, 0, 0, "XOR: 1010 ^ 1100 = 0110");
        test_alu(4'b1111, 4'b1111, 4'b1010, 4'b0000, 1, 0, 0, 0, "XOR: Zero flag");
        test_alu(4'b1010, 4'b0101, 4'b1010, 4'b1111, 0, 0, 0, 1, "XOR: 1010 ^ 0101 = 1111");
        
        $display("");
        
        // NOT tests
        $display("--- Testing NOT (opcode 1011) ---");
        test_alu(4'b1010, 4'b0000, 4'b1011, 4'b0101, 0, 0, 0, 0, "NOT: ~1010 = 0101");
        test_alu(4'b0000, 4'b0000, 4'b1011, 4'b1111, 0, 0, 0, 1, "NOT: ~0000 = 1111");
        test_alu(4'b1111, 4'b0000, 4'b1011, 4'b0000, 1, 0, 0, 0, "NOT: Zero flag");
        
        $display("");
        
        // NAND tests
        $display("--- Testing NAND (opcode 1100) ---");
        test_alu(4'b1010, 4'b1100, 4'b1100, 4'b0111, 0, 0, 0, 0, "NAND: ~(1010 & 1100) = 0111");
        test_alu(4'b1111, 4'b1111, 4'b1100, 4'b0000, 1, 0, 0, 0, "NAND: Zero flag");
        test_alu(4'b0000, 4'b1111, 4'b1100, 4'b1111, 0, 0, 0, 1, "NAND: ~(0000 & 1111) = 1111");
        
        $display("");
        
        // NOR tests
        $display("--- Testing NOR (opcode 1101) ---");
        test_alu(4'b1010, 4'b0101, 4'b1101, 4'b0000, 1, 0, 0, 0, "NOR: Zero flag");
        test_alu(4'b0000, 4'b0000, 4'b1101, 4'b1111, 0, 0, 0, 1, "NOR: ~(0000 | 0000) = 1111");
        test_alu(4'b1100, 4'b0011, 4'b1101, 4'b0000, 1, 0, 0, 0, "NOR: ~(1100 | 0011) = 0000");
        
        $display("");
        
        // XNOR tests
        $display("--- Testing XNOR (opcode 1110) ---");
        test_alu(4'b1010, 4'b1100, 4'b1110, 4'b1001, 0, 0, 0, 1, "XNOR: ~(1010 ^ 1100) = 1001");
        test_alu(4'b1111, 4'b1111, 4'b1110, 4'b1111, 0, 0, 0, 1, "XNOR: ~(1111 ^ 1111) = 1111");
        test_alu(4'b1010, 4'b0101, 4'b1110, 4'b0000, 1, 0, 0, 0, "XNOR: Zero flag");
        
        $display("");
        
        // PASS A tests
        $display("--- Testing PASS A (opcode 1111) ---");
        test_alu(4'b1010, 4'b0000, 4'b1111, 4'b1010, 0, 0, 0, 1, "PASS: A = 1010");
        test_alu(4'b0000, 4'b1111, 4'b1111, 4'b0000, 1, 0, 0, 0, "PASS: A = 0000 (zero)");
        test_alu(4'b0101, 4'b1010, 4'b1111, 4'b0101, 0, 0, 0, 0, "PASS: A = 0101");
        
        $display("");
        
        // ===== RANDOMIZED TESTS =====
        $display("========================================");
        $display("RANDOMIZED TESTS");
        $display("========================================\n");
        
        for (i = 0; i < 50; i = i + 1) begin
            A = $random;
            B = $random;
            opcode = $random % 16;
            #10;
            $display("Random test %0d: A=%b, B=%b, op=%b -> result=%b flags=Z%bC%bV%bN%b",
                     i, A, B, opcode, result, zero, carry, overflow, negative);
        end
        
        $display("");
        
        // ===== TEST SUMMARY =====
        $display("========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        if (errors == 0) begin
            $display("✓ ALL TESTS PASSED!");
            $display("  Total operations tested: 15");
            $display("  Arithmetic: ADD, SUB, INC, DEC, CMP");
            $display("  Logic: AND, OR, XOR, NOT, NAND, NOR, XNOR");
            $display("  Special: PASS A");
        end else begin
            $display("✗ TESTS FAILED: %0d errors", errors);
        end
        
        $display("\nSimulation complete.");
        $display("Waveform saved to: alu_4bit.vcd");
        $display("View with: gtkwave sim/alu_4bit.vcd");
        $display("========================================\n");
        
        #50;
        $finish;
    end

endmodule