# ==========================================================
# ModelSim / QuestaSim Makefile
# ==========================================================

VLIB = vlib
VMAP = vmap
VLOG = vlog
VSIM = vsim

SRC_DIR = src
TB_DIR  = testbench
WORK    = work
TOP     = uart_tb

# Compile all files as a single compilation unit
VLOG_FLAGS = -sv -mfcu +incdir+$(SRC_DIR)
VSIM_FLAGS = -c -do "run -all; quit"

SRC_FILES = \
	$(SRC_DIR)/uart_transmitter.sv \
	$(SRC_DIR)/uart_receiver.sv \
	$(SRC_DIR)/uart.sv

TB_FILES = \
	$(TB_DIR)/uart_tb.sv

all: compile run

$(WORK):
	$(VLIB) $(WORK)
	$(VMAP) $(WORK) $(WORK)

compile: $(WORK)
	$(VLOG) $(VLOG_FLAGS) $(SRC_FILES) $(TB_FILES)

run:
	$(VSIM) $(VSIM_FLAGS) $(WORK).$(TOP)

gui: compile
	$(VSIM) $(WORK).$(TOP)

clean:
	rm -rf work transcript vsim.wlf modelsim.ini

rebuild: clean all
