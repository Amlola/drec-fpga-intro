`include "alu.vh"


module alu #(
    parameter WIDTH = 32
)(
    input wire [WIDTH-1:0] i_first,
    input wire [WIDTH-1:0] i_second,
    input wire [`ALU_OP_WIDTH-1:0] i_operation,

    output reg [WIDTH-1:0] o_result
);

wire [`SHIFT_WIDTH-1:0] shamt = i_second[`SHIFT_WIDTH-1:0];

always @(*) begin
    case (i_operation)
        `ALU_ADD:  o_result = i_first + i_second;
        `ALU_SUB:  o_result = i_first - i_second;
        `ALU_OR:   o_result = i_first | i_second;
        `ALU_AND:  o_result = i_first & i_second;
        `ALU_XOR:  o_result = i_first ^ i_second;
        `ALU_SRL:  o_result = i_first >> shamt;
        `ALU_SRA:  o_result = $signed(i_first) >>> shamt;
        `ALU_SLL:  o_result = i_first << shamt;
        `ALU_SLT:  o_result = {{WIDTH-1{1'b0}}, $signed(i_first) < $signed(i_second)};
        `ALU_SLTU: o_result = {{WIDTH-1{1'b0}}, i_first < i_second};
        default:   o_result = {WIDTH{1'bX}};
    endcase
end

endmodule   