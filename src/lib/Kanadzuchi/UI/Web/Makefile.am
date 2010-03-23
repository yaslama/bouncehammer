# $Id: Makefile.am,v 1.6 2010/03/23 20:31:36 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/UI/Web,
# is processed by automake to create Makefile.in.
#
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/UI/Web
modules = Dispatch.pm
pkgdatadir = @libdir@/Kanadzuchi/UI/Web
instdir = $(pkgdatadir)
pkgdata_DATA = Index.pm MasterTables.pm Profile.pm Search.pm Summary.pm \
        Test.pm Token.pm Update.pm

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
	rm -f $(instdir)/$(modules)
	rm -f $(pkgdatadir)/*.pm

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

