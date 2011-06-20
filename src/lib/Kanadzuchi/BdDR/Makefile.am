# $Id: Makefile.am,v 1.3.2.1 2011/06/20 03:43:40 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/BdDR,
# is processed by automake to create Makefile.in.

SUBDIRS = BounceLogs
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/BdDR
pkgdatadir = @libdir@/Kanadzuchi/BdDR
pkgdata_DATA = BounceLogs.pm Cache.pm DailyUpdates.pm Page.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

