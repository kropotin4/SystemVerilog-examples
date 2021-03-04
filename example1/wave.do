transcript on

vlib work

vlog -sv +incdir+./ ./add.sv
vlog -sv +incdir+./ ./tb.sv

vsim -voptargs="+acc" tb