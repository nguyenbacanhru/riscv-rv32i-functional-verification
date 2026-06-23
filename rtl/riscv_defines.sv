`ifndef RISCV_DEFINES_SV
`define RISCV_DEFINES_SV

`define OPCODE_R     7'b0110011
`define OPCODE_I     7'b0010011
`define OPCODE_L     7'b0000011
`define OPCODE_S     7'b0100011

`define FUNCT3_ADD   3'b000
`define FUNCT3_SUB   3'b000
`define FUNCT3_AND   3'b111
`define FUNCT3_OR    3'b110
`define FUNCT3_LW    3'b010
`define FUNCT3_SW    3'b010

`endif