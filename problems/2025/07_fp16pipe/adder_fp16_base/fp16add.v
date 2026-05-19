`include "../fp16.vh"

module fp16add (
    input  wire [`FP16_WIDTH-1:0] i_a,
    input  wire [`FP16_WIDTH-1:0] i_b,
    output reg  [`FP16_WIDTH-1:0] o_res
);

wire sign_a = i_a[`FP16_WIDTH-1];
wire sign_b = i_b[`FP16_WIDTH-1];

wire [`FP16_EXPONENT_WIDTH-1:0] exp_a  = i_a[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];
wire [`FP16_EXPONENT_WIDTH-1:0] exp_b  = i_b[`FP16_WIDTH-2:`FP16_MANTISSA_WIDTH];

wire [`FP16_MANTISSA_WIDTH-1:0] frac_a = i_a[`FP16_MANTISSA_WIDTH-1:0];
wire [`FP16_MANTISSA_WIDTH-1:0] frac_b = i_b[`FP16_MANTISSA_WIDTH-1:0];

wire [`FP16_MANTISSA_WIDTH:0] mant_a = {1'b1, frac_a};
wire [`FP16_MANTISSA_WIDTH:0] mant_b = {1'b1, frac_b};

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

reg [3:0] norm_shift;

wire a_bigger_mag = ({exp_a, mant_a} >= {exp_b, mant_b});
reg [`FP16_EXPONENT_WIDTH-1:0] exp_diff;

function [3:0] shift;
    input [`FP16_MANTISSA_WIDTH+1:0] val;
    begin
        casez (val)
            `FP16_SHIFT_WIDTH'b1???????????: shift = 4'd0;
            `FP16_SHIFT_WIDTH'b01??????????: shift = 4'd1;
            `FP16_SHIFT_WIDTH'b001?????????: shift = 4'd2;
            `FP16_SHIFT_WIDTH'b0001????????: shift = 4'd3;
            `FP16_SHIFT_WIDTH'b00001???????: shift = 4'd4;
            `FP16_SHIFT_WIDTH'b000001??????: shift = 4'd5;
            `FP16_SHIFT_WIDTH'b0000001?????: shift = 4'd6;
            `FP16_SHIFT_WIDTH'b00000001????: shift = 4'd7;
            `FP16_SHIFT_WIDTH'b000000001???: shift = 4'd8;
            `FP16_SHIFT_WIDTH'b0000000001??: shift = 4'd9;
            `FP16_SHIFT_WIDTH'b00000000001?: shift = 4'd10;
            `FP16_SHIFT_WIDTH'b000000000001: shift = 4'd11;
            default:                         shift = 4'd0;
        endcase
    end
endfunction

always @(*) begin
    sign_big   = 1'b0;
    sign_small = 1'b0;

    exp_big   = {`FP16_EXPONENT_WIDTH{1'b0}};
    exp_small = {`FP16_EXPONENT_WIDTH{1'b0}};
    exp_diff  = {`FP16_EXPONENT_WIDTH{1'b0}};

    mant_big   = {(`FP16_MANTISSA_WIDTH + 1){1'b0}};
    mant_small = {(`FP16_MANTISSA_WIDTH + 1){1'b0}};

    mant_big_ext   = {(`FP16_MANTISSA_WIDTH + 2){1'b0}};
    mant_small_ext = {(`FP16_MANTISSA_WIDTH + 2){1'b0}};

    mant_shifted = {(`FP16_MANTISSA_WIDTH + 2){1'b0}};
    mant_sum     = {(`FP16_MANTISSA_WIDTH + 3){1'b0}};

    norm_shift = 4'd0;

    sign_res = 1'b0;
    mant_res = {(`FP16_MANTISSA_WIDTH + 2){1'b0}};
    exp_res  = {(`FP16_EXPONENT_WIDTH + 2){1'b0}};

    o_res = {`FP16_WIDTH{1'b0}};

    if ((&exp_a && |frac_a) || (&exp_b && |frac_b)) // nan
        o_res = {1'b0, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};

    else if ((&exp_a && (frac_a == 0)) && (&exp_b && (frac_b == 0))) begin
        if (sign_a != sign_b) // +inf + -inf
            o_res = {1'b0, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b1}}};
        else begin // inf
            if (&exp_a && (frac_a == 0))
                o_res = {sign_a, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
            else
                o_res = {sign_b, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
        end
    end

    else if ((exp_a == 0) && (exp_b == 0)) // DAZ
        o_res = {`FP16_WIDTH{1'b0}};

    else if (exp_a == 0)
        o_res = {sign_b, exp_b, frac_b};

    else if (exp_b == 0)
        o_res = {sign_a, exp_a, frac_a};

    else begin
        if (a_bigger_mag) begin
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

        exp_diff = exp_big - exp_small;

        if (exp_diff >= (`FP16_MANTISSA_WIDTH + 2))
            o_res = {sign_big, exp_big, mant_big[`FP16_MANTISSA_WIDTH-1:0]};
        else begin
            mant_shifted = mant_small_ext >> exp_diff;

            if (sign_big == sign_small) begin
                mant_sum = {1'b0, mant_big_ext} + {1'b0, mant_shifted};

                if (mant_sum[`FP16_MANTISSA_WIDTH+2]) begin
                    mant_res = mant_sum[`FP16_MANTISSA_WIDTH+2:1];
                    exp_res  = exp_res + 1'b1;
                end
                else
                    mant_res = mant_sum[`FP16_MANTISSA_WIDTH+1:0];
            end
            else begin
                mant_res = mant_big_ext - mant_shifted;

                if (mant_res == 0) begin
                    sign_res = 1'b0;
                    exp_res  = 0;
                end
                else begin
                    norm_shift = shift(mant_res);

                    if (norm_shift >= exp_big)
                        exp_res = 0;
                    else begin
                        mant_res = mant_res << norm_shift;
                        exp_res  = $signed({1'b0, exp_big}) - norm_shift;
                    end
                end
            end

            if (exp_res <= 0)
                o_res = {sign_res, {(`FP16_WIDTH - 1){1'b0}}}; // FTZ
            else if (exp_res >= `FP16_EXPONENT_OVERFLOW)
                o_res = {sign_res, {`FP16_EXPONENT_WIDTH{1'b1}}, {`FP16_MANTISSA_WIDTH{1'b0}}};
            else
                o_res = {sign_res, exp_res[`FP16_EXPONENT_WIDTH-1:0], mant_res[`FP16_MANTISSA_WIDTH:1]};
        end
    end
end

endmodule