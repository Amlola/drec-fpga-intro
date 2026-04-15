module hex_display #(
    parameter CNT_WIDTH = 14
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] i_data,
    output wire [3:0]  o_anodes,
    output reg  [7:0]  o_segments
);

reg [CNT_WIDTH-1:0] cnt;
wire          [1:0] pos = cnt[CNT_WIDTH-1:CNT_WIDTH-2];

wire [3:0] digit0, digit1, digit2, digit3;
assign {digit3, digit2, digit1, digit0} = i_data;

reg [3:0] digit;

always @(*) begin
    case (pos)
       2'h0:    digit = digit0;
       2'h1:    digit = digit1;
       2'h2:    digit = digit2;
       2'h3:    digit = digit3;
       default: digit = 4'h0;
    endcase
end

always @(posedge clk or negedge rst_n)
   cnt <= !rst_n ? {CNT_WIDTH{1'b0}} : (cnt + 1'b1);

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
   case (digit)
       4'h0:    o_segments = 8'b11111100; 
       4'h1:    o_segments = 8'b01100000;
       4'h2:    o_segments = 8'b11011010;
       4'h3:    o_segments = 8'b11110010;
       4'h4:    o_segments = 8'b01100110;
       4'h5:    o_segments = 8'b10110110;
       4'h6:    o_segments = 8'b10111110;
       4'h7:    o_segments = 8'b11100000;
       4'h8:    o_segments = 8'b11111110;
       4'h9:    o_segments = 8'b11110110;
       4'hA:    o_segments = 8'b11101110;
       4'hB:    o_segments = 8'b00111110;
       4'hC:    o_segments = 8'b10011100;
       4'hD:    o_segments = 8'b01111010;
       4'hE:    o_segments = 8'b10011110;
       4'hF:    o_segments = 8'b10001110;
       default: o_segments = 8'b00000000;
   endcase
end

endmodule
