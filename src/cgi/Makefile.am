# $Id: Makefile.am,v 1.3 2010/03/01 23:41:35 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/cgi, is processed by 
# automake to create Makefile.in.

pkgdatadir = @datarootdir@/script
pkgdata_DATA = api.cgi bouncehammer.cgi
SUFFIXES = .PL .cgi

$(pkgdata_DATA):
	$(CAT) $*.PL | $(SED) \
		-e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|__KANADZUCHIDATA__|@datadir@|g' \
		-e 's|__KANADZUCHIETC__|@sysconfdir@|g' \
		-e 's|__KANADZUCHIBIN__|@bindir@|g' \
		-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
		-e 's|\([^:]\)//|\1/|g' > $@

.PHONY: clean
clean:
	rm -f $(pkgdata_DATA)

