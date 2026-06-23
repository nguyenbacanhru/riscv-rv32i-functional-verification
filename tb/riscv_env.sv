`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_env extends uvm_env;

  `uvm_component_utils(riscv_env)

  riscv_agent             agent;
  riscv_scoreboard        sb;
  riscv_cov               cov;
  riscv_virtual_sequencer vseqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = riscv_agent::type_id::create("agent", this);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "agent", "is_active", UVM_ACTIVE);

    sb    = riscv_scoreboard::type_id::create("sb", this);
    cov   = riscv_cov::type_id::create("cov", this);
    vseqr = riscv_virtual_sequencer::type_id::create("vseqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    
    agent.mon.mon_analysis_port.connect(sb.analysis_export);
    agent.mon.mon_analysis_port.connect(cov.analysis_export);

    
    if (agent.seqr != null) begin
      vseqr.seqr = agent.seqr;   
    end
  endfunction

endclass : riscv_env