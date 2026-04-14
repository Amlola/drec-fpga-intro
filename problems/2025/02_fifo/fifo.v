module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire clk,
    input wire rst_n,

    input wire i_wr_en,
    input wire i_rd_en,

    input  wire [DATA_WIDTH-1:0] i_wr_data,
    output reg  [DATA_WIDTH-1:0] o_rd_data,

    output wire o_rd_empty,
    output wire o_wr_full
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];

reg [ADDR_WIDTH:0] rd_ptr;
reg [ADDR_WIDTH:0] wr_ptr;

assign o_rd_empty = (rd_ptr == wr_ptr);
assign o_wr_full  = (rd_ptr[ADDR_WIDTH] != wr_ptr[ADDR_WIDTH]) && (rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= {ADDR_WIDTH{1'b0}};
        wr_ptr <= {ADDR_WIDTH{1'b0}};
        o_rd_data <= {(ADDR_WIDTH + 1){1'b0}};
    end 
    else begin
        if (i_wr_en && !o_wr_full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= i_wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
        if (i_rd_en && !o_rd_empty) begin
            o_rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

endmodule