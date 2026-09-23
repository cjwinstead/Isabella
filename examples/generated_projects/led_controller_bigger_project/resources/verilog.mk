XVLOG_OPTIONS=-sv
OUTFILTER=grep --color=always -e "ERROR.*" -e "CRIT.*" -e "WARN.*" 

export ROOT?=$(shell git rev-parse --show-toplevel)
export RSRC?=$(ROOT)/resources

all: compile elaborate simulate

.PHONY: compile
.PHONY: elaborate
.PHONY: simulate

TESTBENCH?=testbench
OUTFILTER=grep --color=always -e "ERROR.*" -e "CRIT.*" -e "WARN.*" 
SRCS=$(wildcard src/*.v) $(wildcard tests/*.v)

compile: $(SRCS)
	@ printf "xvlog $(XVLOG_OPTIONS) src/*.v\n"
	@! xvlog $(XVLOG_OPTIONS) src/*.v | $(OUTFILTER)
	-@! if [ -d tests/ ]; then xvlog $(XVLOG_OPTIONS) tests/*.v | $(OUTFILTER); fi

elaborate: compile
	@ printf "xelab -debug typical -s sim testbench\n"
	@! xelab -debug typical -s sim $(TESTBENCH) | $(OUTFILTER)

simulate: elaborate
	@ printf "xsim --runall sim\n"
	@ xsim --runall sim


gui: elaborate
	@ printf "xsim --gui sim\n"
	@ xsim --gui sim 


implement:
	@ if [ -e build.tcl ]; then vivado -mode batch -source build.tcl; \
	else vivado -mode batch -source $(RSRC)/build.tcl; fi

check: 
	@ vivado -mode batch -source $(RSRC)/check_syntax.tcl 

clean:
	@rm -f *.jou
	@rm -f *.log
	@rm -f *.history
	@rm -Rf INCA_libs
	@rm -Rf xsim.dir
	@rm -f *.pb
	@rm -f *.wdb
	@rm -f *.pb
	@rm -f *.rpt
	@rm -f post_*
	@rm -f *_webtalk.*
	@rm -Rf .Xil
	@rm -f *.bit
	@rm -f *~
	@rm -f src/*~

