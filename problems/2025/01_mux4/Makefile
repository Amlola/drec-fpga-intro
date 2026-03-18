BUILD_DIR := build

TESTBENCH := mux4_tb.v
SOURCES   := mux4.v

EXEC      := $(BUILD_DIR)/branch
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