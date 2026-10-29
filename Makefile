# An objc_direct designated initializer skips a Swift subclass's stored
# properties. Builds with the Xcode toolchain on macOS.

CLANG  ?= xcrun clang
SWIFTC ?= xcrun swiftc
BUILD  := build

# Lets a non-Xcode CLANG find the macOS SDK.
SDKROOT ?= $(shell xcrun --show-sdk-path)
export SDKROOT

DEMO   := $(BUILD)/objc_direct_init_demo
OBJS   := $(BUILD)/Foo.o $(BUILD)/Client.o

all: $(DEMO)

$(BUILD):
	mkdir -p $@

$(OBJS): $(BUILD)/%.o: %.m Foo.h | $(BUILD)
	$(CLANG) -fobjc-arc -c $< -o $@

$(DEMO): main.swift Foo.h $(OBJS)
	$(SWIFTC) -import-objc-header Foo.h main.swift $(OBJS) -o $@

run: $(DEMO)
	./$(DEMO)

# The same program with objc_direct defined away: every route prints true.
CONTROL      := $(BUILD)/control/objc_direct_init_demo
CONTROL_OBJS := $(BUILD)/control/Foo.o $(BUILD)/control/Client.o

$(BUILD)/control:
	mkdir -p $@

$(CONTROL_OBJS): $(BUILD)/control/%.o: %.m Foo.h | $(BUILD)/control
	$(CLANG) -fobjc-arc -Dobjc_direct= -c $< -o $@

$(CONTROL): main.swift Foo.h $(CONTROL_OBJS)
	$(SWIFTC) -Xcc -Dobjc_direct= -import-objc-header Foo.h main.swift $(CONTROL_OBJS) -o $@

control: $(CONTROL)
	./$(CONTROL)

clean:
	rm -rf $(BUILD)

.PHONY: all run control clean
