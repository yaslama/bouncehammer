# $Id: Makefile.am,v 1.2 2010/03/01 23:41:53 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Group,
# is processed by automake to create Makefile.in.

SUBDIRS = JP
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Group
instdir = @prefix@/lib/Kanadzuchi/Mail/Group
modules = Neighbor.pm
pkgdatadir = @libdir@/Kanadzuchi/Mail/Group
pkgdata_DATA = WebMail.pm

distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) -e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: all-am
	$(INSTALL) -c -m 0644 $(distdir)/$(modules) $(instdir)

uninstall-am:
	rm -f $(instdir)/$(modules)

all-am: distlib
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

