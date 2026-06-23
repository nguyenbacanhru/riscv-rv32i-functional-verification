`include "riscv_defines.sv"

module riscv_cpu (
  input  logic        clk,
  input  logic        rst,
  input  logic [31:0] instr,
  output logic [31:0] pc,
  output logic [31:0] alu_out,
  output logic [31:0] mem_addr,
  output logic [31:0] mem_wdata,
  input  logic [31:0] mem_rdata,
  output logic        mem_we,

  
  output logic [31:0] regfile_out [0:31]
);

  logic [31:0] regfile [0:31];
  logic [31:0] alu_result;

  logic [6:0] opcode;
  logic [4:0] rd, rs1, rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] imm_i, imm_s;

  assign opcode = instr[6:0];
  assign rd     = instr[11:7];
  assign rs1    = instr[19:15];
  assign rs2    = instr[24:20];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

  assign imm_i = {{20{instr[31]}}, instr[31:20]};
  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

  
  always_comb begin
    mem_addr  = 32'h0;
    mem_wdata = 32'h0;
    mem_we    = 1'b0;
    case (opcode)
      `OPCODE_L: mem_addr = regfile[rs1] + imm_i;
      `OPCODE_S: begin
        mem_addr  = regfile[rs1] + imm_s;
        mem_wdata = regfile[rs2];
        mem_we    = 1'b1;
      end
      default: ;
    endcase
  end

  
  always_comb begin
    alu_result = 32'h0;
    case (opcode)
      `OPCODE_R: begin
        case ({funct7[5], funct3})
          {1'b0, 3'b000}: alu_result = regfile[rs1] + regfile[rs2];  // ADD
          {1'b1, 3'b000}: alu_result = regfile[rs1] - regfile[rs2];  // SUB
          {1'b0, 3'b111}: alu_result = regfile[rs1] & regfile[rs2];  // AND
          {1'b0, 3'b110}: alu_result = regfile[rs1] | regfile[rs2];  // OR
          default: ;
        endcase
      end
      `OPCODE_I: alu_result = regfile[rs1] + imm_i;   // ADDI
      `OPCODE_L: alu_result = mem_rdata;               // LW result
      default: ;
    endcase
  end

  
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      pc      <= 32'h0;
      alu_out <= 32'h0;
      foreach (regfile[i])      regfile[i]      <= 32'h0;
      foreach (regfile_out[i])  regfile_out[i]  <= 32'h0;
    end else begin
      pc      <= pc + 4;
      alu_out <= alu_result;

      
      case (opcode)
        `OPCODE_R, `OPCODE_I:
          if (rd != 0) regfile[rd] <= alu_result;
        `OPCODE_L:
          if (rd != 0) regfile[rd] <= mem_rdata;
        default: ;
      endcase

      
      foreach (regfile_out[i]) regfile_out[i] <= regfile[i];
      if (rd != 0) begin
        case (opcode)
          `OPCODE_R, `OPCODE_I: regfile_out[rd] <= alu_result;
          `OPCODE_L:            regfile_out[rd] <= mem_rdata;
          default: ;
        endcase
      end
    end
  end

endmodule