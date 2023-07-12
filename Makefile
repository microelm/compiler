SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
.DEFAULT_GOAL := build

ELM ?= elm
BUILD_DIR ?= ./build.nosync
SRC ?= ./src

SRCS := $(shell find $(SRC)/MicroElm -name 'V*.elm')
OBJS := ${subst $(SRC), $(BUILD_DIR), $(SRCS:.elm=.html)}
SCRIPTS := ${subst $(SRC), $(BUILD_DIR), $(shell find $(SRC)/script -name '*.css' -or -name '*.js')}
EXAMPLES := ${subst $(SRC), $(BUILD_DIR), $(shell find $(SRC)/examples -name '*.json'  -or -name '*.txt')}

run:
	@cd $(SRC)
	@$(ELM) reactor --port=8888

build: $(OBJS) $(SCRIPTS) $(EXAMPLES) $(BUILD_DIR)/index.html
	@echo Done

$(BUILD_DIR)/index.html: $(BUILD_DIR)/playground.html
	@mv -f $< $@

$(BUILD_DIR)/%: $(SRC)/%
	@$(MKDIR_P) -p $(@D)
	$(CP) $< $@

$(BUILD_DIR)/MicroElm/%.js: $(SRC)/MicroElm/%.elm
	@#$(ELM) make $< --optimize --output=$@
	$(ELM) make $< --output=$@
$(BUILD_DIR)/MicroElm/%.html: $(SRC)/MicroElm/%.elm
	@#$(ELM) make $< --optimize --output=$@
	$(ELM) make $< --output=$@


clean:
	@rm -rf elm-stuff
	rm -rf $(BUILD_DIR)

.PHONY: clean, run, build

MKDIR_P ?= mkdir -p
CP ?= cp -f
