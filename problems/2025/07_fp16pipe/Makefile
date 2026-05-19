TEST_SIZE ?= 4096
DEBUG     ?= 0
VERSION   ?= base

TEST_DIR  := tests
TEST_FILE := $(TEST_DIR)/test.txt

ifeq ($(VERSION), base)
	IMPL_DIR := adder_fp16_base
	TB_LIST  := $(TEST_DIR)/fp16_base_tb.v
else
	IMPL_DIR := adder_fp16_2_stage
	TB_LIST  := $(TEST_DIR)/fp16_2_stage_tb.v
endif

RTL_LIST := $(IMPL_DIR)/fp16add.v

sim: $(TB_LIST) $(RTL_LIST) $(TEST_DIR)/test.py
	python3 $(TEST_DIR)/test.py $(TEST_SIZE) > $(TEST_FILE)
	iverilog -g2012 \
		-I$(TEST_DIR) -I$(IMPL_DIR) \
		$(TB_LIST) $(RTL_LIST) \
		-o sim \
		-DTEST_SIZE=$(TEST_SIZE) \
		-DDEBUG=$(DEBUG) \
		-DTEST_FILE=\"$(TEST_FILE)\"
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

syn:
	cd $(IMPL_DIR) && quartus_sh --flow compile fpga

gui:
	cd $(IMPL_DIR) && quartus fpga &

fpga:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;$(IMPL_DIR)/output/fpga.sof"

clean:
	rm -rf sim dump.vcd $(TEST_FILE)
	rm -rf adder_fp16_base/db adder_fp16_base/incremental_db adder_fp16_base/output
	rm -rf adder_fp16_2_stage/db adder_fp16_2_stage/incremental_db adder_fp16_2_stage/output

.PHONY: sim waves syn gui fpga clean