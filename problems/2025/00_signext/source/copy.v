module copy #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] i_x,
    output wire [WIDTH-1:0] o_y
);

assign o_y = i_x;

endmodule