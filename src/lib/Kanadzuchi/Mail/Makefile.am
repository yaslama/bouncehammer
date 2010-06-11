# $Id: Makefile.am,v 1.3 2010/06/10 09:17:17 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail,
# is processed by automake to create Makefile.in.

SUBDIRS = Bounced Group Stored Why
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail
instdir = @prefix@/lib/Kanadzuchi/Mail/Group
modules = Group.pm
pkgdatadir = @libdir@/Kanadzuchi/Mail
pkgdata_DATA = Bounced.pm Stored.pm Why.pm

all-am: distlib
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) -e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: all-am
	test -d $(instdir) || mkdir -p $(instdir)
	for L in $(modules) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$L $(instdir)/ ;\
	done
	test -d $(pkgdatadir) || mkdir -p $(pkgdatadir)
	for P in $(pkgdata_DATA) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$P $(pkgdatadir)/ ;\
	done

uninstall-am:
	rm -f $(instdir)/$(modules)
	rm -f $(pkgdatadir)/*.pm

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

