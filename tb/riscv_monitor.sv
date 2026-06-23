`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;

class riscv_monitor extends uvm_monitor;
  `uvm_component_utils(riscv_monitor)

  virtual riscv_if vif;

  uvm_analysis_port #(riscv_seq_item) mon_analysis_port;

  function new(string name = "riscv_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface not found!")
  endfunction

  virtual task run_phase(uvm_phase phase);
    riscv_seq_item item;
    super.run_phase(phase);

    forever begin
      @(posedge vif.clk);
      #2;   

      item = riscv_seq_item::type_id::create("item");

      item.instr   = vif.instr;
      item.pc      = vif.pc;
      item.rd      = vif.instr[11:7];
      item.rs1     = vif.instr[19:15];
      item.rs2     = vif.instr[24:20];

      
      item.rd_val  = vif.regfile_out[item.rd];

      
      item.rs1_val = vif.regfile_delayed[item.rs1];
      item.rs2_val = vif.regfile_delayed[item.rs2];

      
      item.mem_rdata_val = vif.mem_rdata;

      `uvm_info(get_type_name(),
        $sformatf("Sampled Instr=%08h PC=%0h rd=%0d rs1=%0d rs2=%0d rd_val=%08h",
                  item.instr, item.pc, item.rd, item.rs1, item.rs2, item.rd_val),
        UVM_LOW)

      mon_analysis_port.write(item);
    end
  endtask

endclass : riscv_monitor