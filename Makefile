# Makefile

.default: usage

usage:
		@echo "Usage:"
		@echo "run-ex1   - run example 1"
		@echo "run-ex2   - run example 2"
		@echo "run-ex3   - run example 3"
		@echo "clean     - clean temp files"
		@echo "clean-all - clean temp files in all directories"


run-ex1:
		cd example1/ && questasim -do work.do

run-ex2:
		cd example2/ && questasim -do work.do

run-ex3:
		cd example3/ && questasim -do work.do


clean:
		rm -rf *.wlf transcript
		rm -rf work/


clean-all:
		make clean
		cd example1/ && make clean
		cd example2/ && make clean