`include "fp16.vh"

module fp16mul (
    input  wire [`FP16_WIDTH-1:0] i_a,
    input  wire [`FP16_WIDTH-1:0] i_b,
    output reg  [`FP16_WIDTH-1:0] o_res
);

reg sign_a;
reg sign_b;
reg sign_res;

reg [`FP16_EXPONENT_WIDTH-1:0] exp_a;
reg [`FP16_EXPONENT_WIDTH-1:0] exp_b;

reg [`FP16_MANTISSA_WIDTH-1:0] frac_a;
reg [`FP16_MANTISSA_WIDTH-1:0] frac_b;

reg [`FP16_MANTISSA_WIDTH:0] mant_a;
reg [`FP16_MANTISSA_WIDTH:0] mant_b;

reg [`FP16_MANTISSA_MUL_WIDTH:0] mant_mul;

reg [`FP16_MANTISSA_WIDTH:0]          mant_res;
reg signed [`FP16_EXPONENT_WIDTH+1:0] exp_res;

always @(*) begin
    sign_a   = i_a[`FP16_WIDTH-1];
    sign_b   = i_b[`FP16_WIDTH-1];
    sign_res = sign_a ^ sign_b;

    exp_a = i_a[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];
    exp_b = i_b[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];

    frac_a = i_a[`FP16_MANTISSA_WIDTH-1:0];
    frac_b = i_b[`FP16_MANTISSA_WIDTH-1:0];

    if ((&exp_a && |frac_a) || (&exp_b && |frac_b)) begin // nan
        o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};
    end

    else if ((&exp_a && (frac_a == 0) && (exp_b == 0)) || (&exp_b && (frac_b == 0) && (exp_a == 0)) ) begin // inf * 0
        o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};
    end

    else if ((&exp_a && (frac_a == 0)) || (&exp_b && (frac_b == 0))) begin // inf
        o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
    end

    else if ((exp_a == 0) || (exp_b == 0)) begin // DAZ
        o_res = {sign_res, {(`FP16_WIDTH - 1){1'b0}}};
    end

    else begin
        mant_a = {1'b1, frac_a};
        mant_b = {1'b1, frac_b};

        mant_mul = mant_a * mant_b;

        exp_res = $signed({1'b0, exp_a}) + $signed({1'b0, exp_b}) - `FP16_BIAS;

        if (mant_mul[`FP16_MANTISSA_MUL_WIDTH]) begin
            mant_res = mant_mul[`FP16_MANTISSA_MUL_WIDTH:`FP16_MANTISSA_WIDTH+1];
            exp_res  = exp_res + 1'b1;
        end
        else begin
            mant_res = mant_mul[`FP16_MANTISSA_MUL_WIDTH-1:`FP16_MANTISSA_WIDTH];
        end

        if (exp_res <= 0) begin // FTZ
            o_res = {sign_res, {(`FP16_WIDTH - 1){1'b0}}};
        end
        else if (exp_res >= `FP16_EXPONENT_OVERFLOW) begin
            o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
        end
        else begin
            o_res = {sign_res, exp_res[`FP16_EXPONENT_WIDTH-1:0], mant_res[`FP16_MANTISSA_WIDTH-1:0]};
        end
    end
end

endmodule