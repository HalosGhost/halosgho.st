.PHONY: init

init:
	@cp skeleton ../Makefile
	@sed -e "s/programname/$(PROGNM)/" -i ../Makefile
