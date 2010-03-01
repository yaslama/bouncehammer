# $Id: Makefile.am,v 1.3 2010/03/01 21:37:19 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/bin, is processed by 
# automake to create Makefile.in.

bin_SCRIPTS = databasectl datadumper logger mailboxparser messagetoken tablectl
distdir = $(BUILDROOT)/dist/bin
instdir = @bindir@

$(bin_SCRIPTS):
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $@.PL | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__KANADZUCHIETC__|@sysconfdir@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@.tmp

	if [ "$(ENABLE_DEBUGCODE)" -eq "0" ]; then \
		$(CAT) $@.tmp | $(GREP) -v 'debugMesg([3-9]' > $@ ;\
	else \
		mv $@.tmp $@ ;\
	fi
	cp -Rp $@ $(distdir)/

.PHONY: clean
clean:
	rm -f $(bin_SCRIPTS) *.tmp
	rm -f $(distdir)/*

