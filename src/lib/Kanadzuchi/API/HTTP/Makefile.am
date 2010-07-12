# $Id: Makefile.am,v 1.1 2010/07/12 14:23:11 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/API/HTTP,
# is processed by automake to create Makefile.in.
#
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/API/HTTP
modules = Dispatch.pm
pkgdatadir = @libdir@/Kanadzuchi/API/HTTP
instdir = $(pkgdatadir)
pkgdata_DATA = Select.pm Search.pm

all-am: distlib
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__KANADZUCHIDATA__|@datadir@|g' \
		-e 's|__KANADZUCHIETC__|@sysconfdir@|g' \
		-e 's|__KANADZUCHIBIN__|@bindir@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: distlib
	test -d $(instdir) || mkdir -p $(instdir)
	for L in $(modules) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$L $(instdir)/ ;\
	done
	test -d $(pkgdatadir) || mkdir -p $(pkgdatadir)
	for P in $(pkgdata_DATA) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$P $(pkgdatadir)/ ;\
	done

uninstall-am:
	rm -f $(instdir)/$(modules) 2> /dev/null
	rm -f $(pkgdatadir)/*.pm 2> /dev/null

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm 2> /dev/null
