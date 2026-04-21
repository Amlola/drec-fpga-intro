module uart_rx #(
    parameter FREQ = 50_000_000,
    parameter RATE = 2_000_000
) (
    input  wire clk,
    input  wire rst_n,

    output reg [7:0] o_data,
    output wire      o_vld,
    input  wire      i_rx
);

localparam CLKS_PER_BIT = FREQ / RATE;

// Enabling Counter
wire en;
// FSM
reg [3:0] state, next_state;

wire rx_fall;
wire load;
reg  rx_d;

localparam [3:0] IDLE  = {1'b0, 3'd0},
                 START = {1'b0, 3'd1},
                 STOP  = {1'b0, 3'd2},
                 BIT0  = {1'b1, 3'd0},
                 BIT1  = {1'b1, 3'd1},
                 BIT2  = {1'b1, 3'd2},
                 BIT3  = {1'b1, 3'd3},
                 BIT4  = {1'b1, 3'd4},
                 BIT5  = {1'b1, 3'd5},
                 BIT6  = {1'b1, 3'd6},
                 BIT7  = {1'b1, 3'd7};


always @(posedge clk) begin
    rx_d <= i_rx;
end

assign rx_fall = rx_d & ~i_rx;
assign load    = (state == IDLE) && rx_fall;

counter #(
    .CNT_WIDTH($clog2(CLKS_PER_BIT)),
    .CNT_LOAD(CLKS_PER_BIT / 2),
    .CNT_MAX(CLKS_PER_BIT- 1)
) counter_inst(.clk(clk), .rst_n(rst_n), .i_load(load), .o_en(en));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        IDLE:    next_state = rx_fall ? START : state;
        START:   next_state = en      ? (i_rx ? IDLE : BIT0) : state;
        BIT0:    next_state = en      ? BIT1  : state;
        BIT1:    next_state = en      ? BIT2  : state;
        BIT2:    next_state = en      ? BIT3  : state;
        BIT3:    next_state = en      ? BIT4  : state;
        BIT4:    next_state = en      ? BIT5  : state;
        BIT5:    next_state = en      ? BIT6  : state;
        BIT6:    next_state = en      ? BIT7  : state;
        BIT7:    next_state = en      ? STOP  : state;
        STOP:    next_state = en      ? IDLE  : state;
        default: next_state = state;
    endcase
end

always @(posedge clk) begin
    if (en && state[3])
        o_data <= {i_rx, o_data[7:1]};
end

assign o_vld = en && (state == STOP) && i_rx;

endmodule