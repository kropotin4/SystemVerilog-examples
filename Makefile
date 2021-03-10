# Makefile

.default: usage

usage:
		@echo "Usage:"
		@echo "run-ex1   - run example 1"
		@echo "run-ex2   - run example 2"
		@echo "clean-all - clean temp files"


run-ex1:
		cd example1/ && questasim -do work.do


run-ex2:
		cd example2/ && questasim -do work.do


clean-all:
		rm -rf *.wlf transcript
		rm -rf work/