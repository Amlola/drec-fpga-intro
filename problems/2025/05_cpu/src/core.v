module core (
    input  wire  clk,
    input  wire  rst_n,

    input  wire [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,

    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire        o_mem_we,
    output wire [3:0]  o_mem_mask,
    input  wire [31:0] i_mem_data
);

wire sign_bit = i_instr_data[31];

wire [31:0] imm_i = {{20{sign_bit}}, i_instr_data[31:20]};
wire [31:0] imm_s = {{20{sign_bit}}, i_instr_data[31:25], i_instr_data[11:7]};
wire [31:0] imm_b = {{20{sign_bit}}, i_instr_data[7], i_instr_data[30:25], i_instr_data[11:8], 1'b0};
wire [31:0] imm_u = {i_instr_data[31:12], {12{1'b0}}};
wire [31:0] imm_j = {{12{sign_bit}}, i_instr_data[19:12], i_instr_data[20], i_instr_data[30:21], 1'b0};

wire [4:0]  rs1_addr = i_instr_data[19:15];
wire [31:0] rs1_data;

wire [4:0]  rs2_addr = i_instr_data[24:20];
wire [31:0] rs2_data;

wire [4:0]  rd_addr = i_instr_data[11:7];

wire [1:0] alu_sel1;
wire [1:0] alu_sel2;
wire [3:0] alu_op;
wire [2:0] cmp_op;
wire       branch;
wire       jump;
wire [1:0] wb_sel;

wire load;
wire store;

wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_res;

wire        branch_res;
wire [31:0] lsu_data;

wire        wb_en;
wire [31:0] wr_data;

reg [29:0] pc;
assign     o_instr_addr = pc;

control control_inst (
    .i_instr    (i_instr_data),
    .o_alu_sel1 (alu_sel1),
    .o_alu_sel2 (alu_sel2),
    .o_alu_op   (alu_op),
    .o_cmp_op   (cmp_op),
    .o_branch   (branch),
    .o_jump     (jump),
    .o_wb_sel   (wb_sel),
    .o_wb_en    (wb_en),
    .o_load     (load),
    .o_store    (store)
);

mux4 #(
    .WIDTH(32)
) mux4_a_inst (
    .i0    (imm_u),
    .i1    (imm_b),
    .i2    (imm_j),
    .i3    (rs1_data),
    .i_sel (alu_sel1),
    .o_y   (alu_a)
);

mux4 #(
    .WIDTH(32)
) mux4_b_inst (
    .i0    (rs2_data),
    .i1    (imm_i),
    .i2    (imm_s),
    .i3    ({pc, {2{1'b0}}}),
    .i_sel (alu_sel2),
    .o_y   (alu_b)
);

alu #(
    .WIDTH(32)
) alu_inst (
    .i_first     (alu_a),
    .i_second    (alu_b),
    .i_operation (alu_op),
    .o_result    (alu_res)
);

regfile #(
    .DATA_WIDTH(32),
    .REG_NUM(32)
) regfile_inst (
    .clk        (clk),
    .i_rd1_addr (rs1_addr),
    .i_rd2_addr (rs2_addr),
    .o_rd1_data (rs1_data),
    .o_rd2_data (rs2_data),
    .i_wr_addr  (rd_addr),
    .i_wr_data  (wr_data),
    .i_wr_en    (wb_en)
);

branch #(
    .WIDTH(32)
) branch_inst (
    .i_first     (rs1_data),
    .i_second    (rs2_data),
    .i_operation (cmp_op),
    .o_taken     (branch_res)
);

wire [29:0] pc_inc = pc + 30'd1;
wire taken = jump || (branch && branch_res);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc <= {30{1'b0}};
    else 
        pc <= taken ? alu_res[31:2] : pc_inc;
end

lsu lsu_inst (
    .i_addr     (alu_res),
    .i_data     (rs2_data),
    .i_funct3   (i_instr_data[14:12]),
    .o_data     (lsu_data),
    .i_load     (load),
    .i_store    (store),
    .i_mem_data (i_mem_data),
    .o_mem_data (o_mem_data),
    .o_mem_addr (o_mem_addr),
    .o_mem_mask (o_mem_mask),
    .o_mem_wren (o_mem_we)
);

mux4 #(
    .WIDTH(32)
) mux4_sel_wb_inst (
    .i0    (alu_res),
    .i1    (lsu_data),
    .i2    ({pc_inc, {2{1'b0}}}),
    .i3    (imm_u),
    .i_sel (wb_sel),
    .o_y   (wr_data)
);

endmodule