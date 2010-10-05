# $Id: Makefile.am,v 1.3 2010/10/05 11:20:05 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/MTA,
# is processed by automake to create Makefile.in.

SUBDIRS = JP US
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA
pkgdatadir = @libdir@/Kanadzuchi/MTA
pkgdata_DATA = Exim.pm Fallback.pm Postfix.pm qmail.pm Sendmail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

