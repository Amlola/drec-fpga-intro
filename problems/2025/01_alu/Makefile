BUILD_DIR := build

TESTBENCH := alu_tb.v
SOURCES   := alu.v
INCLUDE   := alu.vh

EXEC      := $(BUILD_DIR)/alu
DUMP_FILE := dump.vcd

all: $(EXEC)

$(EXEC): $(SOURCES) $(TESTBENCH) $(INCLUDE) | $(BUILD_DIR)
	iverilog $(SOURCES) $(TESTBENCH) -o $@

run: $(EXEC)
	./$(EXEC)

view: $(DUMP_FILE)
	gtkwave $(DUMP_FILE) &

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(DUMP_FILE)