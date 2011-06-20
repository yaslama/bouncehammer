# $Id: Makefile.am,v 1.4.2.1 2011/06/20 03:43:40 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/MTA,
# is processed by automake to create Makefile.in.

SUBDIRS = JP US
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA
pkgdatadir = @libdir@/Kanadzuchi/MTA
pkgdata_DATA = Courier.pm Exim.pm Fallback.pm Postfix.pm \
		qmail.pm Sendmail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

