module regfile #(
    parameter DATA_WIDTH = 32,
    parameter REG_NUM    = 32
)(
    input  wire clk,

    input  wire [$clog2(REG_NUM)-1:0] i_rd1_addr,
    input  wire [$clog2(REG_NUM)-1:0] i_rd2_addr,

    output wire [DATA_WIDTH-1:0]      o_rd1_data,
    output wire [DATA_WIDTH-1:0]      o_rd2_data,

    input  wire [$clog2(REG_NUM)-1:0] i_wr_addr,
    input  wire [DATA_WIDTH-1:0]      i_wr_data,
    input  wire                       i_wr_en,
    
    input  wire [DATA_WIDTH-1:0]      i_bypass_data,
    input  wire                       i_bypass_en
);

localparam [$clog2(REG_NUM)-1:0] ZERO_ADDR = {$clog2(REG_NUM){1'b0}};

reg [DATA_WIDTH-1:0] data[REG_NUM-1:0];

wire [DATA_WIDTH-1:0] rd1_data_raw = data[i_rd1_addr];
wire [DATA_WIDTH-1:0] rd2_data_raw = data[i_rd2_addr];

wire rd1_bypass = i_bypass_en && i_wr_en && (i_rd1_addr == i_wr_addr) && (i_rd1_addr != ZERO_ADDR);
wire rd2_bypass = i_bypass_en && i_wr_en && (i_rd2_addr == i_wr_addr) && (i_rd2_addr != ZERO_ADDR);

assign o_rd1_data = (i_rd1_addr == ZERO_ADDR) ? {DATA_WIDTH{1'b0}} : rd1_bypass ? i_bypass_data : rd1_data_raw;
assign o_rd2_data = (i_rd2_addr == ZERO_ADDR) ? {DATA_WIDTH{1'b0}} : rd2_bypass ? i_bypass_data : rd2_data_raw;

always @(posedge clk) begin
    if (i_wr_en && (i_wr_addr != ZERO_ADDR))
        data[i_wr_addr] <= i_wr_data;
end

endmodule