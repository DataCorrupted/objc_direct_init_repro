# Port of D127661877: an objc_direct designated initializer skips a Swift
# subclass's stored properties. Builds with the Xcode toolchain on macOS.

CLANG  ?= xcrun clang
SWIFTC ?= xcrun swiftc
BUILD  := build

# Lets a non-Xcode CLANG find the macOS SDK.
SDKROOT ?= $(shell xcrun --show-sdk-path)
export SDKROOT
DEMO   := $(BUILD)/objc_direct_init_demo

all: $(DEMO)

$(BUILD):
	mkdir -p $@

$(BUILD)/Foo.o: Foo.m Foo.h | $(BUILD)
	$(CLANG) -fobjc-arc -c Foo.m -o $@

$(DEMO): main.swift Foo.h $(BUILD)/Foo.o
	$(SWIFTC) -import-objc-header Foo.h main.swift $(BUILD)/Foo.o -o $@

run: $(DEMO)
	./$(DEMO)

# The same program with objc_direct defined away: every route prints true.
CONTROL := $(BUILD)/control/objc_direct_init_demo

$(BUILD)/control:
	mkdir -p $@

$(BUILD)/control/Foo.o: Foo.m Foo.h | $(BUILD)/control
	$(CLANG) -fobjc-arc -Dobjc_direct= -c Foo.m -o $@

$(CONTROL): main.swift Foo.h $(BUILD)/control/Foo.o
	$(SWIFTC) -Xcc -Dobjc_direct= -import-objc-header Foo.h main.swift $(BUILD)/control/Foo.o -o $@

control: $(CONTROL)
	./$(CONTROL)

clean:
	rm -rf $(BUILD)

.PHONY: all run control clean
