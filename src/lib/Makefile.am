# $Id: Makefile.am,v 1.3 2010/03/23 20:31:28 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib, is processed by 
# automake to create Makefile.in.

SUBDIRS = Kanadzuchi
modules = Kanadzuchi.pm
distdir = $(BUILDROOT)/dist/lib
instdir = @prefix@/lib
all-am: distlib
distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) -e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: distlib
	test -d $(instdir) || mkdir -p $(instdir)
	$(INSTALL) -c -m 0644 $(distdir)/$(modules) $(instdir)/

uninstall-am:
	rm -f $(instdir)/$(modules)

.PHONY: clean
clean:
	rm -f $(distdir)/$(modules)

