# $Id: Makefile.am,v 1.1 2010/03/01 20:59:57 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Bounced,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Bounced
pkgdatadir = @libdir@/Kanadzuchi/Mail/Bounced
pkgdata_DATA = Generic.pm NTTDoCoMo.pm SoftBank.pm aubyKDDI.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

