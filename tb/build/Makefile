UVM_INCLUDE_DIR = $(UVM_HOME)/src
VLIB_DIR    = ./work
VLOG_FLAGS  = +incdir+$(UVM_INCLUDE_DIR)

$(VLIB_DIR):
	vlib $(VLIB_DIR)
	@echo -e "$(COLOUR_GREEN)Created the $(VLIB_DIR) library$(COLOUR_NONE)\n"

# compile the UVM library
$(VLIB_DIR)/uvm_pkg/_primary.dat:
	vlog -work work -stats=none -sv +incdir+$(UVM_INCLUDE_DIR)  $(UVM_INCLUDE_DIR)/uvm.sv $(UVM_INCLUDE_DIR)/uvm.sv

	@echo -e "$(COLOUR_GREEN)Compiled the UVM package$(COLOUR_NONE)\n"

# simple alias
UVM: $(VLIB_DIR) $(VLIB_DIR)/uvm_pkg/_primary.dat

all2:
	vlib $(VLIB_DIR)
	vlog  -sv  $(UVM_INCLUDE_DIR)/uvm_pkg.sv ../hello.sv +incdir+$(UVM_INCLUDE_DIR)  #-L $(UVM_HOME)
	vsim -c -sv_lib $(UVM_HOME)/lib/uvm_dpi hello #-L $(UVM_HOME)

all:  all2
