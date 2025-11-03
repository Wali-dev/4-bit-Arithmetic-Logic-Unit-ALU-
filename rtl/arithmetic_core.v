
// Arithmetic operations: ADD, SUB, INC, DEC, CMP (Compare)
// Generates carry and overflow flags

module arithmetic_core #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [2:0] op,        // 000=ADD, 001=SUB, 010=INC, 011=DEC, 100=CMP
    output [WIDTH-1:0] result,
    output carry_out,
    output overflow
);

    reg [WIDTH:0] temp_result;
    reg c_out, v_out;
    
    always @(*) begin
        case (op)
            3'b000: begin  // ADD
                temp_result = {1'b0, a} + {1'b0, b};
                c_out = temp_result[WIDTH];
                v_out = (a[WIDTH-1] == b[WIDTH-1]) && (a[WIDTH-1] != temp_result[WIDTH-1]);
            end
            3'b001: begin  // SUB
                temp_result = {1'b0, a} - {1'b0, b};
                c_out = temp_result[WIDTH];  // Borrow
                v_out = (a[WIDTH-1] != b[WIDTH-1]) && (a[WIDTH-1] != temp_result[WIDTH-1]);
            end
            3'b010: begin  // INC
                temp_result = {1'b0, a} + 1'b1;
                c_out = temp_result[WIDTH];
                v_out = (a == {1'b0, {(WIDTH-1){1'b1}}});  // 0111 -> 1000 overflow
            end
            3'b011: begin  // DEC
                temp_result = {1'b0, a} - 1'b1;
                c_out = temp_result[WIDTH];
                v_out = (a == {1'b1, {(WIDTH-1){1'b0}}});  // 1000 -> 0111 overflow
            end
            3'b100: begin  // CMP (Compare: A - B, set flags but don't use result)
                temp_result = {1'b0, a} - {1'b0, b};
                c_out = temp_result[WIDTH];  // Borrow if A < B
                v_out = (a[WIDTH-1] != b[WIDTH-1]) && (a[WIDTH-1] != temp_result[WIDTH-1]);
            end
            default: begin
                temp_result = {WIDTH+1{1'b0}};
                c_out = 1'b0;
                v_out = 1'b0;
            end
        endcase
    end
    
    assign result = temp_result[WIDTH-1:0];
    assign carry_out = c_out;
    assign overflow = v_out;

endmodule