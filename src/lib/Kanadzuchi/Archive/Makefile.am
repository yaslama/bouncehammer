# $Id: Makefile.am,v 1.1.2.1 2011/06/20 03:43:40 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/Archive,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Archive
pkgdatadir = @libdir@/Kanadzuchi/Archive
pkgdata_DATA = Bzip2.pm Gzip.pm Zip.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

