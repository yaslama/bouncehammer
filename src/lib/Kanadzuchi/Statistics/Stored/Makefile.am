# $Id: Makefile.am,v 1.1.2.1 2011/06/20 03:43:40 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/Statistics/Stored,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Statistics/Stored
pkgdatadir = @libdir@/Kanadzuchi/Statistics/Stored
pkgdata_DATA = BdDR.pm YAML.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

