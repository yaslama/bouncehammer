# $Id: Makefile.am,v 1.3.2.5 2011/06/03 09:58:11 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/libexec,
# is processed by automake to create Makefile.in.

libexec_SCRIPTS = mp-startup.pl
distdir = $(BUILDROOT)/dist/libexec
instdir = @libexecdir@

$(libexec_SCRIPTS).X:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $@ | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|__PERLEXTERNALLIB__|$(PERL_EXTLIB)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@.tmp
	mv $@.tmp $@.X
	test "X$(PERL_EXTLIB)" = "X" || ( $(GREP) -v PERL_EXTLIB $@.X > $@.tmp && mv $@.tmp $@.X )
	cp -Rp $@.X $(distdir)/

.PHONY: clean
clean:
	rm -f $(libexec_SCRIPTS).X $(libexec_SCRIPTS).tmp
	rm -f $(distdir)/*

