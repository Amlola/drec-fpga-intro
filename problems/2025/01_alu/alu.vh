`ifndef ALU_VH
`define ALU_VH

`define ALU_OP_WIDTH 4
`define SHIFT_WIDTH 5

`define ALU_ADD  `ALU_OP_WIDTH'd0
`define ALU_SUB  `ALU_OP_WIDTH'd1
`define ALU_OR   `ALU_OP_WIDTH'd2
`define ALU_AND  `ALU_OP_WIDTH'd3
`define ALU_XOR  `ALU_OP_WIDTH'd4
`define ALU_SRL  `ALU_OP_WIDTH'd5
`define ALU_SRA  `ALU_OP_WIDTH'd6
`define ALU_SLL  `ALU_OP_WIDTH'd7
`define ALU_SLT  `ALU_OP_WIDTH'd8
`define ALU_SLTU `ALU_OP_WIDTH'd9

`endif // ALU_VH