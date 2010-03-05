# $Id: Makefile.am,v 1.2 2010/03/05 01:14:05 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/UI,
# is processed by automake to create Makefile.in.

SUBDIRS = Web
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/UI
pkgdatadir = @libdir@/Kanadzuchi/UI
pkgdata_DATA = CLI.pm Web.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

