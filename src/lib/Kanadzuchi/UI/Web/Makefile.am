# $Id: Makefile.am,v 1.2 2010/03/23 06:39:50 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/UI/Web,
# is processed by automake to create Makefile.in.

modules = Index.pm MasterTables.pm Profile.pm Search.pm Summary.pm \
	Test.pm Token.pm Update.pm Dispatch.pm
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/UI/Web
instdir = @libdir@/Kanadzuchi/UI/Web
all-am: distlib
distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/
	$(CAT) $(modules) | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__KANADZUCHIDATA__|@datadir@|g' \
		-e 's|__KANADZUCHIETC__|@sysconfdir@|g' \
		-e 's|__KANADZUCHIBIN__|@bindir@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: distlib
	$(INSTALL) -c -m 0644 $(distdir)/$(modules) $(instdir)/

uninstall-am:
	rm -f $(instdir)/$(modules)

.PHONY: clean
clean:
	rm -f $(distdir)/$(modules)

