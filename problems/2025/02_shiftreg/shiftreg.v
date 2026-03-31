module shiftreg #(
    parameter WIDTH = 8
)(
    input wire clk,

    input wire             i_bit,
    input wire             i_en,
    input wire [WIDTH-1:0] i_data, 
    input wire             i_parall_en,

    output wire o_bit
);

reg [WIDTH-1:0] data;

assign o_bit = data[WIDTH-1];

always @(posedge clk) begin
    if (i_parall_en)
        data <= i_data;
    else if (i_en)
        data <= {data[WIDTH-2:0], i_bit};
end

endmodule