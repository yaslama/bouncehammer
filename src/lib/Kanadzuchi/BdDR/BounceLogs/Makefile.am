# $Id: Makefile.am,v 1.2.2.1 2011/06/20 03:43:40 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/BdDR/BounceLogs,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/BdDR/BounceLogs
pkgdatadir = @libdir@/Kanadzuchi/BdDR/BounceLogs
pkgdata_DATA = Masters.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

