
// Bitwise logical operations: AND, OR, XOR, NOT, NAND, NOR, XNOR

module logic_unit #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [2:0] op,        // 000=AND, 001=OR, 010=XOR, 011=NOT, 100=NAND, 101=NOR, 110=XNOR
    output [WIDTH-1:0] result
);

    reg [WIDTH-1:0] logic_result;
    
    always @(*) begin
        case (op)
            3'b000:  logic_result = a & b;      // AND
            3'b001:  logic_result = a | b;      // OR
            3'b010:  logic_result = a ^ b;      // XOR
            3'b011:  logic_result = ~a;         // NOT
            3'b100:  logic_result = ~(a & b);   // NAND
            3'b101:  logic_result = ~(a | b);   // NOR
            3'b110:  logic_result = ~(a ^ b);   // XNOR
            default: logic_result = {WIDTH{1'b0}};
        endcase
    end
    
    assign result = logic_result;

endmodule