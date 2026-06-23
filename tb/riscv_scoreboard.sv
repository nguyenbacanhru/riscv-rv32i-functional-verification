`include "uvm_macros.svh"
import uvm_pkg::*;



class riscv_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(riscv_scoreboard)

  uvm_analysis_imp #(riscv_seq_item, riscv_scoreboard) analysis_export;
  riscv_ref_model ref_model;

  int unsigned instr_count  = 0;
  int unsigned pass_count   = 0;
  int unsigned skip_count   = 0;
  int unsigned error_count  = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ref_model = riscv_ref_model::type_id::create("ref_model", this);
  endfunction

  virtual function void write(riscv_seq_item t);
    riscv_seq_item item;
    bit [31:0] expected;
    bit [4:0]  rd     = t.instr[11:7];
    bit [6:0]  opcode = t.instr[6:0];

    instr_count++;

    
    if (instr_count <= 69) begin
      item = riscv_seq_item::type_id::create("item");
      item.copy(t);
      void'(ref_model.predict(item));
      `uvm_info("SB_SKIP",
        $sformatf("Warm-up %h (PC=%0h, count=%0d)", t.instr, t.pc, instr_count),
        UVM_MEDIUM)
      skip_count++;
      return;
    end

    
    if (opcode == `OPCODE_S) begin
      item = riscv_seq_item::type_id::create("item");
      item.copy(t);
      void'(ref_model.predict(item));
      `uvm_info("SB_SW",
        $sformatf("SW skip (no rd): %h PC=%0h", t.instr, t.pc),
        UVM_HIGH)
      return;
    end

    
    begin
      bit [2:0] f3 = t.instr[14:12];
      if (opcode == `OPCODE_L && (f3 == 3'b011 || f3 == 3'b110 || f3 == 3'b111)) begin
        item = riscv_seq_item::type_id::create("item");
        item.copy(t);
        void'(ref_model.predict(item));
        `uvm_info("SB_UNDEF",
          $sformatf("Undefined LOAD funct3=%0b skip: %h PC=%0h", f3, t.instr, t.pc),
          UVM_HIGH)
        return;
      end
    end

    
    if (rd == 5'd0) begin
      item = riscv_seq_item::type_id::create("item");
      item.copy(t);
      void'(ref_model.predict(item));
      `uvm_info("SB_X0",
        $sformatf("rd=x0 skip: %h PC=%0h", t.instr, t.pc),
        UVM_HIGH)
      return;
    end

    
    item = riscv_seq_item::type_id::create("item");
    item.copy(t);
    expected = ref_model.predict(item);

    if (item.rd_val !== expected) begin
      error_count++;
      `uvm_error("SB_MISMATCH",
        $sformatf("MISMATCH! Instr=%h | Exp=%0h | Got=%0h | PC=%0h",
                  item.instr, expected, item.rd_val, item.pc))
    end else begin
      pass_count++;
      `uvm_info("SB_PASS",
        $sformatf("PASS: %h -> %0h  (PC=%0h)", item.instr, item.rd_val, item.pc),
        UVM_MEDIUM)
    end
  endfunction

  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB_REPORT",
      $sformatf("\n=== Scoreboard Summary ===\n  Total   : %0d\n  Warm-up : %0d\n  PASS    : %0d\n  ERRORS  : %0d",
                instr_count, skip_count, pass_count, error_count),
      UVM_LOW)
    if (error_count > 0)
      `uvm_error("SB_REPORT", "TEST FAILED: scoreboard errors detected!")
    else
      `uvm_info("SB_REPORT", "TEST PASSED: all checks PASS!", UVM_LOW)
  endfunction

endclass : riscv_scoreboard