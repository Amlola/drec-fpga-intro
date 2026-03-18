module sign_ext #(
    parameter IN_WIDTH  = 12,
    parameter OUT_WIDTH = 32
)(
    input  wire [IN_WIDTH-1:0]  i_x,
    output wire [OUT_WIDTH-1:0] o_y
);

`ifdef BEHAVIORAL
assign o_y = {{(OUT_WIDTH-IN_WIDTH){i_x[IN_WIDTH-1]}}, i_x};

`else
copy #(.WIDTH(IN_WIDTH)) copy_inst (
    .i_x(i_x),
    .o_y(o_y[IN_WIDTH-1:0])
);

generate
    genvar i;
    for (i = IN_WIDTH; i < OUT_WIDTH; i = i + 1) begin : sign_bits
        copy copy_inst (
            .i_x(i_x[IN_WIDTH-1]),
            .o_y(o_y[i])
        );
    end
endgenerate
`endif

endmodule