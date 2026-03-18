`timescale 1ns/1ps

module mux4_tb;

localparam NUM_TESTS = 100;
localparam WIDTH = 8;

reg [WIDTH-1:0] input0;
reg [WIDTH-1:0] input1;
reg [WIDTH-1:0] input2;
reg [WIDTH-1:0] input3;

reg [1:0] sel;

wire [WIDTH-1:0] y;

mux4 #(
    .WIDTH(WIDTH)
) mux4_inst(
    .i0(input0),
    .i1(input1),
    .i2(input2),
    .i3(input3),
    .i_sel(sel),
    .o_y(y)
);

integer test_num;
integer num_errors = 0;

initial begin
    $dumpvars;

    for (test_num = 0; test_num < NUM_TESTS; test_num = test_num + 1) begin
        input0 = $urandom;
        input1 = $urandom;
        input2 = $urandom;
        input3 = $urandom;

        sel = $urandom % 4;
        #1;
        
        case(sel)
            2'b00: if (y !== input0) begin
                $display("FAIL: sel=%b, expected=%b, y=%b\n", sel, input0, y);
                num_errors = num_errors + 1;
            end
            2'b01: if (y !== input1) begin
                $display("FAIL: sel=%b, expected=%b, y=%b\n", sel, input1, y);
                num_errors = num_errors + 1;
            end
            2'b10: if (y !== input2) begin
                $display("FAIL: sel=%b, expected=%b, y=%b\n", sel, input2, y);
                num_errors = num_errors + 1;
            end
            2'b11: if (y !== input3) begin
                $display("FAIL: sel=%b, expected=%b, y=%b\n", sel, input3, y);
                num_errors = num_errors + 1;
            end
            default: begin
                $display("FAIL: unexpected sel=%b\n", sel);
                num_errors = num_errors + 1;
            end
        endcase
    end

    if (num_errors == 0)
        $display("\nAll tests passed");
    else
        $display("FAIL. Number of failed tests: %0d", num_errors);

    $finish;
end

endmodule