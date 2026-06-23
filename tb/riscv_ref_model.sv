`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_ref_model extends uvm_object;

  `uvm_object_utils(riscv_ref_model)

  bit [31:0] regfile[0:31];

  function new(string name = "riscv_ref_model");
    super.new(name);
    foreach(regfile[i]) regfile[i] = 32'h0;
  endfunction

  function bit [31:0] predict(riscv_seq_item item);
    logic [6:0] opcode = item.instr[6:0];
    logic [2:0] funct3 = item.instr[14:12];
    logic       sub    = item.instr[30];     
    logic [4:0] rd     = item.instr[11:7];
    logic [4:0] rs1    = item.instr[19:15];
    logic [4:0] rs2    = item.instr[24:20];

    logic [31:0] imm_i = {{20{item.instr[31]}}, item.instr[31:20]};
    logic [31:0] imm_s = {{20{item.instr[31]}}, item.instr[31:25], item.instr[11:7]};

    bit [31:0] result = 0;

    case (opcode)
      `OPCODE_R: begin
        if (funct3 == `FUNCT3_ADD && sub == 0) result = item.rs1_val + item.rs2_val;
        else if (funct3 == `FUNCT3_SUB && sub == 1) result = item.rs1_val - item.rs2_val;
        else if (funct3 == `FUNCT3_AND) result = item.rs1_val & item.rs2_val;
        else if (funct3 == `FUNCT3_OR)  result = item.rs1_val | item.rs2_val;
      end

      `OPCODE_I: result = item.rs1_val + imm_i;
      `OPCODE_L: result = item.mem_rdata_val;   
      `OPCODE_S: ;                              
      default: ;
    endcase

    if (rd != 0) regfile[rd] = result;
    return result;
  endfunction

endclass : riscv_ref_model