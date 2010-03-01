# $Id: Makefile.am,v 1.1 2010/03/01 21:00:15 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/RDB/Table,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/RDB/Table
pkgdatadir = @libdir@/Kanadzuchi/RDB/Table
pkgdata_DATA = Addressers.pm Destinations.pm HostGroups.pm Providers.pm \
	Reasons.pm SenderDomains.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

