`timescale 1ns/1ps

module fifo_tb;

localparam DATA_WIDTH = 8;
localparam DEPTH = 16;

localparam ADDR_WIDTH = $clog2(DEPTH);

reg clk = 1'b0;
reg rst_n;

reg i_wr_en;
reg i_rd_en;

reg  [DATA_WIDTH-1:0] i_wr_data;
wire [DATA_WIDTH-1:0] o_rd_data;

wire o_rd_empty;
wire o_wr_full;

fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) fifo_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_wr_en(i_wr_en),
    .i_rd_en(i_rd_en),
    .i_wr_data(i_wr_data),
    .o_rd_data(o_rd_data),
    .o_rd_empty(o_rd_empty),
    .o_wr_full(o_wr_full)
);

always begin
    #1 
    clk = ~clk;
end

task check_data (
    input [DATA_WIDTH-1:0] expected
);
begin
    if (o_rd_data !== expected) begin
        $display("FAIL: o_rd_data = %0h, expected = %0h",
                    o_rd_data, expected);
        $finish;
    end
end
endtask

task check_flags (
    input expected_empty,
    input expected_full
);
begin
    if (o_rd_empty !== expected_empty || o_wr_full !== expected_full) begin
        $display("FAIL: o_rd_empty = %0b, expected = %0b, o_wr_full = %0b, expected = %0b",
                    o_rd_empty, expected_empty, o_wr_full, expected_full);
        $finish;
    end
end
endtask

initial begin
    $dumpvars;

    rst_n = 1'b1;

    #1 
    rst_n = 1'b0;
    #2 
    rst_n = 1'b1;
    #2

    check_flags(1'b1, 1'b0);

    i_wr_en = 1'b1;

    i_wr_data = 'h12; #2
    i_wr_data = 'h23; #2
    i_wr_data = 'h34; #2
    i_wr_data = 'h45; #2
    i_wr_data = 'h56; #2
    i_wr_data = 'h67; #2
    i_wr_data = 'h78; #2
    i_wr_data = 'h89; #2
    i_wr_data = 'h9A; #2
    i_wr_data = 'hAB; #2
    i_wr_data = 'hBC; #2
    i_wr_data = 'hCD; #2
    i_wr_data = 'hDE; #2
    i_wr_data = 'hEF; #2
    i_wr_data = 'hF1; #2
    i_wr_data = 'h1D; #2

    i_wr_en = 1'b0;

    check_flags(1'b0, 1'b1);

    i_rd_en = 1'b1;
    #2 check_data('h12);
    #2 check_data('h23);
    #2 check_data('h34);
    #2 check_data('h45);
    #2 check_data('h56);
    #2 check_data('h67);
    #2 check_data('h78);
    #2 check_data('h89);
    #2 check_data('h9A);
    #2 check_data('hAB);
    #2 check_data('hBC);
    #2 check_data('hCD);
    #2 check_data('hDE);
    #2 check_data('hEF);
    #2 check_data('hF1);
    #2 check_data('h1D);
    i_rd_en = 1'b0;

    #2 check_flags(1'b1, 1'b0);

    $display("OK");
    $finish;
end

endmodule