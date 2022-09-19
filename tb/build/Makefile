UVM_INCLUDE_DIR = $(UVM_HOME)/src
VLIB_DIR    = ./work
VLOG_FLAGS  = +incdir+$(UVM_INCLUDE_DIR)

DUT_FILES = ../../common.vhd
DUT_FILES += ../../i2s_receiver.vhd
DUT_FILES += ../../plot_controller.vhd

$(VLIB_DIR):
	vlib $(VLIB_DIR)

$(VLIB_DIR)/uvm_pkg/_primary.dat:
	vlog -work work -stats=none -sv +incdir+$(UVM_INCLUDE_DIR)  $(UVM_INCLUDE_DIR)/uvm.sv $(UVM_INCLUDE_DIR)/uvm.sv


UVM: $(VLIB_DIR) $(VLIB_DIR)/uvm_pkg/_primary.dat

all2:
	vlib $(VLIB_DIR)
	vcom $(DUT_FILES)
	vlog  -sv  $(UVM_INCLUDE_DIR)/uvm_pkg.sv -f test.f +incdir+$(UVM_INCLUDE_DIR)
	vsim -c -sv_lib $(UVM_HOME)/lib/uvm_dpi top_tb -do "run; exit"

all:  all2

all_i2s: all2

