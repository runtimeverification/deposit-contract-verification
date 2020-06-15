# Settings
# --------

UNAME_S := $(shell uname -s)

DEPS_DIR       := ../deps
BUILD_DIR      := .build
SUBDEFN_DIR    := .
DEFN_BASE_DIR  := $(BUILD_DIR)/defn
DEFN_DIR       := $(DEFN_BASE_DIR)/$(SUBDEFN_DIR)
BUILD_LOCAL    := $(abspath $(BUILD_DIR)/local)
LOCAL_LIB      := $(BUILD_LOCAL)/lib
KEVM_SUBMODULE ?= $(DEPS_DIR)/evm-semantics

K_SUBMODULE := $(KEVM_SUBMODULE)/deps/k
ifneq (,$(wildcard $(K_SUBMODULE)/k-distribution/target/release/k/bin/*))
    K_RELEASE ?= $(abspath $(K_SUBMODULE)/k-distribution/target/release/k)
else
    K_RELEASE ?= $(dir $(shell which kompile))..
endif
K_BIN := $(K_RELEASE)/bin
K_LIB := $(K_RELEASE)/lib/kframework
export K_RELEASE

.PHONY: all clean distclean                 \
        deps k-deps                         \
        build build-concrete build-symbolic \
        test test-concrete test-symbolic
.SECONDARY:

all: build

clean:
	rm -rf $(DEFN_BASE_DIR)

distclean:
	rm -rf $(BUILD_DIR)
	git clean -dffx -- tests/

# K Dependencies
# --------------

K_JAR := $(K_SUBMODULE)/k-distribution/target/release/k/lib/java/kernel-1.0-SNAPSHOT.jar

deps: k-deps
k-deps: $(K_JAR)

K_MVN_ARGS += -Dllvm.backend.skip -Dhaskell.backend.skip

ifneq ($(RELEASE),)
    K_BUILD_TYPE := FastBuild
else
    K_BUILD_TYPE := Debug
endif

$(K_JAR):
	cd $(K_SUBMODULE) && mvn package -DskipTests -U -Dproject.build.type=$(K_BUILD_TYPE) $(K_MVN_ARGS)

# Building
# --------

build: build-concrete build-symbolic

SOURCE_FILES       := deposit          \
                      deposit-symbolic
EXTRA_SOURCE_FILES :=
ALL_FILES          := $(patsubst %, %.k, $(SOURCE_FILES) $(EXTRA_SOURCE_FILES))

ifneq (,$(RELEASE))
    KOMPILE_OPTS += -O3
endif

JAVA_KOMPILE_OPTS :=

KOMPILE_JAVA := kompile --debug --backend java       \
                $(KOMPILE_OPTS) $(JAVA_KOMPILE_OPTS)

### Concrete

concrete_dir           := $(DEFN_DIR)/concrete
concrete_files         := $(ALL_FILES)
concrete_main_module   := DEPOSIT
concrete_syntax_module := $(concrete_main_module)-SYNTAX
concrete_main_file     := deposit
concrete_kompiled      := $(concrete_dir)/$(concrete_main_file)-kompiled/timestamp

build-concrete: $(concrete_kompiled)

$(concrete_kompiled): $(concrete_files)
	$(KOMPILE_JAVA) $(concrete_main_file).k                   \
	                --directory $(concrete_dir) -I $(CURDIR)  \
	                --main-module $(concrete_main_module)     \
	                --syntax-module $(concrete_syntax_module)

### Symbolic

symbolic_dir           := $(DEFN_DIR)/symbolic
symbolic_files         := $(ALL_FILES)
symbolic_main_module   := DEPOSIT-SYMBOLIC
symbolic_syntax_module := $(symbolic_main_module)
symbolic_main_file     := deposit-symbolic
symbolic_kompiled      := $(symbolic_dir)/$(symbolic_main_file)-kompiled/timestamp

build-symbolic: $(symbolic_kompiled)

$(symbolic_kompiled): $(symbolic_files)
	$(KOMPILE_JAVA) $(symbolic_main_file).k                   \
	                --directory $(symbolic_dir) -I $(CURDIR)  \
	                --main-module $(symbolic_main_module)     \
	                --syntax-module $(symbolic_syntax_module)

# Tests
# -----

CHECK := git --no-pager diff --no-index --ignore-all-space -R

test: test-concrete test-symbolic

### Concrete Tests

concrete_tests := $(wildcard tests/concrete/*.deposit)

test-concrete: $(concrete_tests:=.run)

tests/concrete/%.run: tests/concrete/% $(concrete_kompiled)
	krun --directory $(concrete_dir) --smt none -cTREEHEIGHT=3 $< > $<.out
	$(CHECK) $<.out $<.expected

### Symbolic Tests

KPROVE_OPTS :=

ifneq (,$(DEBUG_KPROVE))
    KPROVE_OPTS += -v --debug --log --log-rules --debug-z3-queries --log-cells k,depositCount,branch,zerohashes,#pc,#result
endif

symbolic_tests := $(wildcard tests/symbolic/*-spec.k)

test-symbolic: $(symbolic_tests:=.prove)

tests/symbolic/%.prove: tests/symbolic/% $(symbolic_kompiled)
	kprove --directory $(symbolic_dir) --smt-prelude imap.smt2 $< $(KPROVE_OPTS) > $<.out
	$(CHECK) $<.out $<.expected
