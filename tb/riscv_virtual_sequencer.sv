`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(riscv_virtual_sequencer)

  
  riscv_sequencer seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass : riscv_virtual_sequencer