# $Id: Makefile.am,v 1.6.2.3 2011/06/20 03:43:39 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/bin, is processed by 
# automake to create Makefile.in.

bin_SCRIPTS = databasectl datadumper logger mailboxparser \
		messagetoken summarizer tablectl
distdir = $(BUILDROOT)/dist/bin
instdir = @bindir@

$(bin_SCRIPTS):
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $@.PL | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__KANADZUCHIETC__|@sysconfdir@|g' \
		-e 's|__KANADZUCHIVAR__|@localstatedir@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|__PERLEXTERNALLIB__|$(PERL_EXTLIB)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@.tmp
	mv $@.tmp $@
	test "X$(PERL_EXTLIB)" = "X" || ( $(GREP) -v PERL_EXTLIB $@ > $@.tmp && mv $@.tmp $@ )
	cp -Rp $@ $(distdir)/

.PHONY: clean
clean:
	rm -f $(bin_SCRIPTS) *.tmp
	rm -f $(distdir)/*

