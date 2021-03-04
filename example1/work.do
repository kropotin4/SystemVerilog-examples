transcript on

vlib work

<!-- book 1 price -->
vlog -sv +incdir+./ ./add.sv
vlog -sv +incdir+./ ./tb.sv

vsim -voptargs="+acc" tb