`timescale 1ns/1ps

`include "branch.vh"


module branch_tb;

localparam WIDTH = 32;

reg [WIDTH-1:0] first;
reg [WIDTH-1:0] second;
reg [`BRANCH_OP_WIDTH-1:0] operation;

wire taken;

branch #(
    .WIDTH(WIDTH)
) branch_inst ( 
    .i_first(first),
    .i_second(second),
    .i_operation(operation),
    .o_taken(taken)
);

integer num_errors = 0;

task branch_test (
    input [`BRANCH_OP_WIDTH-1:0] operation,
    input [WIDTH-1:0] first,
    input [WIDTH-1:0] second,
    input [WIDTH-1:0] expected
);
begin
    branch_tb.first     = first;
    branch_tb.second    = second;
    branch_tb.operation = operation;
    #1

    if (expected !== branch_tb.taken) begin
        num_errors = num_errors + 1;

        $display("FAIL: operation=%0d first=%b second=%b", operation, first, second);
        $display("taken    = %b", branch_tb.taken);
        $display("expected = %b\n", expected);
    end
end
endtask

initial begin
    $dumpvars;

    branch_test(`BRANCH_BEQ, 32'd15, 32'd15, 1'b1); // 1
    branch_test(`BRANCH_BEQ, 32'd13, 32'd26, 1'b0); // 2

    branch_test(`BRANCH_BNE, 32'd13, 32'd26, 1'b1); // 3
    branch_test(`BRANCH_BNE, 32'd15, 32'd15, 1'b0); // 4

    branch_test(`BRANCH_BLT, -32'd4, 32'd3, 1'b1); // 5
    branch_test(`BRANCH_BLT,  32'd4, 32'd3, 1'b0); // 6

    branch_test(`BRANCH_BGE,  32'd14, 32'd14, 1'b1); // 7
    branch_test(`BRANCH_BGE, -32'd1,  32'd1,  1'b0); // 8

    branch_test(`BRANCH_BLTU,  32'd8, -32'd2, 1'b1); // 9
    branch_test(`BRANCH_BLTU, -32'd4,  32'd5, 1'b0); // 10

    branch_test(`BRANCH_BGEU, -32'd3, 32'd9, 1'b1); // 11
    branch_test(`BRANCH_BGEU,  32'd2, 32'd5, 1'b0); // 12


    if (num_errors == 0)
        $display("\nAll tests passed");
    else
        $display("FAIL. Number of failed tests: %0d", num_errors);

    $finish;
end

endmodule
