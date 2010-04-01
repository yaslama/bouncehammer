# $Id: Makefile.am,v 1.2 2010/04/01 08:04:50 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mbox,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mbox
pkgdatadir = @libdir@/Kanadzuchi/Mbox
pkgdata_DATA = Google.pm KLab.pm aubyKDDI.pm qmail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

