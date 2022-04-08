.PHONY: deploy packages res minify

all: $(BLDDIR) bin res minify

$(BLDDIR):
	@$(MKDIR) $(BLDDIR)/.well-known/acme-challenge

res: $(BLDDIR)
	@(for i in pages media assets; do \
		cp -a --no-preserve=ownership "$$i" $(BLDDIR); \
	done)

run: all
	@(pushd $(BLDDIR); ./$(PROGNM); popd)

minify: res
	@(cd $(BLDDIR); for i in $$(find {pages,assets} -name '*.html' -o -name '*.css'); do \
		mv "$$i" "$$i".bak; \
		awk -f '$(RTDIR)/extra/minify.awk' "$$i".bak > "$$i"; \
		rm "$$i".bak; \
	done)

bin: $(BLDDIR)
	@$(CC) $(CFLAGS) ./src/main.c -DVERSION="\"$(VER)\n\"" -o $(BLDDIR)/$(PROGNM) $(LDFLAGS) 
	@$(CC) $(CFLAGS) ./src/redirector.c -o $(BLDDIR)/redirector $(LDFLAGS)

clean:
	@rm -rf -- dist cov-int $(PROGNM).tgz ./src/*.plist
	@(pushd bld; rm -rf -- $(PACKAGES) src pkg packages $(PROGNM); popd)

install: all
	@$(MKDIR) -- $(BINDIR) $(SVCDIR)
	@cp -a --no-preserve=ownership $(BLDDIR)/* $(PKGDIR)/
	@cp -a --no-preserve=ownership svc/* $(SVCDIR)/
	@install -m755 -t $(BINDIR) bin/*

packages: clean
	@(pushd bld; \
		$(MKDIR) packages; \
		for i in $(PACKAGES); do \
			cower -df "$$i" --ignorerepo &> /dev/null; \
			pushd "$$i"; \
			PKGDEST=../packages makepkg -s; \
			popd; \
			echo "$$i: built"; \
		done; \
		PKGDEST=packages makepkg -s; \
	)

deploy: packages
	@(pushd bld; \
		ssh -p $(PORT) $(TARGET) 'rm -r -- ~/packages'; \
		scp -P $(PORT) -r packages $(TARGET):~; \
		ssh -p $(PORT) $(TARGET); \
	)

uninstall:
	@rm -rf -- $(PKGDIR)/{assets,media,pages,.well-known}
	@rm -f  -- $(SVCDIR)/{$(PROGNM),redirector}.service $(SVCDIR)/update-copyright.{service,timer} $(SVCDIR)/uacme.{timer,service}
	@rm -f  -- $(BINDIR)/website
