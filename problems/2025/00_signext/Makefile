BUILD_DIR := build
TEST_DIR  := tests
SOURCE_DIR := source

TESTBENCH := $(TEST_DIR)/testbench.v
SOURCES   := $(SOURCE_DIR)/sign_ext.v $(SOURCE_DIR)/copy.v

EXEC_BEH  := $(BUILD_DIR)/signext_beh
EXEC_ST   := $(BUILD_DIR)/signext_struct
DUMP_FILE := dump.vcd

all: $(EXEC_BEH) $(EXEC_ST)

$(EXEC_BEH): $(SOURCES) $(TESTBENCH) | $(BUILD_DIR)
	iverilog -D BEHAVIORAL $^ -o $@

bh: $(EXEC_BEH)
	./$(EXEC_BEH)

$(EXEC_ST): $(SOURCES) $(TESTBENCH) | $(BUILD_DIR)
	iverilog $^ -o $@

st: $(EXEC_ST)
	./$(EXEC_ST)

view: $(DUMP_FILE)
	gtkwave $(DUMP_FILE) &

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(DUMP_FILE)