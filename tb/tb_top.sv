`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;

module tb_top;

  logic clk = 0;
  riscv_if vif(clk);

  
  riscv_cpu dut (
    .clk       (clk),
    .rst       (vif.rst),
    .instr     (vif.instr),
    .pc        (vif.pc),
    .alu_out   (vif.alu_out),
    .mem_addr  (vif.mem_addr),
    .mem_wdata (vif.mem_wdata),
    .mem_rdata (vif.mem_rdata),
    .mem_we    (vif.mem_we),
    .regfile_out(vif.regfile_out)  
  );

  simple_mem mem (
    .clk   (clk),
    .we    (vif.mem_we),
    .addr  (vif.mem_addr),
    .wdata (vif.mem_wdata),
    .rdata (vif.mem_rdata)
  );

  
  always_ff @(posedge clk) begin
    vif.regfile_delayed <= vif.regfile_out;
  end

  
  assign vif.regfile = vif.regfile_out;

  
  always #5 clk = ~clk;

  
  initial begin
    vif.rst = 1;
    #25 vif.rst = 0;
  end

  
  initial begin
    uvm_config_db#(virtual riscv_if)::set(null, "*", "vif", vif);
    run_test("riscv_test");
  end

  initial begin
    $dumpfile("riscv_tb.vcd");
    $dumpvars(0, tb_top);
  end

endmodule