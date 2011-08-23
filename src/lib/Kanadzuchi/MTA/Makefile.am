# $Id: Makefile.am,v 1.4.2.2 2011/08/23 21:28:27 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/MTA,
# is processed by automake to create Makefile.in.

SUBDIRS = JP US User
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/MTA
pkgdatadir = @libdir@/Kanadzuchi/MTA
pkgdata_DATA = Courier.pm Exim.pm Fallback.pm Postfix.pm \
		qmail.pm Sendmail.pm MODULES

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm
	rm -f $(distdir)/MODULES

