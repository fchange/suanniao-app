APP_NAME := 蒜鸟蒜鸟
EXECUTABLE_NAME := SuanNiaoSuanNiao
BUILD_DIR := build
APP_DIR := $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR := $(APP_DIR)/Contents
MACOS_DIR := $(CONTENTS_DIR)/MacOS
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
INFO_PLIST := Support/Info.plist
INSTALL_DIR ?= $(HOME)/Applications
LOCAL_HOME := $(CURDIR)/.home
LOCAL_CACHE := $(CURDIR)/.cache
SWIFT_ENV := env HOME="$(LOCAL_HOME)" XDG_CACHE_HOME="$(LOCAL_CACHE)" CLANG_MODULE_CACHE_PATH="$(LOCAL_CACHE)/clang/ModuleCache"

.PHONY: build run install clean

build:
	@mkdir -p "$(LOCAL_HOME)" "$(LOCAL_CACHE)/clang/ModuleCache" "$(BUILD_DIR)"
	$(SWIFT_ENV) swift build -c release
	@BIN_DIR="$$( $(SWIFT_ENV) swift build -c release --show-bin-path )"; \
	PRODUCT_DIR="$$(dirname "$$BIN_DIR")"; \
	rm -rf "$(APP_DIR)"; \
	mkdir -p "$(MACOS_DIR)" "$(RESOURCES_DIR)"; \
	cp "$(INFO_PLIST)" "$(CONTENTS_DIR)/Info.plist"; \
	cp "$$BIN_DIR/$(EXECUTABLE_NAME)" "$(MACOS_DIR)/$(EXECUTABLE_NAME)"; \
	chmod +x "$(MACOS_DIR)/$(EXECUTABLE_NAME)"; \
	find "$$PRODUCT_DIR" -maxdepth 1 -name '*.bundle' -exec cp -R {} "$(RESOURCES_DIR)/" \; || true; \
	if [ -d Resources ]; then cp -R Resources/. "$(RESOURCES_DIR)/"; fi

run: build
	pkill -x "$(EXECUTABLE_NAME)" || true
	open "$(APP_DIR)"

install: build
	mkdir -p "$(INSTALL_DIR)"
	rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"
	cp -R "$(APP_DIR)" "$(INSTALL_DIR)/$(APP_NAME).app"

clean:
	swift package clean
	rm -rf "$(BUILD_DIR)"
