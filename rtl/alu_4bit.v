
// Top-level 4-bit ALU module
// Opcode map:
// 000 - ADD    (arithmetic)
// 001 - SUB    (arithmetic)
// 010 - INC    (arithmetic)
// 011 - DEC    (arithmetic)
// 100 - AND    (logic)
// 101 - OR     (logic)
// 110 - XOR    (logic)
// 111 - NOT    (logic)

module alu_4bit #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [2:0] opcode,
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
    
    // Determine if operation is arithmetic (opcode[2] == 0) or logic (opcode[2] == 1)
    assign is_arithmetic = ~opcode[2];
    
    // Instantiate arithmetic core
    arithmetic_core #(.WIDTH(WIDTH)) arith_core (
        .a(A),
        .b(B),
        .op(opcode[1:0]),
        .result(arith_result),
        .carry_out(arith_carry),
        .overflow(arith_overflow)
    );
    
    // Instantiate logic unit
    logic_unit #(.WIDTH(WIDTH)) logic_core (
        .a(A),
        .b(B),
        .op(opcode[1:0]),
        .result(logic_result)
    );
    
    // Result multiplexer: select arithmetic or logic result
    assign final_result = is_arithmetic ? arith_result : logic_result;
    
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