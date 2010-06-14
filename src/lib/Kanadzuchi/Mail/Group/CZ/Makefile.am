# $Id: Makefile.am,v 1.1 2010/06/14 11:23:17 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Group/CZ,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Group/CZ
pkgdatadir = @libdir@/Kanadzuchi/Mail/Group/CZ
pkgdata_DATA = WebMail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

