
// Top-level 4-bit ALU module with extended operations
// Opcode map (4-bit opcode for 16 operations):
// 0000 - ADD     (arithmetic)
// 0001 - SUB     (arithmetic)
// 0010 - INC     (arithmetic)
// 0011 - DEC     (arithmetic)
// 0100 - CMP     (arithmetic compare)
// 0101 - RESERVED
// 0110 - RESERVED
// 0111 - RESERVED
// 1000 - AND     (logic)
// 1001 - OR      (logic)
// 1010 - XOR     (logic)
// 1011 - NOT     (logic)
// 1100 - NAND    (logic)
// 1101 - NOR     (logic)
// 1110 - XNOR    (logic)
// 1111 - PASS A  (pass-through)

module alu_4bit #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [3:0] opcode,      // Extended to 4 bits for 16 operations
    output [WIDTH-1:0] result,
    output zero,
    output carry,
    output overflow,
    output negative
);

    wire [WIDTH-1:0] arith_result;
    wire [WIDTH-1:0] logic_result;
    wire arith_carry;
    wire arith_overflow;
    wire is_arithmetic;
    wire [WIDTH-1:0] final_result;
    
    // Determine if operation is arithmetic (opcode[3] == 0) or logic (opcode[3] == 1)
    assign is_arithmetic = ~opcode[3];
    
    // Instantiate arithmetic core
    arithmetic_core #(.WIDTH(WIDTH)) arith_core (
        .a(A),
        .b(B),
        .op(opcode[2:0]),
        .result(arith_result),
        .carry_out(arith_carry),
        .overflow(arith_overflow)
    );
    
    // Instantiate logic unit
    logic_unit #(.WIDTH(WIDTH)) logic_core (
        .a(A),
        .b(B),
        .op(opcode[2:0]),
        .result(logic_result)
    );
    
    // Result multiplexer: select arithmetic, logic, or pass-through
    assign final_result = (opcode == 4'b1111) ? A :          // PASS A
                         is_arithmetic ? arith_result :      // Arithmetic ops
                         logic_result;                        // Logic ops
    
    // Instantiate flag unit
    flag_unit #(.WIDTH(WIDTH)) flags (
        .result(final_result),
        .carry_in(arith_carry),
        .overflow_in(arith_overflow),
        .is_arithmetic(is_arithmetic),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .negative(negative)
    );
    
    assign result = final_result;

endmodule