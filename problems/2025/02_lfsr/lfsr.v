module lfsr (
    input  wire clk,
    input  wire rst_n,
    input  wire i_en,
    output wire [7:0] o_data
);

reg [7:0] data;

assign o_data = data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data <= {{7{1'b0}}, 1'b1};
    else if (i_en) // primitive p(x) = x^8 + x^6 + x^5 + x^4 + 1
        data <= {data[6:0], data[7] ^ data[5] ^ data[4] ^ data[3]};
end

endmodule
