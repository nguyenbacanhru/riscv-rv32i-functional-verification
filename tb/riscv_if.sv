

interface riscv_if(input logic clk);

  
  logic        rst;
  logic [31:0] instr;
  logic [31:0] pc;
  logic [31:0] alu_out;
  logic [31:0] mem_addr;
  logic [31:0] mem_wdata;
  logic [31:0] mem_rdata;
  logic        mem_we;

  logic [31:0] regfile_out [0:31];
  logic [31:0] regfile [0:31];
  logic [31:0] regfile_delayed [0:31];

  
  property p_x0_always_zero;
    @(posedge clk) (regfile_out[0] == 32'h0);
  endproperty

  AST_X0_ALWAYS_ZERO : assert property (p_x0_always_zero)
    else $error("[AST-1 FAIL] x0 (zero register) bi ghi != 0! gia tri = %0h, tai PC = %0h",
                regfile_out[0], pc);


  
  property p_pc_word_aligned;
    @(posedge clk) disable iff (rst)
    (pc[1:0] == 2'b00);
  endproperty

  AST_PC_WORD_ALIGNED : assert property (p_pc_word_aligned)
    else $error("[AST-2 FAIL] PC khong word-aligned! PC = %0h, pc[1:0] = %0b",
                pc, pc[1:0]);


  
  property p_reset_pc_zero;
    @(posedge clk) $rose(rst) |=> (pc == 32'h0);
  endproperty

  AST_RESET_PC_ZERO : assert property (p_reset_pc_zero)
    else $error("[AST-3 FAIL] PC phai = 0 sau reset! PC hien tai = %0h", pc);


 
  property p_mem_we_only_on_sw;
    @(posedge clk) disable iff (rst)
    mem_we |-> (instr[6:0] == 7'b0100011);
  endproperty

  AST_MEM_WE_ONLY_ON_SW : assert property (p_mem_we_only_on_sw)
    else $error("[AST-4 FAIL] mem_we=1 nhung opcode = %0b (khong phai SW)! instr = %0h, tai PC = %0h",
                instr[6:0], instr, pc);


  
  property p_reset_mem_we_zero;
    @(posedge clk) rst |-> (mem_we == 1'b0);
  endproperty

  AST_RESET_MEM_WE_ZERO : assert property (p_reset_mem_we_zero)
    else $error("[AST-5 FAIL] mem_we = 1 trong khi dang reset! instr = %0h", instr);

  
endinterface