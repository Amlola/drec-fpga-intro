`include "config.vh"

module mmio_xbar (
    input  wire [29:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire [3:0]  i_mmio_mask,
    input  wire        i_mmio_wren,
    output wire [31:0] o_mmio_data,

    output reg  [15:0] o_hexd_data,
    output reg         o_hexd_wren
);

assign o_mmio_data = {32{1'b0}};

always @(*) begin
    o_hexd_data = {16{1'bX}};
    o_hexd_wren = 1'b0;

    if (i_mmio_addr == `XBAR_HEXD_ADDR0) begin
        if (i_mmio_mask[0])
            o_hexd_data[7:0] = i_mmio_data[7:0];

        if (i_mmio_mask[1])
            o_hexd_data[15:8] = i_mmio_data[15:8];

        o_hexd_wren = i_mmio_wren;
    end
end

endmodule