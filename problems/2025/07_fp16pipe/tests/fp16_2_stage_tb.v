module fp16u_tb;

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

wire [15:0] a, b, c, z;

reg  [15:0] a_s1;
reg  [15:0] b_s1;
reg  [15:0] z_s1;
reg  [$clog2(`TEST_SIZE)-1:0] idx_s1;

wire       z_sign = z_s1[15];
wire [4:0] z_bexp = z_s1[14:10];
wire [9:0] z_mant = z_s1[9:0];

wire       c_sign = c[15];
wire [4:0] c_bexp = c[14:10];
wire [9:0] c_mant = c[9:0];

fp16add fp16add (
    .clk   (clk),
    .i_a   (a),
    .i_b   (b),
    .o_res (c)
);

reg [3*16-1:0] test[0:`TEST_SIZE-1];
reg [$clog2(`TEST_SIZE)-1:0] idx = 0;

reg ok, pass = 1;
reg start = 1'b0;

assign {a, b, z} = test[idx];

initial begin
    $readmemh("tests/test.txt", test, 0, `TEST_SIZE - 1);
    @(posedge clk);
    start <= 1'b1;
end

wire signed [14:0] diff = $signed(c[14:0]) - $signed(z_s1[14:0]);

always @(*) begin
    if (z_bexp == 5'h0) // Zero/denormal
        ok = (c_bexp == 5'h00) && (c_mant == 10'h0) && (c_sign == z_sign);
    else if (z_bexp == 5'h1F) // Inf/NaN
        ok = (c_bexp == 5'h1F) && (c_mant == 10'h0) && (c_sign == z_sign);
    else
        ok = ($abs(diff) < 2) && (c_sign == z_sign);
end

always @(posedge clk) begin
    a_s1   <= a;
    b_s1   <= b;
    z_s1   <= z;
    idx_s1 <= idx;
end

always @(posedge clk) begin
    if (start) begin
        if (`DEBUG || !ok) begin
            $display("[%d] %h %h -> %h z=%h ok=%d", idx_s1, a_s1, b_s1, c, z_s1, ok);
        end
        pass <= ok ? pass : 0;
        if (idx == `TEST_SIZE-1) begin
            $display("Result: %s", pass ? "PASS" : "FAIL");
            $finish;
        end

        idx <= idx + 1'b1;
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fp16u_tb);
    $display("Test size: %d", `TEST_SIZE);
end

endmodule