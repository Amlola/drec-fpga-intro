module fpga_top (
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE,
    input  wire RXD
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [3:0] anodes;
wire [7:0] segments;
wire [7:0] data;

wire vld;

localparam RATE = 2_000_000;
localparam FREQ = 50_000_000;

reg rx, RXD_d;

always @(posedge CLK) begin
    rx <= RXD_d;
    RXD_d <= RXD;
end

uart_rx #(
    .FREQ(FREQ),
    .RATE(RATE)
) uart_rx_inst(.clk(CLK), .rst_n(rst_n), .i_rx(rx), .o_data(data), .o_vld(vld));

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