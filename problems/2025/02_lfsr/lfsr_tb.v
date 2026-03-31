`timescale 1ns/1ps

module lfsr_tb;

localparam WIDTH = 8;
localparam TEST_NUM = 100;

reg clk = 1'b0;
reg rst_n;

reg i_en;
wire [WIDTH-1:0] o_data;

reg [WIDTH-1:0] expected;

lfsr lfsr_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_en(i_en),
    .o_data(o_data)
);

always begin
    #1;
    clk = ~clk;
end

task check;
begin
    #1;
    if (o_data !== expected) begin
        $display("FAIL: o_data=%b expected=%b", o_data, expected);
        $finish;
    end
end
endtask

integer i;
initial begin
    $dumpvars;

    rst_n    = 1'b0;
    i_en     = 1'b0;
    expected = {{(WIDTH-1){1'b0}}, 1'b1};

    @(posedge clk);
    check();

    @(negedge clk);
    rst_n = 1'b1;
    i_en  = 1'b1;

    for (i = 0; i < TEST_NUM; i = i + 1) begin
        @(posedge clk);
        expected = {expected[WIDTH-2:0], expected[7] ^ expected[5] ^ expected[4] ^ expected[3]};
        check();
    end

    $display("OK");
    $finish;
end

endmodule