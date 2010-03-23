# $Id: Makefile.am,v 1.1 2010/03/23 08:51:04 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/libexec,
# is processed by automake to create Makefile.in.

modules = mp-startup.pl
distdir = $(BUILDROOT)/dist/libexec
instdir = @libexecdir@
all-am: distlib
distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) 
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: distlib
	$(INSTALL) -c -m 0755 $(distdir)/$(modules) $(instdir)/

uninstall-am:
	rm -f $(instdir)/$(modules)

.PHONY: clean
clean:
	rm -f $(distdir)/$(modules)

