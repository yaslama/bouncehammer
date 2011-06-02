# $Id: Makefile.am,v 1.3.2.1 2011/06/02 18:39:09 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/libexec,
# is processed by automake to create Makefile.in.

modules = mp-startup.pl
distdir = $(BUILDROOT)/dist/libexec
instdir = @libexecdir@
all-am: distlib
distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|__PERLEXTERNALLIB__|$(PERL_EXTLIB)|g' \
		-e 's|\([^:]\)//|\1/|g' > $(modules)
	test "X$(PERL_EXTLIB)" = "X" || \
		( $(GREP) -v PERL_EXTLIB $(modules) > $(modules).tmp && mv $(modules).tmp $(modules) )
	/bin/cp $(modules) $(distdir)/$(modules)

install-am: distlib
	test -d $(instdir) || mkdir -p $(instdir)
	$(INSTALL) -c -m 0755 $(distdir)/$(modules) $(instdir)/

uninstall-am:
	rm -f $(instdir)/$(modules)

.PHONY: clean
clean:
	rm -f $(distdir)/$(modules)

