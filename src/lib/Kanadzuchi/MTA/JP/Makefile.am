# $Id: Makefile.am,v 1.3.2.2 2011/08/23 21:28:27 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/MTA/JP,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA/JP
pkgdatadir = @libdir@/Kanadzuchi/MTA/JP
pkgdata_DATA = aubyKDDI.pm Biglobe.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

