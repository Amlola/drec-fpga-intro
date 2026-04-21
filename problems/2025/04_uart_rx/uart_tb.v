`timescale 1ns/1ps

module uart_tb;

localparam FREQ = 50_000_000;
localparam RATE = 2_000_000;

reg clk   = 1'b0;
reg rst_n;

always begin
    #1 
    clk <= ~clk;
end

reg  [7:0] tx_data;
reg        tx_vld;
wire       o_tx;

wire [7:0] rx_data;
wire       rx_vld;

uart_tx #(
    .FREQ(FREQ),
    .RATE(RATE)
) uart_tx_inst(.clk(clk), .rst_n(rst_n), .i_data(tx_data), .i_vld(tx_vld), .o_tx(o_tx));

uart_rx #(
    .FREQ(FREQ),
    .RATE(RATE)
) uart_rx_inst(.clk(clk), .rst_n(rst_n), .i_rx(o_tx), .o_data(rx_data), .o_vld(rx_vld));

task check (
    input [7:0] data
);
begin
    tx_data <= data;
    tx_vld  <= 1'b1;

    @(posedge clk);
    tx_vld  <= 1'b0;

    wait (rx_vld === 1'b1);

    if (rx_data === data)
        $display("OK: input = 0x%h, output = 0x%h", data, rx_data);
    else begin
        $display("ERROR: sent = 0x%h, received = 0x%h", data, rx_data);
        $finish;
    end

    repeat (FREQ / RATE) @(posedge clk);
end
endtask

initial begin
    $dumpvars;

    tx_data = 8'd0;
    tx_vld  = 1'b0;
    rst_n   = 1'b0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;

    repeat (2) @(posedge clk);

    check(8'h11);
    check(8'h33);
    check(8'h55);
    check(8'h77);
    check(8'h99);
    check(8'hBB);
    check(8'hDD);
    check(8'hFF);
    check(8'h1F);

    $display("TEST PASSED");
    $finish;
end

endmodule