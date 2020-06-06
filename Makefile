# Settings
# --------

BUILD_DIR      := .build
DEFN_DIR       := $(BUILD_DIR)/defn

DEPS_DIR       := deps
K_SUBMODULE    := $(abspath $(DEPS_DIR)/k)
KEVM_SUBMODULE := $(abspath $(DEPS_DIR)/evm-semantics)

K_RELEASE ?= $(K_SUBMODULE)/k-distribution/target/release/k
K_BIN     := $(K_RELEASE)/bin
K_LIB     := $(K_RELEASE)/lib
export K_RELEASE

PATH := $(K_BIN):$(PATH)
export PATH

PYTHONPATH := $(K_LIB)
export PYTHONPATH

PANDOC_TANGLE_SUBMODULE := $(KEVM_SUBMODULE)/deps/pandoc-tangle
TANGLER                 := $(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH                := $(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export TANGLER
export LUA_PATH

# no intermediate target is removed
.SECONDARY:

# Dependencies
# ------------

KEVM_BUILD := $(KEVM_SUBMODULE)/.build/defn/java

.PHONY: deps deps-k deps-kevm

deps: deps-k deps-kevm
deps-k:    $(K_SUBMODULE)/mvn.timestamp
deps-kevm: $(KEVM_SUBMODULE)/make.timestamp

%/submodule.timestamp:
	git submodule update --init --recursive -- $*
	touch $@

$(K_SUBMODULE)/mvn.timestamp: $(K_SUBMODULE)/submodule.timestamp
	cd $(K_SUBMODULE) \
		&& mvn package -DskipTests -Dllvm.backend.skip -Dhaskell.backend.skip -Dproject.build.type=FastBuild
	touch $@

$(KEVM_SUBMODULE)/make.timestamp: $(KEVM_SUBMODULE)/submodule.timestamp $(K_SUBMODULE)/mvn.timestamp
	cd $(KEVM_SUBMODULE) \
		&& make tangle-deps \
		&& make defn \
		&& $(K_BIN)/kompile -v --debug --backend java -I $(KEVM_BUILD) -d $(KEVM_BUILD) --main-module ETHEREUM-SIMULATION --syntax-module ETHEREUM-SIMULATION $(KEVM_BUILD)/driver.k
	touch $@

.PHONY: clean clean-deps clean-k clean-kevm clean-kevm-cache

clean:
	rm -rf $(BUILD_DIR)

clean-deps: clean clean-k clean-kevm
clean-k:
	rm -rf $(K_SUBMODULE)/mvn.timestamp
clean-kevm:
	rm -rf $(KEVM_SUBMODULE)/make.timestamp $(KEVM_BUILD)/driver-kompiled
clean-kevm-cache:
	rm -rf $(KEVM_BUILD)/driver-kompiled/cache.bin

# Specs
# -----

SPECS_DIR := $(BUILD_DIR)/specs

SPEC_INI := deposit-spec.ini

SPEC_NAMES := $(shell cut -f 1 -d '|' spec-list.txt)
SPEC_FILES := $(patsubst %,$(SPECS_DIR)/%-spec.k,$(SPEC_NAMES))

LEMMA_NAMES := abstract-semantics lemmas verification
LEMMA_FILES := $(patsubst %,$(SPECS_DIR)/%.k,$(LEMMA_NAMES))

GEN_SPEC := scripts/gen-spec.py
TMPLS    := scripts/module-tmpl.k scripts/spec-tmpl.k

.PHONY: split-proof-tests

split-proof-tests: $(SPECS_DIR) $(SPEC_FILES) $(LEMMA_FILES)

$(SPECS_DIR):
	mkdir -p $@

$(SPECS_DIR)/%-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) $* $* > $@

$(SPECS_DIR)/%.k: lemmas/%.k
	cp -p $< $@

# non-standard spec generation

$(SPECS_DIR)/get_deposit_root-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) get_deposit_root-success get_deposit_root-success-loop-trusted get_deposit_root-success > $@

$(SPECS_DIR)/deposit-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) deposit-success deposit-success-loop-trusted deposit-success > $@

# Kprove
# ------

K_OPTS ?= -Xmx24g
export K_OPTS

PRELUDE_FILE        := lemmas/evm.smt2
CONCRETE_RULES_FILE := lemmas/concrete-rules.txt

KPROVE_OPTS ?=
KPROVE_OPTS += -v --debug -d $(KEVM_BUILD)
KPROVE_OPTS += --no-exc-wrap --no-alpha-renaming
KPROVE_OPTS += --deterministic-functions --cache-func-optimized --format-failures
KPROVE_OPTS += --z3-impl-timeout 500
KPROVE_OPTS += --smt-prelude $(PRELUDE_FILE)
KPROVE_OPTS += --concrete-rules $(shell cat $(CONCRETE_RULES_FILE) | tr '\n' ',')

.PHONY: test

test: $(addsuffix .test,$(SPEC_FILES))

$(SPECS_DIR)/%-spec.k.test: $(SPECS_DIR)/%-spec.k
	$(K_BIN)/kprove $(KPROVE_OPTS) $(shell grep "^[ ]*$*[ ]*|" spec-list.txt | cut -f 2 -d '|') $<
