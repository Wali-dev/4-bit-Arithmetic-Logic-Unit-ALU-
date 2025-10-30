
// Comprehensive testbench with directed and randomized tests

`timescale 1ns/1ps

module tb_alu_4bit;
    parameter WIDTH = 4;
    
    reg [WIDTH-1:0] A, B;
    reg [2:0] opcode;
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
        input [2:0] op;
        input [WIDTH-1:0] expected_result;
        input expected_z, expected_c, expected_v, expected_n;
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
                $display("ERROR at time %0t:", $time);
                $display("  A=%b, B=%b, opcode=%b", A, B, opcode);
                $display("  Expected: result=%b Z=%b C=%b V=%b N=%b", 
                         expected_result, expected_z, expected_c, expected_v, expected_n);
                $display("  Got:      result=%b Z=%b C=%b V=%b N=%b", 
                         result, zero, carry, overflow, negative);
                errors = errors + 1;
            end else begin
                $display("PASS: A=%b, B=%b, op=%b -> result=%b Z=%b C=%b V=%b N=%b",
                         A, B, opcode, result, zero, carry, overflow, negative);
            end
        end
    endtask
    
    initial begin
        errors = 0;
        $display("\n=== Starting ALU Testbench ===\n");
        
        // ===== DIRECTED TESTS =====
        $display("--- Arithmetic Tests ---");
        
        // ADD tests
        $display("Testing ADD...");
        test_alu(4'd3, 4'd2, 3'b000, 4'd5, 0, 0, 0, 0);     // 3+2=5
        test_alu(4'd7, 4'd1, 3'b000, 4'd8, 0, 0, 1, 1);     // Overflow: 7+1=8 (0111+0001=1000)
        test_alu(4'd15, 4'd1, 3'b000, 4'd0, 1, 1, 0, 0);    // Carry: 15+1=16 (overflow to 0)
        test_alu(4'd0, 4'd0, 3'b000, 4'd0, 1, 0, 0, 0);     // Zero flag
        test_alu(4'd8, 4'd8, 3'b000, 4'd0, 1, 1, 1, 0);     // -8+(-8)=0 with carry and overflow
        
        // SUB tests
        $display("Testing SUB...");
        test_alu(4'd5, 4'd3, 3'b001, 4'd2, 0, 0, 0, 0);     // 5-3=2
        test_alu(4'd3, 4'd5, 3'b001, 4'd14, 0, 1, 0, 1);    // 3-5=-2 (borrow)
        test_alu(4'd8, 4'd1, 3'b001, 4'd7, 0, 0, 1, 0);     // Overflow: -8-1=7 (1000-0001=0111)
        test_alu(4'd0, 4'd0, 3'b001, 4'd0, 1, 0, 0, 0);     // Zero flag
        test_alu(4'd7, 4'd8, 3'b001, 4'd15, 0, 1, 1, 1);    // 7-(-8)=-1 with overflow
        
        // INC tests
        $display("Testing INC...");
        test_alu(4'd5, 4'd0, 3'b010, 4'd6, 0, 0, 0, 0);     // 5+1=6
        test_alu(4'd7, 4'd0, 3'b010, 4'd8, 0, 0, 1, 1);     // Overflow: 7+1=8
        test_alu(4'd15, 4'd0, 3'b010, 4'd0, 1, 1, 0, 0);    // 15+1=0 with carry
        
        // DEC tests
        $display("Testing DEC...");
        test_alu(4'd5, 4'd0, 3'b011, 4'd4, 0, 0, 0, 0);     // 5-1=4
        test_alu(4'd8, 4'd0, 3'b011, 4'd7, 0, 0, 1, 0);     // Overflow: -8-1=7
        test_alu(4'd0, 4'd0, 3'b011, 4'd15, 0, 1, 0, 1);    // 0-1=-1 (borrow)
        
        // ===== LOGIC TESTS =====
        $display("\n--- Logic Tests ---");
        
        // AND tests
        $display("Testing AND...");
        test_alu(4'b1010, 4'b1100, 3'b100, 4'b1000, 0, 0, 0, 1);
        test_alu(4'b1111, 4'b1111, 3'b100, 4'b1111, 0, 0, 0, 1);
        test_alu(4'b1010, 4'b0101, 3'b100, 4'b0000, 1, 0, 0, 0);  // Zero flag
        
        // OR tests
        $display("Testing OR...");
        test_alu(4'b1010, 4'b0101, 3'b101, 4'b1111, 0, 0, 0, 1);
        test_alu(4'b0000, 4'b0000, 3'b101, 4'b0000, 1, 0, 0, 0);  // Zero flag
        test_alu(4'b1100, 4'b0011, 3'b101, 4'b1111, 0, 0, 0, 1);
        
        // XOR tests
        $display("Testing XOR...");
        test_alu(4'b1010, 4'b1100, 3'b110, 4'b0110, 0, 0, 0, 0);
        test_alu(4'b1111, 4'b1111, 3'b110, 4'b0000, 1, 0, 0, 0);  // Zero flag
        test_alu(4'b1010, 4'b0101, 3'b110, 4'b1111, 0, 0, 0, 1);
        
        // NOT tests
        $display("Testing NOT...");
        test_alu(4'b1010, 4'b0000, 3'b111, 4'b0101, 0, 0, 0, 0);
        test_alu(4'b0000, 4'b0000, 3'b111, 4'b1111, 0, 0, 0, 1);
        test_alu(4'b1111, 4'b0000, 3'b111, 4'b0000, 1, 0, 0, 0);  // Zero flag
        
        // ===== RANDOMIZED TESTS =====
        $display("\n--- Randomized Tests ---");
        for (i = 0; i < 50; i = i + 1) begin
            A = $random;
            B = $random;
            opcode = $random % 8;
            #10;
            // Just display random test results without checking
            // (in real testbench, you'd compute expected values)
            $display("Random test %0d: A=%b, B=%b, op=%b -> result=%b flags=Z%bC%bV%bN%b",
                     i, A, B, opcode, result, zero, carry, overflow, negative);
        end
        
        // ===== TEST SUMMARY =====
        $display("\n=== Test Summary ===");
        if (errors == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("TESTS FAILED: %0d errors", errors);
        end
        
        $display("\nSimulation complete. Check alu_4bit.vcd with GTKWave.");
        #50;
        $finish;
    end

endmodule