`include "lsu.vh"


module lsu (
    input  wire [31:0] i_addr,       
    input  wire [31:0] i_data,
    input  wire [2:0]  i_funct3,
    output reg  [31:0] o_data,

    input  wire        i_load,        
    input  wire        i_store,

    input  wire [31:0] i_mem_data, 
    output reg  [31:0] o_mem_data,
    output wire [29:0] o_mem_addr,  
    output reg   [3:0] o_mem_mask,
    output wire        o_mem_wren  
);

assign o_mem_addr = i_addr[31:2];
assign o_mem_wren = i_store;

always @(*) begin
    o_data = {32{1'bX}};

    if (i_load) begin
        case (i_funct3)
            `LSU_FUNCT3_B: begin
                case (i_addr[1:0])
                    2'b00:   o_data = {{24{i_mem_data[7]}},  i_mem_data[7:0]};
                    2'b01:   o_data = {{24{i_mem_data[15]}}, i_mem_data[15:8]};
                    2'b10:   o_data = {{24{i_mem_data[23]}}, i_mem_data[23:16]};
                    2'b11:   o_data = {{24{i_mem_data[31]}}, i_mem_data[31:24]};
                    default: o_data = {32{1'bX}};
                endcase
            end

            `LSU_FUNCT3_H: begin
                case (i_addr[1:0])
                    2'b00:   o_data = {{16{i_mem_data[15]}}, i_mem_data[15:0]};
                    2'b01:   o_data = {{16{i_mem_data[23]}}, i_mem_data[23:8]};
                    2'b10:   o_data = {{16{i_mem_data[31]}}, i_mem_data[31:16]};
                    default: o_data = {32{1'bX}};
                endcase
            end

            `LSU_FUNCT3_W: begin
                o_data = i_mem_data;
            end

            `LSU_FUNCT3_BU: begin
                case (i_addr[1:0])
                    2'b00:   o_data = {{24{1'b0}}, i_mem_data[7:0]};
                    2'b01:   o_data = {{24{1'b0}}, i_mem_data[15:8]};
                    2'b10:   o_data = {{24{1'b0}}, i_mem_data[23:16]};
                    2'b11:   o_data = {{24{1'b0}}, i_mem_data[31:24]};
                    default: o_data = {32{1'bX}};
                endcase
            end

            `LSU_FUNCT3_HU: begin
                case (i_addr[1:0])
                    2'b00:   o_data = {{16{1'b0}}, i_mem_data[15:0]};
                    2'b01:   o_data = {{16{1'b0}}, i_mem_data[23:8]};
                    2'b10:   o_data = {{16{1'b0}}, i_mem_data[31:16]};
                    default: o_data = {32{1'bX}};
                endcase
            end

            default: o_data = {32{1'bX}};
        endcase
    end
end

always @(*) begin
    o_mem_data = {32{1'bX}};
    o_mem_mask = {4{1'bX}};

    if (i_store) begin
        case (i_funct3)
            `LSU_FUNCT3_B: begin
                case (i_addr[1:0])
                    2'b00: begin
                        o_mem_data = {{24{1'b0}}, i_data[7:0]};
                        o_mem_mask = 4'b0001;
                    end
                    2'b01: begin
                        o_mem_data = {{16{1'b0}}, i_data[7:0], {8{1'b0}}};
                        o_mem_mask = 4'b0010;
                    end
                    2'b10: begin
                        o_mem_data = {{8{1'b0}}, i_data[7:0], {16{1'b0}}};
                        o_mem_mask = 4'b0100;
                    end
                    2'b11: begin
                        o_mem_data = {i_data[7:0], {24{1'b0}}};
                        o_mem_mask = 4'b1000;
                    end
                    default: begin
                        o_mem_data = {32{1'bX}};
                        o_mem_mask = {4{1'bX}};
                    end
                endcase
            end

            `LSU_FUNCT3_H: begin
                case (i_addr[1:0])
                    2'b00: begin
                        o_mem_data = {{16{1'b0}}, i_data[15:0]};
                        o_mem_mask = 4'b0011;
                    end
                    2'b01: begin
                        o_mem_data = {{8{1'b0}}, i_data[15:0], {8{1'b0}}};
                        o_mem_mask = 4'b0110;
                    end
                    2'b10: begin
                        o_mem_data = {i_data[15:0], {16{1'b0}}};
                        o_mem_mask = 4'b1100;
                    end
                    default: begin
                        o_mem_data = {32{1'bX}};
                        o_mem_mask = {4{1'bX}};
                    end
                endcase
            end

            `LSU_FUNCT3_W: begin
                o_mem_data = i_data;
                o_mem_mask = 4'b1111;
            end

            default: begin
                o_mem_data = {32{1'bX}};
                o_mem_mask = {4{1'bX}};
            end
        endcase
    end
end

endmodule