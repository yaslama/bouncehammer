# $Id: Makefile.am,v 1.3.2.6 2011/06/03 10:17:23 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/libexec,
# is processed by automake to create Makefile.in.

libexec_SCRIPTS = mp-startup.pl
distdir = $(BUILDROOT)/dist/libexec
instdir = @libexecdir@

$(libexec_SCRIPTS).X:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(libexec_SCRIPTS) | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|__PERLEXTERNALLIB__|$(PERL_EXTLIB)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@
	mv $@ $@.tmp
	test "X$(PERL_EXTLIB)" = "X" || \
		( $(GREP) -v PERL_EXTLIB $@.tmp > $@ && mv $@ $@.tmp )
	cp -Rp $@.tmp $(distdir)/$(libexec_SCRIPTS)

.PHONY: clean
clean:
	rm -f *.X *.tmp
	rm -f $(distdir)/*

