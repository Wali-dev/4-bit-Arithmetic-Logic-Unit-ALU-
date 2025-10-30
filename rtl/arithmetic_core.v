
// Arithmetic operations: ADD, SUB, INC, DEC, CMP
// Generates carry and overflow flags

module arithmetic_core #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [1:0] op,        // 00=ADD, 01=SUB, 10=INC, 11=DEC
    output [WIDTH-1:0] result,
    output carry_out,
    output overflow
);

    reg [WIDTH:0] temp_result;
    reg c_out, v_out;
    
    always @(*) begin
        case (op)
            2'b00: begin  // ADD
                temp_result = {1'b0, a} + {1'b0, b};
                c_out = temp_result[WIDTH];
                v_out = (a[WIDTH-1] == b[WIDTH-1]) && (a[WIDTH-1] != temp_result[WIDTH-1]);
            end
            2'b01: begin  // SUB
                temp_result = {1'b0, a} - {1'b0, b};
                c_out = temp_result[WIDTH];  // Borrow
                v_out = (a[WIDTH-1] != b[WIDTH-1]) && (a[WIDTH-1] != temp_result[WIDTH-1]);
            end
            2'b10: begin  // INC
                temp_result = {1'b0, a} + 1'b1;
                c_out = temp_result[WIDTH];
                v_out = (a == {1'b0, {(WIDTH-1){1'b1}}});  // 0111 -> 1000 overflow
            end
            2'b11: begin  // DEC
                temp_result = {1'b0, a} - 1'b1;
                c_out = temp_result[WIDTH];
                v_out = (a == {1'b1, {(WIDTH-1){1'b0}}});  // 1000 -> 0111 overflow
            end
        endcase
    end
    
    assign result = temp_result[WIDTH-1:0];
    assign carry_out = c_out;
    assign overflow = v_out;

endmodule