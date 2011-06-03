# $Id: Makefile.am,v 1.3.2.3 2011/06/03 09:41:22 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/libexec,
# is processed by automake to create Makefile.in.

libexec_SCRIPTS = mp-startup.pl
distdir = $(BUILDROOT)/dist/libexec
instdir = @libexecdir@

$(libexec_SCRIPTS):

all-am: distlib
distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $@ | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|__PERLEXTERNALLIB__|$(PERL_EXTLIB)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@.tmp
	mv $@.tmp $@
	test "X$(PERL_EXTLIB)" = "X" || ( $(GREP) -v PERL_EXTLIB $@ > $@.tmp && mv $@.tmp $@ )
	cp -Rp $@ $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*

