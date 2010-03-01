# $Id: Makefile.am,v 1.1 2010/03/01 21:00:11 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/RDB,
# is processed by automake to create Makefile.in.

SUBDIRS = Schema Table
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/RDB
pkgdatadir = @libdir@/Kanadzuchi/RDB
pkgdata_DATA = MasterTable.pm Schema.pm Table.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

