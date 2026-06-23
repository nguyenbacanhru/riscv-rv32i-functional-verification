`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_virtual_sequence extends uvm_sequence;

  `uvm_object_utils(riscv_virtual_sequence)
  `uvm_declare_p_sequencer(riscv_virtual_sequencer)

  riscv_config         cfg;
  riscv_base_sequence  base_seq;

  function new(string name = "riscv_virtual_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info("VSEQ", "Starting virtual sequence", UVM_LOW)

    cfg = riscv_config::type_id::create("cfg");
    assert(cfg.randomize()) else
      `uvm_error("VSEQ", "Failed to randomize config");

    base_seq = riscv_base_sequence::type_id::create("base_seq");
    base_seq.start(p_sequencer.seqr);

    `uvm_info("VSEQ",
      $sformatf("Virtual sequence completed (cfg.num_transactions=%0d)",
                cfg.num_transactions),
      UVM_LOW)
  endtask

endclass : riscv_virtual_sequence