`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_config extends uvm_object;

  `uvm_object_utils(riscv_config)

  rand int unsigned num_transactions;

  
  constraint reasonable {
    num_transactions inside {[1400:1500]};
  }

  constraint soft_default {
    soft num_transactions == 1400;
  }

  function new(string name = "riscv_config");
    super.new(name);
  endfunction

endclass : riscv_config