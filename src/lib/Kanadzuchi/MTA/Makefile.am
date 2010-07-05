# $Id: Makefile.am,v 1.2 2010/07/04 23:45:50 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/MTA,
# is processed by automake to create Makefile.in.

SUBDIRS = JP
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA
pkgdatadir = @libdir@/Kanadzuchi/MTA
pkgdata_DATA = Google.pm Postfix.pm qmail.pm Sendmail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

