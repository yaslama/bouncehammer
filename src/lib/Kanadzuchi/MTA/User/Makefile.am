# $Id: Makefile.am,v 1.1.2.1 2011/08/23 21:29:28 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/MTA/User,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA/User
pkgdatadir = @libdir@/Kanadzuchi/MTA/User
pkgdata_DATA = 

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

