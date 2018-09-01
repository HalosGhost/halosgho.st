PROGNM  =  hgweb
PREFIX  ?= /srv/http
MAINDIR ?= $(DESTDIR)$(PREFIX)
SVCDIR  ?= $(DESTDIR)/usr/lib/systemd/system/
BINDIR  ?= $(DESTDIR)/usr/bin

include Makerules

.PHONY: all bin clean complexity clang-analyze cov-build res minify install

all: dist bin res minify

bin: dist
	@(cd src; \
		$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCES) -o ../dist/$(PROGNM) \
	)
	@(cd src; \
		$(CC) $(CFLAGS) $(LDFLAGS) redirector.c -o ../dist/hgredirector \
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

install: all
	@mkdir -p $(BINDIR) $(SVCDIR) $(MAINDIR)
	@cp -a --no-preserve=ownership dist/* $(MAINDIR)/
	@cp -a --no-preserve=ownership svc/* $(SVCDIR)/
	@install -Dm755 website $(BINDIR)/website

include Makeeaster
