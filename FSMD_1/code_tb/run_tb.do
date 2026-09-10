quit -sim
.main clear
vlib work

vlog ../FSMD_1_K2/code_rtl/*.v
vlog ../FSMD_1_K3/code_rtl/*.v
vlog ../FSMD_1_K4/code_rtl/*.v
vlog *.v

vsim -voptargs="+acc" work.FSMD_1_tb

run -all