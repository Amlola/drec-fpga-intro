module mux4 #(
    parameter WIDTH = 32
)(
    input wire [WIDTH-1:0] i0,
    input wire [WIDTH-1:0] i1,
    input wire [WIDTH-1:0] i2,
    input wire [WIDTH-1:0] i3,

    input wire [1:0] i_sel,

    output reg [WIDTH-1:0] o_y
);

always @(*) begin
    case (i_sel)
        2'b00:   o_y = i0;
        2'b01:   o_y = i1;
        2'b10:   o_y = i2;
        2'b11:   o_y = i3;
        default: o_y = {WIDTH{1'bX}};
    endcase
end

endmodule