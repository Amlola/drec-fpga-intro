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
    input  wire                       i_wr_en
);

reg [DATA_WIDTH-1:0] data[REG_NUM-1:0];

assign o_rd1_data = (i_rd1_addr == {$clog2(REG_NUM){1'b0}}) ? {DATA_WIDTH{1'b0}} : data[i_rd1_addr];
assign o_rd2_data = (i_rd2_addr == {$clog2(REG_NUM){1'b0}}) ? {DATA_WIDTH{1'b0}} : data[i_rd2_addr];

always @(posedge clk) begin
    if (i_wr_en) begin
        data[i_wr_addr] <= i_wr_data;
    end
end

endmodule