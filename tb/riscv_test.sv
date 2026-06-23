`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_test extends uvm_test;

  `uvm_component_utils(riscv_test)

  riscv_env env;
  riscv_virtual_sequence vseq;

  function new(string name="riscv_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = riscv_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    vseq = riscv_virtual_sequence::type_id::create("vseq");
    vseq.start(env.vseqr);

    phase.drop_objection(this);
  endtask

endclass