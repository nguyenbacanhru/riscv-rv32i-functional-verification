
catch {vdel -all -lib work}
vlib work
vmap work work

# ====================== COMPILE ======================
# +cover : bat thu thap Code Coverage (statement, branch, condition, toggle)
vlog -sv +cover -f filelist.f

# ====================== SIMULATION ======================
# -coverage : kich hoat ghi nhan code coverage trong qua trinh chay
vsim -voptargs="+acc" -coverage work.tb_top +UVM_TESTNAME=riscv_test

# ====================== WAVEFORM SETUP ======================

add wave -divider "=== CLOCK & RESET ==="
add wave -group "Clock_Reset" tb_top/clk tb_top/vif/rst

add wave -divider "=== INSTRUCTION & PC ==="
add wave tb_top/vif/instr
add wave tb_top/vif/pc

add wave -divider "=== ALU & RESULT ==="
add wave tb_top/vif/alu_out
add wave tb_top/dut/alu_result

add wave -divider "=== MEMORY INTERFACE ==="
add wave tb_top/vif/mem_addr
add wave tb_top/vif/mem_wdata
add wave tb_top/vif/mem_rdata
add wave tb_top/vif/mem_we

add wave -divider "=== REGFILE (Post-Writeback) ==="
add wave -group "Regfile" tb_top/vif/regfile_out

add wave -divider "=== UVM Items ==="
add wave -group "Monitor_Item" tb_top/vif/instr tb_top/vif/pc

# ====================== COVERAGE ======================
coverage save -onexit riscv_coverage.ucdb

# ====================== RUN SIMULATION ======================
run -all

# Luu thu cong sau khi run -all de dam bao co du ca code coverage
coverage save riscv_coverage.ucdb

# ====================== XUAT CODE COVERAGE REPORT ======================
# Xoa thu muc cu neu da ton tai de tranh loi "directory already exists"
file delete -force coverage_report

# Xuat HTML report de xem bang trinh duyet (co ca code coverage va functional coverage)
vcover report -html -htmldir coverage_report -code bcst -cvg riscv_coverage.ucdb

# In tom tat code coverage ra Transcript
vcover report -code bcst riscv_coverage.ucdb

# ====================== FINAL SETUP ======================
wave zoom full
config wave -signalnamewidth 1
radix -hexadecimal

echo "============================================================="
echo "Simulation completed successfully!"
echo "Coverage database saved as: riscv_coverage.ucdb"
echo "Code Coverage HTML report saved in: coverage_report/"
echo "Open coverage_report/index.html in a browser to view details"
echo "============================================================="
