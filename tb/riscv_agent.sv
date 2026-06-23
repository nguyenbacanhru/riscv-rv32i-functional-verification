`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_agent extends uvm_agent;

  `uvm_component_utils(riscv_agent)

  riscv_driver    drv;
  riscv_monitor   mon;
  riscv_sequencer seqr;          

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = riscv_monitor::type_id::create("mon", this);

    if (get_is_active() == UVM_ACTIVE) begin
      drv  = riscv_driver::type_id::create("drv", this);
      seqr = riscv_sequencer::type_id::create("seqr", this);  
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass : riscv_agent