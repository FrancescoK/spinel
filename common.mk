# Shared build configuration for Spinel.
#
# Included by ./Makefile (the C compiler + test/bench harness). Keep only
# toolchain-level knobs here; target rules live in the Makefile.

# Machine-local overrides (gitignored). Lets a developer set OPT/CC/etc.
# without editing committed defaults. A command-line `make VAR=...` still wins.
-include $(dir $(lastword $(MAKEFILE_LIST)))local.mk

CC       ?= cc
# A native Windows build (MinGW-w64 gcc, as MSYS2 and RubyInstaller ship it),
# or a cross-build for Windows from another host (CC=x86_64-w64-mingw32-gcc:
# the compile-only check), sets its toolchain and the lib/win32 shim up in
# win32.mk; elsewhere every PLATFORM_ variable is empty.
ifneq ($(filter Windows_NT,$(OS))$(findstring -w64-mingw32-,$(CC)),)
include $(dir $(lastword $(MAKEFILE_LIST)))win32.mk
endif
# Auto-wrap CC with sccache or ccache when present. Skip when CC is
# already wrapped -- the substring guard catches both "ccache" and
# "sccache" since "ccache" is a substring of "sccache", so CI's
# `CC=sccache <cc>` env stays untouched. NO_CCACHE=1 opts out.
# `override` is required so that a command-line `make CC=gcc` is also
# wrapped -- without it the wrap would be silently ignored.
ifeq (,$(findstring ccache,$(CC)))
ifeq (,$(NO_CCACHE))
  CCACHE_BIN := $(shell command -v sccache 2>/dev/null || command -v ccache 2>/dev/null)
  ifneq (,$(CCACHE_BIN))
    override CC := $(CCACHE_BIN) $(CC)
  endif
endif
endif

# Optimization level for the C compiles driven by the test/bench harness
# (each .rb gets parsed → codegen → cc'd → run). CI overrides this to -O0
# to cut cc time; locally -O2 keeps the test binaries reasonable-speed.
# `-Wno-alloc-size-larger-than` silences a gcc 13+ paranoia warning on the
# inlined `h->cap *= 2` in sp_*Hash_grow; `-Wno-unknown-warning-option`
# keeps clang (which lacks that flag) from turning it into a -Werror fail.
# `-Wno-format-truncation` silences gcc's FORTIFY-driven paranoia on benign
# `snprintf(buf, sizeof buf, "@%s", name)` ivar/path builds (the buffers are
# sized for real identifiers; the warning fires independently of -Wall under
# _FORTIFY_SOURCE, so -Wno-all does not cover it). clang lacks the flag and
# ignores it via -Wno-unknown-warning-option above.
OPT     ?= $(COPT)
# String#crypt is libc crypt(3): glibc keeps it in libcrypt (macOS has it in
# libSystem). --as-needed drops the DSO when a program never calls it.
ifeq ($(shell uname -s),Linux)
LDFLAGS += -lcrypt
endif
# A Float `a * b - c` is two IEEE operations in Ruby, each rounded to
# double; clang (-ffp-contract=on) and gcc (=fast) fuse the pair written in
# one C expression into a single fused multiply-add that rounds once, and
# the program answers a double a few ULP from CRuby's, silently. Off on
# every C line: CFLAGS (the PCH, the tests, optcarrot) and SEC_FLAGS (the
# runtime objects, the packages, bench) -- src/main.c says the same on the
# generated program's own command line.
FP_FLAGS = -ffp-contract=off
CFLAGS   = $(OPT) -Wno-all -Wno-unknown-warning-option -Wno-alloc-size-larger-than -Wno-format-truncation $(FP_FLAGS) $(PLATFORM_FLAGS)

# The product build -- bin/spinel, libspinel_rt.a, and the generated
# programs -- uses CFLAGS and never used LTO, so there is no LTO toggle.

# Per-function sections let the linker strip unused bigint/regexp code.
SEC_FLAGS = -ffunction-sections -fdata-sections $(FP_FLAGS) $(PLATFORM_FLAGS)
# The target's word width, asked of the C compiler: 32 or 64. A 32-bit
# target (`make CC='cc -m32'` on a 64-bit host, or a 32-bit host) gets a
# 32-bit sp_int (lib/sp_types.h) and two things a Ruby needs there: 64-bit
# time_t and file offsets on glibc, and IEEE double arithmetic on i386, whose
# x87 unit rounds every intermediate at 80 bits otherwise (3.7.round(1) came
# out 3.8). Tests that assume a 64-bit Integer are filtered by the width
# (see TESTS in the Makefile).
SPINEL_INT_BITS ?= $(shell echo | $(CC) -dM -E - 2>/dev/null | awk '/__SIZEOF_POINTER__/{print $$3*8}')
ifeq ($(SPINEL_INT_BITS),32)
  SEC_FLAGS += -D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64
  ifneq (,$(shell echo | $(CC) -dM -E - 2>/dev/null | grep __i386__))
    SEC_FLAGS += -msse2 -mfpmath=sse
  endif
endif
# Apple ld64 spells dead-code stripping --dead_strip; GNU ld --gc-sections.
ifeq ($(shell uname -s),Darwin)
  GC_FLAGS = -Wl,-dead_strip
else
  GC_FLAGS = -Wl,--gc-sections
endif

# Wrapper around the system `timeout` that always returns GNU coreutils'
# exit code (124 on timeout), regardless of which `timeout` is on PATH.
# The bench target keys on 124 to mark a run as SKIP; busybox uses 143
# and BSDs use 399, which would be misclassified. Built once from C. The
# seconds it takes are CPU seconds of the command, with a backstop on the clock
# of six times as many (scripts/spinel-timeout.c).
# It is a build ARTEFACT, so it belongs under build/ with the rest of them --
# not beside its source in scripts/, where it would need its own ignore rule
# and would survive `make clean`.
#
# TIMEOUT_BIN stays defined because targets still test it, but it can no longer
# be empty: the wrapper is always built, so the "no time limit" warning those
# checks print is now unreachable. It is left in place rather than deleted --
# it is one line, and it is the thing to restore if the wrapper ever becomes
# optional again.
SPINEL_TIMEOUT := build/spinel-timeout
TIMEOUT_BIN := $(SPINEL_TIMEOUT)
TIMEOUT10 := $(SPINEL_TIMEOUT) 10
TIMEOUT60 := $(SPINEL_TIMEOUT) 60

# Default to a parallel build at the logical CPU count, unless the
# invocation already asked for a job count. Applied ONLY at the top level
# (MAKELEVEL 0): a sub-make inherits the parent's jobserver, and forcing
# -j again in a sub-make's MAKEFLAGS triggers GNU Make's "-j forced in
# makefile: resetting jobserver mode" warning (the --jobserver-auth flag
# isn't visible in MAKEFLAGS at sub-make parse time, so a plain -j guard
# can't see it -- MAKELEVEL is the reliable discriminator). A command-line
# -jN still wins by precedence; the env form `MAKEFLAGS=-jN` is honored
# by the inner guard.
ifeq ($(MAKELEVEL),0)
ifeq (,$(filter -j%,$(MAKEFLAGS))$(findstring j,$(firstword -$(MAKEFLAGS))))
  MAKEFLAGS += -j$(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)
endif
endif

# Reference Ruby for test/bench output comparison. Override on the command
# line to use a freshly-built interpreter, e.g. `REF_RUBY=miniruby make test`.
REF_RUBY ?= ruby
