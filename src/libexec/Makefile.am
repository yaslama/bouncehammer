# $Id: Makefile.am,v 1.3.2.2 2011/06/03 09:14:32 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/libexec,
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
		-e 's|\([^:]\)//|\1/|g' > $(modules).tmp
	test "X$(PERL_EXTLIB)" = "X" || \
		( $(GREP) -v PERL_EXTLIB $(modules).tmp > $(modules) && mv $(modules) $(modules).tmp )
	/bin/cp $(modules).tmp $(distdir)/$(modules)

install-am: distlib
	test -d $(instdir) || mkdir -p $(instdir)
	$(INSTALL) -c -m 0755 $(distdir)/$(modules) $(instdir)/

uninstall-am:
	rm -f $(instdir)/$(modules)

.PHONY: clean
clean:
	rm -f $(distdir)/$(modules)

