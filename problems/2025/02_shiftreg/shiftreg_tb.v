`timescale 1ns/1ps

module shiftreg_tb;

localparam WIDTH = 8;

reg clk = 1'b0;

reg             i_bit;
reg             i_en;
reg [WIDTH-1:0] i_data;
reg             i_parall_en;

wire o_bit;

reg [WIDTH-1:0] expected;

shiftreg #(
    .WIDTH(WIDTH)
) shiftreg_inst (
    .clk(clk),
    .i_bit(i_bit),
    .i_en(i_en),
    .i_data(i_data),
    .i_parall_en(i_parall_en),
    .o_bit(o_bit)
);

always begin
    #1;
    clk = ~clk;
end

task check;
begin
    #1;
    if (shiftreg_inst.data !== expected) begin
        $display("FAIL: data=%b expected=%b", shiftreg_inst.data, expected);
        $finish;
    end
end
endtask

initial begin
    $dumpvars;

    i_en        = 1'b0;
    i_parall_en = 1'b1;

    @(negedge clk);
    i_data      = 8'b11000000;
    expected    = 8'b11000000;

    @(posedge clk);
    check();

    @(negedge clk);
    i_parall_en = 1'b0;
    i_en        = 1'b1;
    i_bit       = 1'b0;
    expected    = {expected[WIDTH-2:0], i_bit};

    @(posedge clk);
    check();

    $display("OK");
    $finish;
end

endmodule