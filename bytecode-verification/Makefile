# Settings
# --------

BUILD_DIR      := .build
DEPS_DIR       := ../deps
DEFN_DIR       := $(BUILD_DIR)/defn
SPECS_DIR      := $(BUILD_DIR)/specs
KEVM_SUBMODULE ?= $(CURDIR)/$(DEPS_DIR)/evm-semantics

K_SUBMODULE := $(KEVM_SUBMODULE)/deps/k
ifneq (,$(wildcard $(K_SUBMODULE)/k-distribution/target/release/k/bin/*))
    K_RELEASE ?= $(abspath $(K_SUBMODULE)/k-distribution/target/release/k)
else
    K_RELEASE ?= $(dir $(shell which kompile))..
endif
K_BIN := $(K_RELEASE)/bin
K_LIB := $(K_RELEASE)/lib/kframework
export K_RELEASE

PATH := $(K_BIN):$(PATH)
export PATH

PYTHONPATH := $(K_LIB)
export PYTHONPATH

# no intermediate target is removed
.SECONDARY:

# Dependencies
# ------------

KEVM_MAKE := make --directory $(KEVM_SUBMODULE) DEPS_DIR=$(KEVM_SUBMODULE)/deps BUILD_DIR=$(CURDIR)/$(BUILD_DIR) K_RELEASE=$(K_RELEASE) RELEASE=$(RELEASE)

.PHONY: deps deps-k deps-kevm

deps: deps-k deps-kevm
deps-k:
	$(KEVM_MAKE) deps SKIP_LLVM=true SKIP_HASKELL=true
deps-kevm:
	$(KEVM_MAKE) build-java

.PHONY: clean clean-k clean-kevm

clean: clean-kevm clean-specs
	rm -rf $(BUILD_DIR)
clean-kevm:
	rm -rf $(DEFN_DIR)
clean-specs:
	rm -rf $(SPECS_DIR)

# Specs
# -----

SPEC_INI := deposit-spec.ini

SPEC_NAMES := $(shell cut -f 1 -d '|' spec-list.txt)
SPEC_FILES := $(patsubst %,$(SPECS_DIR)/%-spec.k,$(SPEC_NAMES))

LEMMA_NAMES := abstract-semantics lemmas verification
LEMMA_FILES := $(patsubst %,$(SPECS_DIR)/%.k,$(LEMMA_NAMES))

GEN_SPEC := scripts/gen-spec.py
TMPLS    := scripts/module-tmpl.k scripts/spec-tmpl.k

.PHONY: specs

specs: $(SPEC_FILES) $(LEMMA_FILES)

$(SPECS_DIR)/%-spec.k: $(TMPLS) $(SPEC_INI)
	@mkdir -p $(dir $@)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) $* $* > $@

$(SPECS_DIR)/%.k: lemmas/%.k
	@mkdir -p $(dir $@)
	cp $< $@

# non-standard spec generation

$(SPECS_DIR)/get_deposit_root-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) get_deposit_root-success get_deposit_root-success-loop-trusted get_deposit_root-success > $@

$(SPECS_DIR)/deposit-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(GEN_SPEC) $(TMPLS) $(SPEC_INI) deposit-success deposit-success-loop-trusted deposit-success > $@

# Kprove
# ------

K_OPTS ?= -Xmx8g
export K_OPTS

PRELUDE_FILE        := lemmas/evm.smt2
CONCRETE_RULES_FILE := lemmas/concrete-rules.txt

KPROVE_OPTS ?=
KPROVE_OPTS += -v --debug -d $(DEFN_DIR)/java
KPROVE_OPTS += --no-exc-wrap --no-alpha-renaming
KPROVE_OPTS += --deterministic-functions --cache-func-optimized --format-failures
KPROVE_OPTS += --z3-impl-timeout 500
KPROVE_OPTS += --smt-prelude $(PRELUDE_FILE)
KPROVE_OPTS += --concrete-rules $(shell cat $(CONCRETE_RULES_FILE) | tr '\n' ',')

.PHONY: verify

verify: $(addsuffix .test,$(SPEC_FILES))

$(SPECS_DIR)/%-spec.k.test: $(SPECS_DIR)/%-spec.k
	$(K_BIN)/kprove $(KPROVE_OPTS) $(shell grep "^[ ]*$*[ ]*|" spec-list.txt | cut -f 2 -d '|') $<
