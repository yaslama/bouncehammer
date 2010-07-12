# $Id: Makefile.am,v 1.10 2010/07/12 14:23:10 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/API,
# is processed by automake to create Makefile.in.
SUBDIRS = HTTP
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/API
pkgdatadir = @libdir@/Kanadzuchi/API
pkgdata_DATA = HTTP.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

