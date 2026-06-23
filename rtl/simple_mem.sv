module simple_mem(
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] addr,
  input  logic [31:0] wdata,
  output logic [31:0] rdata
);
  logic [31:0] mem [0:255];  // 1KB memory

 
  integer j;
  initial begin
    for (j = 0; j < 256; j = j + 1)
      mem[j] = 32'h0;
  end

  always @(posedge clk) begin
    if (we)
      mem[addr[9:2]] <= wdata;
  end

  assign rdata = mem[addr[9:2]];

endmodule