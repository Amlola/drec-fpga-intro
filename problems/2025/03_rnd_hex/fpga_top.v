module fpga_top (
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0]  anodes;
wire  [7:0]  segments;
wire  [15:0] data;

wire out_clk;

localparam F0 = 50_000_000;
localparam F1 = 1;
localparam SEED = 16'hD00D;

clkdiv #(
    .F0(F0),
    .F1(F1)
) clkdiv_inst(.clk(CLK), .rst_n(rst_n), .out(out_clk));

lfsr #(
    .SEED(SEED)
) lfsr_inst(.clk(CLK), .rst_n(rst_n), .i_en(out_clk), .o_data(data));

hex_display hex_display_inst(.clk(CLK), .rst_n(rst_n), .i_data(data), .o_anodes(anodes), .o_segments(segments));

ctrl_74hc595 ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
