PROGNM = hgweb

CC ?= gcc
CFLAGS ?= -O2 -fPIE -flto -fstack-protector-strong --param=ssp-buffer-size=1 -Wno-reserved-id-macro -Wall -Wextra -Wpedantic -Werror -std=gnu18 -fsanitize=undefined -march=native
LDFLAGS ?= `pkg-config --libs lwan`
VER = `git describe --long --tags | sed 's/\([^-]*-g\)/r\1/;s/-/./g'`
FMFLAGS = -wp -then -wp -wp-rte
SOURCES ?= $(wildcard src/*.c)

PACKAGES  ?= lwan-git hitch uacme
TARGET    ?= oceanus.halosgho.st
PORT      ?= 2222
WATCHDIRS ?= src pages assets media

ifneq ($(CC), tcc)
CFLAGS += -pie -D_FORTIFY_SOURCE=2
LDFLAGS += -Wl,-z,relro,-z,now
endif

ifeq ($(CC), clang)
CFLAGS += -Weverything -fsanitize-trap=undefined
endif

CFLAGS += -Wno-disabled-macro-expansion

BLDRT ?= dist
CONFIGURATION ?= debug
ifneq ($(CONFIGURATION), release)
BLDDIR ?= $(BLDRT)/debug
CFLAGS += -g -ggdb -O0 -U_FORTIFY_SOURCE
else
BLDDIR ?= $(BLDRT)/release
CFLAGS += -DNDEBUG -O3
endif

include mke/rules

ifneq ($(wildcard ./overrides.mk),)
include ./overrides.mk
endif
