`include "uvm_macros.svh"
import uvm_pkg::*;



class riscv_base_sequence extends uvm_sequence #(riscv_seq_item);

  `uvm_object_utils(riscv_base_sequence)

  function new(string name = "riscv_base_sequence");
    super.new(name);
  endfunction

  
  task send(bit [31:0] enc);
    riscv_seq_item item;
    item = riscv_seq_item::type_id::create("item");
    start_item(item);
    item.instr = enc;
    finish_item(item);
  endtask

  task body();
    int i, j;
    bit [4:0] r_rd, r_rs1, r_rs2;

    
    `uvm_info("SEQ", "Phase 1: Init ALL registers x1..x31", UVM_LOW)
    for (i = 1; i <= 31; i++) begin
      
      send({ i[11:0], 5'd0, 3'b000, i[4:0], `OPCODE_I });
    end

    
    `uvm_info("SEQ", "Phase 2: funct3 sweep", UVM_LOW)
    for (i = 0; i <= 7; i++) begin
      
      send({7'b0000000, 5'd2, 5'd1, i[2:0], 5'd20, `OPCODE_R});
      
      send({12'd5,            5'd1, i[2:0], 5'd21, `OPCODE_I});
      
      send({12'h004,          5'd0, i[2:0], 5'd22, `OPCODE_L});
      
      send({7'b0000000, 5'd1, 5'd0, i[2:0], 5'd0,  `OPCODE_S});
    end

    
    `uvm_info("SEQ", "Phase 3: IMM bins warm-up", UVM_LOW)
    
    send({12'd0,   5'd1, 3'b000, 5'd30, `OPCODE_I});
    
    send({12'd15,  5'd2, 3'b000, 5'd30, `OPCODE_I});
    
    send({12'd500, 5'd3, 3'b000, 5'd30, `OPCODE_I});
    
    send({12'hFFF, 5'd4, 3'b000, 5'd30, `OPCODE_I});
    send({12'hF00, 5'd5, 3'b000, 5'd30, `OPCODE_I});
    send({12'h800, 5'd6, 3'b000, 5'd30, `OPCODE_I});

    
    `uvm_info("SEQ", "Phase 4: Full 32x32 rs1 x rs2 sweep (R-type)", UVM_LOW)
    for (i = 0; i <= 31; i++) begin
      for (j = 0; j <= 31; j++) begin
        r_rs1 = i[4:0];
        r_rs2 = j[4:0];
        r_rd  = ((i * 32 + j) % 31) + 1;  
        
        send({7'b0000000, r_rs2, r_rs1, 3'b000, r_rd, `OPCODE_R});
      end
    end

    
    `uvm_info("SEQ", "Phase 5a: opcode x rd sweep", UVM_LOW)
    for (i = 0; i <= 31; i++) begin
      r_rd = i[4:0];

      
      send({7'b0000000, 5'd3, 5'd2, 3'b000, r_rd, `OPCODE_R});

      
      send({12'd7, 5'd1, 3'b000, r_rd, `OPCODE_I});

      
      send({12'h004, 5'd0, 3'b010, r_rd, `OPCODE_L});

     
      send({7'b0000000, 5'd1, 5'd0, 3'b010, r_rd, `OPCODE_S});
    end

    
    `uvm_info("SEQ", "Phase 5b: S-type rs1 sweep", UVM_LOW)
    for (i = 0; i <= 31; i++) begin
      
      send({7'b0000000, 5'd1, i[4:0], 3'b010, 5'd0, `OPCODE_S});
    end

    
    `uvm_info("SEQ", "Phase 6: opcode x rs2/imm[4:0] sweep", UVM_LOW)
    for (i = 0; i <= 31; i++) begin
      r_rs2 = i[4:0];
      r_rd  = (i % 31) + 1;  
      
      send({7'b0000000, r_rs2, 5'd1, 3'b000, r_rd, `OPCODE_R});

      
      send({7'b0000000, r_rs2, 5'd0, 3'b010, 5'd0, `OPCODE_S});

      
      send({7'b0000000, r_rs2, 5'd1, 3'b000, r_rd, `OPCODE_I});

      
      send({7'b0000000, r_rs2, 5'd0, 3'b010, r_rd, `OPCODE_L});
    end

    
    `uvm_info("SEQ", "Phase 7: opcode x imm cross", UVM_LOW)
    begin
      
      bit [11:0] imm_v[4];
      imm_v[0] = 12'd0;    
      imm_v[1] = 12'd10;   
      imm_v[2] = 12'd200;  
      imm_v[3] = 12'hF00;  

      for (i = 0; i < 4; i++) begin
        
        send({imm_v[i], 5'd1, 3'b000, 5'd27, `OPCODE_I});

        
        send({imm_v[i], 5'd0, 3'b010, 5'd28, `OPCODE_L});

       
        send({imm_v[i][11:5], 5'd1, 5'd0, 3'b010, imm_v[i][4:0], `OPCODE_S});

        
        send({imm_v[i][11:5], imm_v[i][4:0], 5'd1, 3'b000, 5'd29, `OPCODE_R});
      end
    end

    
    `uvm_info("SEQ", "Phase 8: cp_sub bit coverage (ADD + SUB)", UVM_LOW)
    
    send({7'b0000000, 5'd2, 5'd1, 3'b000, 5'd10, `OPCODE_R});
    
    send({7'b0100000, 5'd2, 5'd1, 3'b000, 5'd11, `OPCODE_R});

    
    `uvm_info("SEQ", "Phase 9: funct3 x opcode full sweep", UVM_LOW)
    for (i = 0; i <= 7; i++) begin
      
      send({7'b0000000, 5'd2, 5'd1, i[2:0], 5'd1, `OPCODE_R});
      
      send({12'd1,            5'd1, i[2:0], 5'd2, `OPCODE_I});
      
      send({12'h000,          5'd0, i[2:0], 5'd3, `OPCODE_L});
      
      send({7'b0000000, 5'd1, 5'd0, i[2:0], 5'd0, `OPCODE_S});
    end

   
    `uvm_info("SEQ", "Phase 10: Extra neg imm sweep across opcodes", UVM_LOW)
    begin
      
      send({12'h800, 5'd1, 3'b000, 5'd5,  `OPCODE_I});
      send({12'h800, 5'd0, 3'b010, 5'd6,  `OPCODE_L});
      send({7'b1000000, 5'd1, 5'd0, 3'b010, 5'b00000, `OPCODE_S});
      
      send({7'b1000000, 5'b00000, 5'd1, 3'b000, 5'd7, `OPCODE_R});

      
      send({12'hFFF, 5'd2, 3'b000, 5'd8,  `OPCODE_I});
      send({12'hFFF, 5'd0, 3'b010, 5'd9,  `OPCODE_L});
      send({7'b1111111, 5'd1, 5'd0, 3'b010, 5'b11111, `OPCODE_S});
      send({7'b1111111, 5'b11111, 5'd1, 3'b000, 5'd10, `OPCODE_R});
    end

    
    `uvm_info("SEQ", "Phase 11: pos_large imm x all opcodes", UVM_LOW)
    begin
      
      send({12'd100, 5'd1, 3'b000, 5'd12, `OPCODE_I});
      send({12'd100, 5'd0, 3'b010, 5'd13, `OPCODE_L});
      send({7'b0000011, 5'd1, 5'd0, 3'b010, 5'b00100, `OPCODE_S}); 
      send({7'b0000011, 5'b00100, 5'd1, 3'b000, 5'd14, `OPCODE_R});

      
      send({12'd2047, 5'd1, 3'b000, 5'd15, `OPCODE_I});
      send({12'd2047, 5'd0, 3'b010, 5'd16, `OPCODE_L});
      send({7'b0111111, 5'd1, 5'd0, 3'b010, 5'b11111, `OPCODE_S});
      send({7'b0111111, 5'b11111, 5'd1, 3'b000, 5'd17, `OPCODE_R});
    end

    
    `uvm_info("SEQ", "Phase 12: pos_small imm x all opcodes", UVM_LOW)
    begin
      bit [4:0] rd_tmp;
      for (i = 1; i <= 31; i++) begin
       
        rd_tmp = i[4:0];  
        send({i[11:0], 5'd1, 3'b000, rd_tmp, `OPCODE_I});
      end
      
      send({12'd1,  5'd0, 3'b010, 5'd20, `OPCODE_L});
      send({12'd31, 5'd0, 3'b010, 5'd21, `OPCODE_L});
      
      for (i = 1; i <= 7; i++) begin
        send({7'b0000000, 5'd1, 5'd0, 3'b010, i[4:0], `OPCODE_S});
      end
      
      for (i = 1; i <= 7; i++) begin
        rd_tmp = i[4:0];  
        send({7'b0000000, i[4:0], 5'd1, 3'b000, rd_tmp, `OPCODE_R});
      end
    end

    `uvm_info("SEQ", "Sequence completed", UVM_LOW)
  endtask

endclass : riscv_base_sequence