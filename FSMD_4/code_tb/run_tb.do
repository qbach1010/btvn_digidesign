quit -sim
.main clear
vlib work

vlog ../FSMD_4_P1/code_rtl/*.v
vlog ../FSMD_4_P2/code_rtl/*.v
vlog *.v

vsim -voptargs="+acc" work.FSMD_4_tb

run -all