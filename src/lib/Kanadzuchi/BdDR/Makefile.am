# $Id: Makefile.am,v 1.2 2010/05/16 23:58:20 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/BdDR,
# is processed by automake to create Makefile.in.

SUBDIRS = BounceLogs
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/BdDR
pkgdatadir = @libdir@/Kanadzuchi/BdDR
pkgdata_DATA = BounceLogs.pm Cache.pm Page.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

