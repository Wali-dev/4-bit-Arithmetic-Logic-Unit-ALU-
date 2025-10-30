
// Bitwise logical operations: AND, OR, XOR, NOT

module logic_unit #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [1:0] op,        // 00=AND, 01=OR, 10=XOR, 11=NOT
    output [WIDTH-1:0] result
);

    reg [WIDTH-1:0] logic_result;
    
    always @(*) begin
        case (op)
            2'b00:   logic_result = a & b;   // AND
            2'b01:   logic_result = a | b;   // OR
            2'b10:   logic_result = a ^ b;   // XOR
            2'b11:   logic_result = ~a;      // NOT
            default: logic_result = {WIDTH{1'b0}};
        endcase
    end
    
    assign result = logic_result;

endmodule