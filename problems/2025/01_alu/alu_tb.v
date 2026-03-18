`timescale 1ns/1ps

`include "alu.vh"


module alu_tb;

localparam WIDTH = 32;

reg [WIDTH-1:0] first;
reg [WIDTH-1:0] second;
reg [`ALU_OP_WIDTH-1:0] operation;

wire [WIDTH-1:0] result;

alu #(
    .WIDTH(WIDTH)
) alu_inst (
    .i_first(first),
    .i_second(second),
    .i_operation(operation),
    .o_result(result)
);

integer num_errors = 0;

task alu_test (
    input [`ALU_OP_WIDTH-1:0] operation,
    input [WIDTH-1:0] first,
    input [WIDTH-1:0] second,
    input [WIDTH-1:0] expected
);
begin
    alu_tb.first     = first;
    alu_tb.second    = second;
    alu_tb.operation = operation;
    #1

    if (expected !== alu_tb.result) begin
        num_errors = num_errors + 1;

        $display("FAIL: operation=%0d first=%b second=%b", operation, first, second);
        $display("result   = %b", alu_tb.result);
        $display("expected = %b\n", expected);
    end
end
endtask

initial begin
    $dumpvars;

    alu_test(`ALU_ADD, 32'd112, 32'd134, 32'd246); // 1

    alu_test(`ALU_SUB, 32'd18, 32'd12, 32'd6); // 2

    alu_test(`ALU_OR,  32'b0010_1001, 32'b1111_0110, 32'b1111_1111); // 3

    alu_test(`ALU_AND, 32'hFFFF_FFFF, 32'h2222_3333, 32'h2222_3333); // 4

    alu_test(`ALU_XOR, 32'hAAAA_AAAA, 32'h5555_5555, 32'hFFFF_FFFF); // 5

    alu_test(`ALU_SRL, 32'hFFFF_FFFF, 32'd4,  32'h0FFF_FFFF); // 6

    alu_test(`ALU_SRA, -32'd16, 32'd2, -32'd4); // 7

    alu_test(`ALU_SLL, 32'h0000_0001, 32'd4, 32'h0000_0010); // 8

    alu_test(`ALU_SLT, -32'd1,   32'd1,  32'd1); // 9
    alu_test(`ALU_SLT,  32'd10,  32'd5,  32'd0); // 10

    alu_test(`ALU_SLTU, 32'h0000_0001, 32'hFFFF_FFFF, 32'd1); // 11
    alu_test(`ALU_SLTU, 32'hFFFF_FFFF, 32'h0000_0001, 32'd0); // 12


    if (num_errors == 0)
        $display("\nAll tests passed");
    else
        $display("FAIL. Number of failed tests: %0d", num_errors);

    $finish;
end

endmodule
