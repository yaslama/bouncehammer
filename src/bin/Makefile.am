# $Id: Makefile.am,v 1.5 2010/06/25 19:32:15 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/bin, is processed by 
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
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@.tmp
	mv $@.tmp $@
	cp -Rp $@ $(distdir)/

.PHONY: clean
clean:
	rm -f $(bin_SCRIPTS) *.tmp
	rm -f $(distdir)/*

