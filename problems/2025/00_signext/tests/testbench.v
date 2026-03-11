`timescale 1ns/1ps

module sign_ext_tb;

localparam IN_WIDTH_FIRST_TEST  = 12;
localparam IN_WIDTH_SECOND_TEST = 20;

localparam OUT_WIDTH_TEST  = 32;

localparam NUMBER_TESTS = 100;

reg  [IN_WIDTH_FIRST_TEST-1:0]  input1;
reg  [OUT_WIDTH_TEST-1:0]       expected1;
wire [OUT_WIDTH_TEST-1:0]       output1;

reg  [IN_WIDTH_SECOND_TEST-1:0] input2;
reg  [OUT_WIDTH_TEST-1:0]       expected2;
wire [OUT_WIDTH_TEST-1:0]       output2;

sign_ext #(
    .IN_WIDTH(IN_WIDTH_FIRST_TEST),
    .OUT_WIDTH(OUT_WIDTH_TEST)
) sign_ext_inst1 (
    .i_x(input1),
    .o_y(output1)
);

sign_ext #(
    .IN_WIDTH(IN_WIDTH_SECOND_TEST),
    .OUT_WIDTH(OUT_WIDTH_TEST)
) sign_ext_inst2 (
    .i_x(input2),
    .o_y(output2)
);

integer i;
integer incorrect = 0;

initial begin
    $dumpvars;

    for (i = 0; i < NUMBER_TESTS; i = i + 1) begin
        input1    = $random;
        expected1 = {{(OUT_WIDTH_TEST - IN_WIDTH_FIRST_TEST){input1[IN_WIDTH_FIRST_TEST - 1]}}, input1};
        #1;

        if (output1 !== expected1) begin
            $display("FAIL: N=12 M=32 input=%b output=%b expected=%b",
                     input1, output1, expected1);
            incorrect = incorrect + 1;
        end
    end

    for (i = 0; i < NUMBER_TESTS; i = i + 1) begin
        input2    = $random;
        expected2 = {{(OUT_WIDTH_TEST - IN_WIDTH_SECOND_TEST){input2[IN_WIDTH_SECOND_TEST - 1]}}, input2};
        #1;

        if (output2 !== expected2) begin
            $display("FAIL: N=20 M=32 input=%b output=%b expected=%b",
                     input2, output2, expected2);
            incorrect = incorrect + 1;
        end
    end

    if (incorrect != 0)
        $display("%0d tests incorrect", incorrect);
    else
        $display("All tests passed");

    $finish;
end

endmodule