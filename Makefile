VCS = SW_VCS=2017.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 -debug_access+all 
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

HEADERS     = $(wildcard *.svh)
SIMFILES  = circ.sv
TESTBENCH = circ_tb.sv
SYNFILES  = synth_out/free_list.vg
PIPEFILES = synth_out/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.vg synth_out/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.vg synth_out/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.vg

# $(wildcard synth_out/*.vg)
# synth_out/free_list.vg synth_out/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.vg synth_out/priority_selector_SEL_CNT3_WIDTH3_INVERT1.vg synth_out/priority_selector_module_WIDTH3.vg\
# 			 synth_out/binary_encoder_IN_WIDTH3_OUT_WIDTH2.vg synth_out/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.vg synth_out/priority_selector_SEL_CNT3_WIDTH32_INVERT1.vg\
# 			 synth_out/priority_selector_module_WIDTH32.vg synth_out/binary_encoder_IN_WIDTH32_OUT_WIDTH5.vg synth_out/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.vg\
# 			 synth_out/priority_selector_SEL_CNT32_WIDTH32_INVERT1.vg

export CLOCK_NET_NAME = clock
export RESET_NET_NAME = reset
export CLOCK_PERIOD   = 50

################################################################################
## RULES
################################################################################

# Default target
all: simv
	./simv | tee program.out

.PHONY: all

sim: simv $(ASSEMBLED)
	./simv | tee program.out

simv: $(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) $^ -o simv

syn_simv: sys_defs.svh ISA.svh $(SYNFILES) $(TESTBENCH)
	$(VCS) -xprop=tmerge $^ $(LIB) -o syn_simv

syn: syn_simv
	./syn_simv | tee syn_program.out

dve:	sim
	./simv -gui &

dve_syn: syn_simv
	./syn_simv -gui &


################################################################################
## Synthesis
################################################################################


# output_buffer_SIZE3.vg: verilog/output_buffer.sv synth_out/output_buffer.tcl priority_selector_SEL_CNT3_WIDTH3_INVERT1.vg
# 	dc_shell-t -f ../synth/synth_out/output_buffer.tcl | tee output_buffer_SIZE3.out
# 	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@


#####################################################FREE LIST##################################################################

# synth_out/free_list.vg: verilog/free_list.sv synth/free_list.tcl synth_out/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.vg synth_out/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.vg synth_out/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.vg
# 	mkdir -p synth_out
# 	cd synth_out && dc_shell-t -f ../synth/free_list.tcl | tee free_list.out
# 	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

synth_out/free_list.vg: verilog/free_list.sv synth/free_list.tcl $(PIPEFILES)
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/free_list.tcl | tee free_list.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

#sel3, width3, invert1
synth_out/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.vg: verilog/util/priority_encoder.sv synth_out/priority_selector_SEL_CNT3_WIDTH3_INVERT1.vg synth_out/binary_encoder_IN_WIDTH3_OUT_WIDTH2.vg synth/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_encoder_SEL_CNT3_WIDTH3_INVERT1.tcl | tee priority_encoder_SEL_CNT3_WIDTH3_INVERT1.out

synth_out/priority_selector_SEL_CNT3_WIDTH3_INVERT1.vg: verilog/util/priority_selector.sv synth_out/priority_selector_module_WIDTH3.vg synth/priority_selector_SEL_CNT3_WIDTH3_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_selector_SEL_CNT3_WIDTH3_INVERT1.tcl | tee priority_selector_SEL_CNT3_WIDTH3_INVERT1.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

synth_out/priority_selector_module_WIDTH3.vg: verilog/util/priority_selector_module.sv synth/priority_selector_module_WIDTH3.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_selector_module_WIDTH3.tcl | tee priority_selector_module_WIDTH3.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

synth_out/binary_encoder_IN_WIDTH3_OUT_WIDTH2.vg: verilog/util/binary_encoder.sv synth/binary_encoder_IN_WIDTH3_OUT_WIDTH2.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/binary_encoder_IN_WIDTH3_OUT_WIDTH2.tcl | tee binary_encoder_IN_WIDTH3_OUT_WIDTH2.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

#sel3, width32, invert1
synth_out/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.vg: verilog/util/priority_encoder.sv synth_out/priority_selector_SEL_CNT3_WIDTH32_INVERT1.vg synth_out/binary_encoder_IN_WIDTH32_OUT_WIDTH5.vg synth/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_encoder_SEL_CNT3_WIDTH32_INVERT1.tcl | tee priority_encoder_SEL_CNT3_WIDTH32_INVERT1.out

synth_out/priority_selector_SEL_CNT3_WIDTH32_INVERT1.vg: verilog/util/priority_selector.sv synth_out/priority_selector_module_WIDTH32.vg synth/priority_selector_SEL_CNT3_WIDTH32_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_selector_SEL_CNT3_WIDTH32_INVERT1.tcl | tee priority_selector_SEL_CNT3_WIDTH32_INVERT1.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

synth_out/priority_selector_module_WIDTH32.vg: verilog/util/priority_selector_module.sv synth/priority_selector_module_WIDTH32.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_selector_module_WIDTH32.tcl | tee priority_selector_module_WIDTH32.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

synth_out/binary_encoder_IN_WIDTH32_OUT_WIDTH5.vg: verilog/util/binary_encoder.sv synth/binary_encoder_IN_WIDTH32_OUT_WIDTH5.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/binary_encoder_IN_WIDTH32_OUT_WIDTH5.tcl | tee binary_encoder_IN_WIDTH32_OUT_WIDTH5.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

#sel32, width32, invert1
synth_out/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.vg: verilog/util/priority_encoder.sv synth_out/priority_selector_SEL_CNT32_WIDTH32_INVERT1.vg synth_out/binary_encoder_IN_WIDTH32_OUT_WIDTH5.vg synth/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_encoder_SEL_CNT32_WIDTH32_INVERT1.tcl | tee priority_encoder_SEL_CNT32_WIDTH32_INVERT1.out

synth_out/priority_selector_SEL_CNT32_WIDTH32_INVERT1.vg: verilog/util/priority_selector.sv synth_out/priority_selector_module_WIDTH32.vg synth/priority_selector_SEL_CNT32_WIDTH32_INVERT1.tcl
	mkdir -p synth_out
	cd synth_out && dc_shell-t -f ../synth/priority_selector_SEL_CNT32_WIDTH32_INVERT1.tcl | tee priority_selector_SEL_CNT32_WIDTH32_INVERT1.out
	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $@

#^^^uses a 32 width priority module and binary encoder^^

################################################END FREE LIST#####################################################

#$(PIPELINE): $(SIMFILES) $(SYNTH_DIR)/$(PIPELINE_NAME).tcl
# cd $(SYNTH_DIR) && dc_shell-t -f ../synth/./$(PIPELINE_NAME).tcl | tee $(PIPELINE_NAME)_synth.out
#	echo -e -n 'H\n1\ni\n`timescale 1ns/100ps\n.\nw\nq\n' | ed $(PIPELINE)

#syn_simv:	$(HEADERS) $(SYNFILES) $(TESTBENCH)
#	$(VCS) -xprop=tmerge  $^ $(LIB) +define+SYNTH_TEST -o syn_simv

clean:
	rm -rf *simv *simv.daidir csrc vcs.key program.out *.key
	rm -rf vis_simv vis_simv.daidir
	rm -rf dve* inter.vpd DVEfiles
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h
	rm -f *.elf *.dump *.mem debug_bin

nuke:	clean
	rm -rf synth_out/*.vg synth_out/*.rep synth_out/*.ddc synth_out/*.chk synth_out/*.log synth_out/*.syn synth_out/*.res
	rm -rf synth_out/*.out command.log synth_out/*.db synth_out/*.svf synth_out/*.mr synth_out/*.pvl
	rm -rf *.vg *.rep *.ddc *.chk *.log *.syn
	rm -rf *.out command.log *.db *.svf *.mr *.pvl *.res
