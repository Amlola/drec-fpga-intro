module timer (
    input wire clk,
    input wire rst_n,

    input  wire        i_en,
    output wire [15:0] o_data
);

reg [15:0] data;

assign o_data = data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data <= 16'd600;
    end 
    else if (i_en) begin
        if (data == 16'd0)
            data <= 16'd600;
        else
            data <= data - 16'd1;
    end
end

endmodule