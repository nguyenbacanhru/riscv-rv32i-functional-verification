`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_driver extends uvm_driver #(riscv_seq_item);

  `uvm_component_utils(riscv_driver)

  virtual riscv_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Virtual interface not found!")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

      
      @(negedge vif.clk);
      vif.instr <= req.instr;

      @(posedge vif.clk);        
      seq_item_port.item_done();
    end
  endtask

endclass : riscv_driver