`include "cmp.vh"


module branch #(
    parameter WIDTH = 32
)(
    input wire [WIDTH-1:0] i_first,
    input wire [WIDTH-1:0] i_second,
    input wire [`BRANCH_OP_WIDTH-1:0] i_operation,

    output reg o_taken
);

always @(*) begin
    case (i_operation)
        `BRANCH_BEQ:  o_taken = (i_first == i_second);
        `BRANCH_BNE:  o_taken = (i_first != i_second);
        `BRANCH_BLT:  o_taken = ($signed(i_first) < $signed(i_second));
        `BRANCH_BGE:  o_taken = ($signed(i_first) >= $signed(i_second));
        `BRANCH_BLTU: o_taken = (i_first < i_second);
        `BRANCH_BGEU: o_taken = (i_first >= i_second);
        default:      o_taken = 1'bX;
    endcase
end

endmodule