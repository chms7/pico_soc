# directory
TOP_DIR   := $(PWD)
RTL_DIR		:= $(TOP_DIR)/rtl
TB_DIR		:= $(TOP_DIR)/tb
SIM_DIR  	:= $(TOP_DIR)/sim
TESTCASE	:= picorv32_wrapper

# src
RTL 		 	:= $(RTL_DIR)/utils/*.v
RTL 		 	+= $(RTL_DIR)/wb2pulse.v
RTL				+= $(RTL_DIR)/debounce.v
RTL 		 	+= $(RTL_DIR)/wb2byteout.v
RTL 		 	+= $(RTL_DIR)/wb2byteio.v
RTL 		 	+= $(RTL_DIR)/wb2sram32.v
RTL 		 	+= $(RTL_DIR)/wb_interconnect.v
RTL 		 	+= $(RTL_DIR)/picorv32_wrapper.v
TB  		 	:= $(TB_DIR)/tb_$(TESTCASE).v

# sim
SIMV		 	:= $(SIM_DIR)/simv
SIM_TOOL 	:= iverilog
ifeq ($(SIM_TOOL), iverilog)
SIM_OPTION := -o $(SIMV)
endif
ifeq ($(SIM_TOOL), vcs)
SIM_OPTION := -full64 +v2k -sverilog -kdb -fsdb -ldflags -debug_access+all -LDFLAGS -Wl,--no-as-needed -o $(SIMV)
endif

# wave
ifeq ($(SIM_TOOL), iverilog)
WAVE_TOOL   := gtkwave
WAVE_OPTION := 
endif
ifeq ($(SIM_TOOL), vcs)
WAVE_TOOL   := verdi
WAVE_OPTION := +v2k
endif
WAVE_FILE := $(SIM_DIR)/$(TESTCASE).vcd

# clean
CLEAN := $(wildcard $(SIM_DIR)/*)
CLEAN_FILTER := $(wildcard $(SIM_DIR)/*.gtkw)

all: sim

sim:
	@mkdir -p $(SIM_DIR)
	$(SIM_TOOL) $(SIM_OPTION) $(RTL) $(TB)
	$(SIMV)

# wave: sim
# 	$(WAVE_TOOL) $(SIM_DIR)/$(TESTCASE).gtkw || \
# 	nohup $(WAVE_TOOL) $(WAVE_FILE) >> sim/gtkwave_nohup &
wave:
	nohup $(WAVE_TOOL) $(WAVE_FILE) >> sim/gtkwave_nohup &

clean:
	rm -rf $(filter-out $(CLEAN_FILTER), $(CLEAN)) ./csrc ./ucli.key ./*Log ./novas*

.PHONY: all sim wave clean

# include software/Makefile
