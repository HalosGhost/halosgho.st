PROGNM  =  hgweb
PREFIX  ?= /srv/http
DOCDIR  ?= $(DESTDIR)$(PREFIX)/share/man
LIBDIR  ?= $(DESTDIR)$(PREFIX)/lib
BINDIR  ?= $(DESTDIR)$(PREFIX)/bin
ZSHDIR  ?= $(DESTDIR)$(PREFIX)/share/zsh
BASHDIR ?= $(DESTDIR)$(PREFIX)/share/bash-completion
LOCDIR  ?= $(DESTDIR)$(PREFIX)/share/locale

include Makerules

.PHONY: all bin clean complexity clang-analyze cov-build res minify install uninstall

all: dist bin res minify

bin: dist
	@(cd src; \
		$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCES) -o ../dist/$(PROGNM) \
	)
	@(cd src; \
		$(CC) $(CFLAGS) $(LDFLAGS) redirector.c -o ../dist/redirector \
	)

clang-analyze:
	@(cd ./src; clang-check -analyze ./*.c)

clean:
	@rm -rf -- dist cov-int $(PROGNM).tgz ./src/*.plist \

complexity:
	@complexity -h ./src/*

cov-build: clean dist
	@cov-build --dir cov-int make
	@tar czvf $(PROGNM).tgz cov-int

dist:
	@mkdir -p dist/.well-known/acme-challenge

res: dist
	@cp -a --no-preserve=ownership pages dist/
	@cp -a --no-preserve=ownership media dist/
	@cp -a --no-preserve=ownership assets dist/
	@cp -a --no-preserve=ownership conf/* dist/

minify: res
	@(cd dist; \
	for i in 'assets/main.css' 'pages/index.htm'; do \
		mv "$$i" "$$i".bak; \
		sed -E 's/^\s+//g' "$$i".bak | tr -d '\n' > "$$i"; \
		rm "$$i".bak; \
	done)

install:
	@install -Dm755 dist/$(PROGNM)   $(BINDIR)/$(PROGNM)

uninstall:
	@rm -f $(BINDIR)/$(PROGNM)

include Makeeaster
