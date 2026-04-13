`include "fp16.vh"

module fp16add (
    input  wire [`FP16_WIDTH-1:0] i_a,
    input  wire [`FP16_WIDTH-1:0] i_b,
    output reg  [`FP16_WIDTH-1:0] o_res
);

reg sign_a;
reg sign_b;

reg [`FP16_EXPONENT_WIDTH-1:0] exp_a;
reg [`FP16_EXPONENT_WIDTH-1:0] exp_b;

reg [`FP16_MANTISSA_WIDTH-1:0] frac_a;
reg [`FP16_MANTISSA_WIDTH-1:0] frac_b;

reg [`FP16_MANTISSA_WIDTH:0] mant_a;
reg [`FP16_MANTISSA_WIDTH:0] mant_b;

reg sign_big;
reg sign_small;

reg [`FP16_EXPONENT_WIDTH-1:0] exp_big;
reg [`FP16_EXPONENT_WIDTH-1:0] exp_small;

reg [`FP16_MANTISSA_WIDTH:0]   mant_big;
reg [`FP16_MANTISSA_WIDTH:0]   mant_small;
reg [`FP16_MANTISSA_WIDTH+1:0] mant_big_ext;
reg [`FP16_MANTISSA_WIDTH+1:0] mant_small_ext;

reg [`FP16_MANTISSA_WIDTH+1:0] mant_shifted;
reg [`FP16_MANTISSA_WIDTH+2:0] mant_sum;

reg                                   sign_res;
reg [`FP16_MANTISSA_WIDTH+1:0]        mant_res;
reg signed [`FP16_EXPONENT_WIDTH+1:0] exp_res;

always @(*) begin
    sign_a = i_a[`FP16_WIDTH-1];
    sign_b = i_b[`FP16_WIDTH-1];

    exp_a  = i_a[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];
    exp_b  = i_b[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];

    frac_a = i_a[`FP16_MANTISSA_WIDTH-1:0];
    frac_b = i_b[`FP16_MANTISSA_WIDTH-1:0];

     if ((&exp_a && |frac_a) || (&exp_b && |frac_b)) begin // nan
        o_res = {1'b0, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};
    end

    else if ((&exp_a && (frac_a == 0)) && (&exp_b && (frac_b == 0))) begin
        if (sign_a != sign_b) begin  // +inf + -inf
            o_res = {1'b0, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};
        end
        else begin // inf
            if (&exp_a && (frac_a == 0))
                o_res = {sign_a, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
            else
                o_res = {sign_b, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
        end
    end

    else if ((exp_a == 0) && (exp_b == 0)) begin // DAZ
        o_res = {`FP16_WIDTH{1'b0}};
    end

    else if (exp_a == 0) begin
        o_res = {sign_b, exp_b, frac_b};
    end

    else if (exp_b == 0) begin
        o_res = {sign_a, exp_a, frac_a};
    end

    else begin
        mant_a = {1'b1, frac_a};
        mant_b = {1'b1, frac_b};

        if ((exp_a > exp_b) || ((exp_a == exp_b) && (mant_a >= mant_b))) begin
            sign_big   = sign_a;
            sign_small = sign_b;
            exp_big    = exp_a;
            exp_small  = exp_b;
            mant_big   = mant_a;
            mant_small = mant_b;
        end
        else begin
            sign_big   = sign_b;
            sign_small = sign_a;
            exp_big    = exp_b;
            exp_small  = exp_a;
            mant_big   = mant_b;
            mant_small = mant_a;
        end

        exp_res  = $signed({1'b0, exp_big});
        sign_res = sign_big;

        mant_big_ext   = {mant_big, 1'b0};
        mant_small_ext = {mant_small, 1'b0};

        if ((exp_big - exp_small) >= (`FP16_MANTISSA_WIDTH + 2)) begin
            mant_shifted = {(`FP16_MANTISSA_WIDTH + 2){1'b0}};
        end
        else begin
            mant_shifted = mant_small_ext >> (exp_big - exp_small);
        end

        if (sign_big == sign_small) begin
            mant_sum = {1'b0, mant_big_ext} + {1'b0, mant_shifted};

            if (mant_sum[`FP16_MANTISSA_WIDTH+2]) begin
                mant_res = mant_sum[`FP16_MANTISSA_WIDTH+2:1];
                exp_res  = exp_res + 1'b1;
            end
            else begin
                mant_res = mant_sum[`FP16_MANTISSA_WIDTH+1:0];
            end
        end
        else begin
            mant_res = mant_big_ext - mant_shifted;

            if (mant_res == 0) begin
                sign_res = 1'b0;
                exp_res  = 0;
            end
            else begin
                integer i;
                for (i = 0; i < `FP16_MANTISSA_WIDTH + 2; i = i + 1) begin
                    if ((mant_res[`FP16_MANTISSA_WIDTH+1] == 1'b0) && (exp_res > 0)) begin
                        mant_res = mant_res << 1;
                        exp_res  = exp_res - 1'b1;
                    end
                end
            end
        end

        if (exp_res <= 0) begin
            o_res = {sign_res, {(`FP16_WIDTH - 1){1'b0}}}; // FTZ
        end
        else if (exp_res >= `FP16_EXPONENT_OVERFLOW) begin
            o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
        end
        else begin
            o_res = {sign_res, exp_res[`FP16_EXPONENT_WIDTH-1:0], mant_res[`FP16_MANTISSA_WIDTH:1]};
        end
    end
end

endmodule