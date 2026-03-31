`timescale 1ns/1ps

module regfile_tb;

localparam DATA_WIDTH = 32;
localparam REG_NUM    = 32;
localparam ADDR_WIDTH = $clog2(REG_NUM);

reg clk = 1'b0;

reg  [ADDR_WIDTH-1:0] i_rd1_addr;
reg  [ADDR_WIDTH-1:0] i_rd2_addr;

wire [DATA_WIDTH-1:0] o_rd1_data;
wire [DATA_WIDTH-1:0] o_rd2_data;

reg  [ADDR_WIDTH-1:0] i_wr_addr;
reg  [DATA_WIDTH-1:0] i_wr_data;
reg                   i_wr_en;

reg [DATA_WIDTH-1:0]  expected[REG_NUM-1:0];

regfile #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_NUM(REG_NUM)
) regfile_inst (
    .clk(clk),
    .i_rd1_addr(i_rd1_addr),
    .i_rd2_addr(i_rd2_addr),
    .o_rd1_data(o_rd1_data),
    .o_rd2_data(o_rd2_data),
    .i_wr_addr(i_wr_addr),
    .i_wr_data(i_wr_data),
    .i_wr_en(i_wr_en)
);

always begin
    #1;
    clk = ~clk;
end

task check (
    input [ADDR_WIDTH-1:0] addr1,
    input [ADDR_WIDTH-1:0] addr2
);
begin
    i_rd1_addr = addr1;
    i_rd2_addr = addr2;
    #1;

    if (o_rd1_data !== expected[addr1]) begin
        $display("FAIL: i=%0d RD1: addr=%0d data=%h expected=%h",
                 addr1, addr1, o_rd1_data, expected[addr1]);
        $finish;
    end

    if (o_rd2_data !== expected[addr2]) begin
        $display("FAIL: i=%0d RD2: addr=%0d data=%h expected=%h",
                 addr1, addr2, o_rd2_data, expected[addr2]);
        $finish;
    end
end
endtask

integer i;
initial begin
    $dumpvars;

    i_wr_en = 1'b1;

    for (i = 0; i < REG_NUM; i = i + 1) begin
        @(negedge clk);
        i_wr_addr   = i[ADDR_WIDTH-1:0];
        i_wr_data   = $urandom;
        expected[i] = i_wr_data;
    end

    @(negedge clk);
    i_wr_en = 1'b0;

    for (i = 0; i < REG_NUM / 2; i = i + 1)
        check(i, i + REG_NUM / 2);

    $display("OK");
    $finish;
end

endmodule