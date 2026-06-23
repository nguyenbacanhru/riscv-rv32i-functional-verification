`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_seq_item extends uvm_sequence_item;

  rand bit [31:0] instr;

  
  bit [31:0] pc;
  bit [4:0]  rd;
  bit [4:0]  rs1;
  bit [4:0]  rs2;
  bit [31:0] rd_val;
  bit [31:0] rs1_val;
  bit [31:0] rs2_val;
  bit [31:0] mem_addr_val;
  bit [31:0] mem_wdata_val;
  bit [31:0] mem_rdata_val;
  bit        mem_we_val;

  `uvm_object_utils_begin(riscv_seq_item)
    `uvm_field_int(instr,    UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(pc,       UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rd,       UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rs1,      UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rs2,      UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rd_val,   UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rs1_val,  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rs2_val,  UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  function new(string name = "riscv_seq_item");
    super.new(name);
  endfunction

  
  constraint valid_rv32 {
    instr[1:0] == 2'b11;           
  }

  constraint instr_type_dist {
    instr[6:0] dist {
      `OPCODE_R := 40,
      `OPCODE_I := 30,
      `OPCODE_L := 15,
      `OPCODE_S := 15
    };
  }

endclass : riscv_seq_item