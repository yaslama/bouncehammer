# $Id: Makefile.am,v 1.1 2010/06/14 16:23:13 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Group/CN,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Group/CN
pkgdatadir = @libdir@/Kanadzuchi/Mail/Group/CN
pkgdata_DATA = WebMail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

