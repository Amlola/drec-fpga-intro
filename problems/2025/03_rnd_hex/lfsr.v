module lfsr #(
    parameter [15:0] SEED = 16'h0001
)(
    input  wire clk,
    input  wire rst_n,
    input  wire i_en,
    output wire [15:0] o_data
);

reg [15:0] data;

assign o_data = data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
         data <= (SEED == 16'h0000) ? 16'h0001 : SEED;
    else if (i_en) // primitive p(x) = x^16 + x^14 + x^13 + x^11 + 1
        data <= {data[14:0], data[15] ^ data[13] ^ data[12] ^ data[10]};
end

endmodule
