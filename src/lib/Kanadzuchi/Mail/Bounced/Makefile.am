# $Id: Makefile.am,v 1.4 2010/11/13 19:16:22 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Bounced,
# is processed by automake to create Makefile.in.
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Bounced
pkgdatadir = @libdir@/Kanadzuchi/Mail/Bounced
pkgdata_DATA = Generic.pm Yahoo.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

