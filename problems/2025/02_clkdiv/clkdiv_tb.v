`timescale 1ns/1ps

module testbench;

localparam F0 = 50_000_000;
localparam F_out1 = 9600;
localparam F_out2 = 38400;
localparam F_out3 = 115200;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 
    clk <= ~clk;
end

initial begin
    repeat (3) @(posedge clk);
    rst_n <= 1'b1;
end

wire out1;
wire out2;
wire out3;

clkdiv #(
    .F0(F0),
    .F1(F_out1)
) clkdiv1_inst(.clk(clk), .rst_n(rst_n), .out(out1));

clkdiv #(
    .F0(F0),
    .F1(F_out2)
) clkdiv2_inst(.clk(clk), .rst_n(rst_n), .out(out2));

clkdiv #(
    .F0(F0),
    .F1(F_out3)
) clkdiv3_inst(.clk(clk), .rst_n(rst_n), .out(out3));

initial begin
    $dumpvars;
    #100000
    $finish;
end

endmodule
