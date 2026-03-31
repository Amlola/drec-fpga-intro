BUILD_DIR := build

TESTBENCH := shiftreg_tb.v
SOURCES   := shiftreg.v

EXEC      := $(BUILD_DIR)/shiftreg
DUMP_FILE := dump.vcd

all: $(EXEC)

$(EXEC): $(SOURCES) $(TESTBENCH) | $(BUILD_DIR)
	iverilog $(SOURCES) $(TESTBENCH) -o $@

run: $(EXEC)
	./$(EXEC)

view: $(DUMP_FILE)
	gtkwave $(DUMP_FILE) &

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(DUMP_FILE)