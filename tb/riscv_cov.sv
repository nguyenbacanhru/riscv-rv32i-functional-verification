`include "uvm_macros.svh"
import uvm_pkg::*;



class riscv_cov extends uvm_subscriber #(riscv_seq_item);

  `uvm_component_utils(riscv_cov)

  riscv_seq_item item;

  
  covergroup cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.at_least     = 1;

       
    cp_opcode: coverpoint item.instr[6:0] {
      bins r = {`OPCODE_R};
      bins i = {`OPCODE_I};
      bins l = {`OPCODE_L};
      bins s = {`OPCODE_S};
    }
  
    cp_funct3: coverpoint item.instr[14:12] {
      bins f3[] = {[0:7]};
    }
 
    cp_sub: coverpoint item.instr[30] {
      bins add = {0};
      bins sub = {1};
    }

    cp_rd: coverpoint item.instr[11:7] {
      bins all[] = {[0:31]};
    }

    cp_rs1: coverpoint item.instr[19:15] {
      bins all[] = {[0:31]};
    }

    cp_rs2: coverpoint item.instr[24:20] {
      bins all[] = {[0:31]};
    }

    cp_imm: coverpoint signed'(item.instr[31:20]) {
      bins zero      = {0};
      bins pos_small = {[1:31]};
      bins pos_large = {[32:2047]};
      bins neg       = {[-2048:-1]};
    }

    cross_opcode_funct3: cross cp_opcode, cp_funct3 {
      option.weight = 0;
    }

    cross_opcode_rd: cross cp_opcode, cp_rd;

    cross_opcode_rs2: cross cp_opcode, cp_rs2;

    cross_rs1_rs2: cross cp_rs1, cp_rs2;

    cross_opcode_imm: cross cp_opcode, cp_imm;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg   = new();
    item = new();
  endfunction

  function void write(riscv_seq_item t);
    item = t;
    cg.sample();
  endfunction

endclass : riscv_cov