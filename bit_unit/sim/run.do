view wave -title wave_1

clear
vlib  work
vdel -all
vlog -f files.f ../src/tb_cpu/top.v -dbg 
vsim +access+r top -dbg

framework.window.activate -window wave_1

wave sim:/top/*
wave sim:/top/cpu_uut/ctrl_inst/*

run -all