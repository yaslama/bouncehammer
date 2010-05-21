# $Id: Makefile.am,v 1.2 2010/05/19 18:25:03 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail,
# is processed by automake to create Makefile.in.

SUBDIRS = Bounced Group Stored Why
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail
pkgdatadir = @libdir@/Kanadzuchi/Mail
pkgdata_DATA = Bounced.pm Stored.pm Group.pm Why.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

