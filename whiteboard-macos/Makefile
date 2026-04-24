# Build a runnable .app bundle from the SPM executable.
#
# Usage:
#   make             # build Debug
#   make release     # build Release
#   make run         # build Debug and launch
#   make clean
#
# Produces build/Whiteboard.app that you can double-click or `open`.

APP_NAME        := Whiteboard
BUNDLE_ID       := com.whiteboard.app
CONFIG          ?= debug
BIN_DIR         := $(shell swift build --configuration $(CONFIG) --show-bin-path)
APP_DIR         := build/$(APP_NAME).app
CONTENTS        := $(APP_DIR)/Contents
MACOS_DIR       := $(CONTENTS)/MacOS
RESOURCES_DIR   := $(CONTENTS)/Resources

.PHONY: all release run clean

all: bundle

release:
	$(MAKE) CONFIG=release bundle

bundle:
	swift build --configuration $(CONFIG)
	rm -rf $(APP_DIR)
	mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	cp $(BIN_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Sources/Whiteboard/Resources/Info.plist $(CONTENTS)/Info.plist
	@echo "Built $(APP_DIR)"

run: bundle
	open $(APP_DIR)

clean:
	swift package clean
	rm -rf build
