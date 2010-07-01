# $Id: Makefile.am,v 1.1 2010/06/25 19:29:26 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Statistics,
# is processed by automake to create Makefile.in.

SUBDIRS = Stored
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Statistics
pkgdatadir = @libdir@/Kanadzuchi/Statistics
pkgdata_DATA = Stored.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

