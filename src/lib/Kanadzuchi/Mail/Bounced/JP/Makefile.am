# $Id: Makefile.am,v 1.1 2010/06/10 09:13:41 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Bounced/JP,
# is processed by automake to create Makefile.in.
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Bounced/JP
pkgdatadir = @libdir@/Kanadzuchi/Mail/Bounced/JP
pkgdata_DATA = NTTDoCoMo.pm aubyKDDI.pm SoftBank.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

