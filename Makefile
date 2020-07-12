include Makerules

PROGNM  =  hgweb
WEBDIR  ?= /srv/http
MAINDIR ?= $(DESTDIR)$(WEBDIR)
SVCDIR  ?= $(DESTDIR)$(PREFIX)/lib/systemd/system/
BINDIR  ?= $(DESTDIR)$(PREFIX)/bin
TARGET  ?= oceanus.halosgho.st
PORT    ?= 2222
MKDIR   ?= mkdir -p

.PHONY: all bin clean complexity scan-build cov-build res run minify install uninstall

all: dist bin res minify

bin: dist
	@(cd src; \
		$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCES) -o ../dist/$(PROGNM); \
		$(CC) $(CFLAGS) $(LDFLAGS) redirector.c -o ../dist/hgredirector \
	)

scan-build:
	@scan-build --use-cc=$(CC) make bin

clean:
	@rm -rf -- dist cov-int $(PROGNM).tgz ./src/*.plist
	@rm -rf -- bld/{lwan-git,acme-client-git,uacme,hitch-git,pkg,src,packages,halosgho.st}

complexity:
	@complexity -h ./src/*

cov-build: clean dist
	@cov-build --dir cov-int make
	@tar czvf $(PROGNM).tgz cov-int

dist:
	@$(MKDIR) dist/.well-known/acme-challenge

res: dist
	@(for i in pages media assets; do \
		cp -a --no-preserve=ownership "$$i" dist/; \
	done)

run: all
	@(cd dist; sudo ./$(PROGNM))

minify: res
	@(cd dist; \
	for i in $$(find {pages,assets} -name '*.html' -o -name '*.css'); do \
		mv "$$i" "$$i".bak; \
		awk -f '../extra/minify.awk' "$$i".bak > "$$i"; \
		rm "$$i".bak; \
	done)

install: all
	@$(MKDIR) -- $(BINDIR) $(SVCDIR) $(MAINDIR)
	@cp -a --no-preserve=ownership dist/* $(MAINDIR)/
	@cp -a --no-preserve=ownership svc/* $(SVCDIR)/
	@install -m755 -t $(BINDIR) bin/*

deploy: clean
	@(pushd bld; \
	$(MKDIR) packages; \
	for i in lwan-git uacme; do \
		cower -df "$$i" --ignorerepo &> /dev/null; \
		pushd "$$i"; \
		PKGDEST=../packages makepkg -s; \
		popd; \
		echo "$$i: built"; \
	done; \
	PKGDEST=packages makepkg -s; \
	ssh -p $(PORT) $(TARGET) 'rm -r -- /home/halosghost/packages'; \
	scp -P $(PORT) -r packages $(TARGET):/home/halosghost/; \
	ssh -p $(PORT) $(TARGET); \
	)

uninstall:
	@rm -rf -- $(MAINDIR)/{assets,media,pages,.well-known}
	@rm -f  -- $(SVCDIR)/{$(PROGNM),hgredirector}.service ${SVCDIR}/update-copyright.{service,timer} ${SVCDIR}/uacme.{timer,service}
	@rm -f  -- $(BINDIR)/website

include Makeeaster
