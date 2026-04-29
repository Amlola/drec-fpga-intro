`include "alu.vh"
`include "cmp.vh"
`include "lsu.vh"


module control (
    input wire [31:0] i_instr,

    output reg [1:0] o_alu_sel1,
    output reg [1:0] o_alu_sel2,
    output reg [3:0] o_alu_op,
    output reg [2:0] o_cmp_op,
    output wire      o_branch,
    output wire      o_jump,
    output reg [1:0] o_wb_sel,
    output wire      o_wb_en,

    output wire o_load,
    output wire o_store
);

wire [6:0] opcode = i_instr[6:0];
wire [2:0] funct3 = i_instr[14:12];
wire [6:0] funct7 = i_instr[31:25];

assign o_branch = (opcode == `OPCODE_BRANCH);
assign o_jump   = (opcode == `OPCODE_JALR) || (opcode == `OPCODE_JAL);

assign o_load  = (opcode == `OPCODE_LOAD);
assign o_store = (opcode == `OPCODE_STORE);

assign o_wb_en = (opcode != `OPCODE_STORE) && (opcode != `OPCODE_BRANCH);

localparam [1:0]
    SEL1_U_IMM = 2'b00,
    SEL1_B_IMM = 2'b01,
    SEL1_J_IMM = 2'b10,
    SEL1_SRC1  = 2'b11;

localparam [1:0]
    SEL2_SRC2  = 2'b00,
    SEL2_I_IMM = 2'b01,
    SEL2_S_IMM = 2'b10,
    SEL2_PC    = 2'b11;

localparam [1:0]
    SELWB_ALU   = 2'b00,
    SELWB_LSU   = 2'b01,
    SELWB_PC4   = 2'b10,
    SELWB_IMM_U = 2'b11;

always @(*) begin
    {o_alu_sel1, o_alu_sel2, o_wb_sel} = {6{1'bX}};
    o_alu_op = {4{1'bX}}; 
    o_cmp_op = {3{1'bX}};

    case (opcode)
         `OPCODE_OP_IMM: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_SRC1, SEL2_I_IMM, SELWB_ALU};

            case (funct3)
                `ALU_FUNCT3_ADD_SUB: o_alu_op = `ALU_ADD;
                `ALU_FUNCT3_OR:      o_alu_op = `ALU_OR;
                `ALU_FUNCT3_AND:     o_alu_op = `ALU_AND;
                `ALU_FUNCT3_XOR:     o_alu_op = `ALU_XOR;
                `ALU_FUNCT3_SRL_SRA: o_alu_op = (funct7 == `ALU_FUNCT7_SRL) ? `ALU_SRL : `ALU_SRA;
                `ALU_FUNCT3_SLL:     o_alu_op = `ALU_SLL;
                `ALU_FUNCT3_SLT:     o_alu_op = `ALU_SLT;
                `ALU_FUNCT3_SLTU:    o_alu_op = `ALU_SLTU;
                default              o_alu_op = {4{1'bX}}; 
            endcase
        end

        `OPCODE_OP: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_SRC1, SEL2_SRC2, SELWB_ALU};

            case (funct3)
                `ALU_FUNCT3_ADD_SUB: o_alu_op = (funct7 == `ALU_FUNCT7_ADD) ? `ALU_ADD : `ALU_SUB;
                `ALU_FUNCT3_OR:      o_alu_op = `ALU_OR;
                `ALU_FUNCT3_AND:     o_alu_op = `ALU_AND;
                `ALU_FUNCT3_XOR:     o_alu_op = `ALU_XOR;
                `ALU_FUNCT3_SRL_SRA: o_alu_op = (funct7 == `ALU_FUNCT7_SRL) ? `ALU_SRL : `ALU_SRA;
                `ALU_FUNCT3_SLL:     o_alu_op = `ALU_SLL;
                `ALU_FUNCT3_SLT:     o_alu_op = `ALU_SLT;
                `ALU_FUNCT3_SLTU:    o_alu_op = `ALU_SLTU;
                default              o_alu_op = {4{1'bX}}; 
            endcase
        end

        `OPCODE_STORE: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_SRC1, SEL2_S_IMM, {2{1'bX}}};
            o_alu_op = `ALU_ADD;
        end

        `OPCODE_BRANCH: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_B_IMM, SEL2_PC, {2{1'bX}}};
            o_alu_op = `ALU_ADD;

            case (funct3)
                `BRANCH_FUNCT3_BEQ:  o_cmp_op = `BRANCH_BEQ;
                `BRANCH_FUNCT3_BNE:  o_cmp_op = `BRANCH_BNE;
                `BRANCH_FUNCT3_BLT:  o_cmp_op = `BRANCH_BLT;
                `BRANCH_FUNCT3_BGE:  o_cmp_op = `BRANCH_BGE;
                `BRANCH_FUNCT3_BLTU: o_cmp_op = `BRANCH_BLTU;
                `BRANCH_FUNCT3_BGEU: o_cmp_op = `BRANCH_BGEU;
                default:             o_cmp_op = {3{1'bX}};          
            endcase
        end

        `OPCODE_LOAD: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_SRC1, SEL2_I_IMM, SELWB_LSU};
            o_alu_op = `ALU_ADD;
        end

        `OPCODE_JALR: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_SRC1, SEL2_I_IMM, SELWB_PC4};
            o_alu_op = `ALU_ADD;
        end

        `OPCODE_JAL: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_J_IMM, SEL2_PC, SELWB_PC4};
            o_alu_op = `ALU_ADD;
        end

        `OPCODE_LUI: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {{2{1'bX}}, {2{1'bX}}, SELWB_IMM_U};
        end

        `OPCODE_AUIPC: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SEL1_U_IMM, SEL2_PC, SELWB_ALU};
            o_alu_op = `ALU_ADD;
        end

        default: begin
            {o_alu_sel1, o_alu_sel2, o_wb_sel} = {6{1'bX}};
            o_alu_op = {4{1'bX}}; 
            o_cmp_op = {3{1'bX}};          
        end
    endcase
end

endmodule