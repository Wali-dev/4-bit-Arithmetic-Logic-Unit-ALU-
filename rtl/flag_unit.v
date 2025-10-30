
// Status flag generation: Zero, Carry, Overflow, Negative

module flag_unit #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] result,
    input  carry_in,
    input  overflow_in,
    input  is_arithmetic,    // 1 if arithmetic op, 0 if logic op
    output zero,
    output carry,
    output overflow,
    output negative
);

    // Zero flag: result is all zeros
    assign zero = (result == {WIDTH{1'b0}});
    
    // Negative flag: MSB of result (sign bit in two's complement)
    assign negative = result[WIDTH-1];
    
    // Carry and Overflow only valid for arithmetic operations
    assign carry = is_arithmetic ? carry_in : 1'b0;
    assign overflow = is_arithmetic ? overflow_in : 1'b0;

endmodule