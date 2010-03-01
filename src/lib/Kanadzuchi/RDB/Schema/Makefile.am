# $Id: Makefile.am,v 1.1 2010/03/01 21:00:13 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/RDB/Schema,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/RDB/Schema
pkgdatadir = @libdir@/Kanadzuchi/RDB/Schema
pkgdata_DATA = Addressers.pm BounceLogs.pm Destinations.pm HostGroups.pm \
	Providers.pm Reasons.pm SenderDomains.pm 

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

