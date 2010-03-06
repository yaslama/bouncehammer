# $Id: Makefile.am,v 1.3 2010/03/06 04:42:49 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi,
# is processed by automake to create Makefile.in.

SUBDIRS = API Archive Config Mail Mbox RDB UI
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi
pkgdatadir = @libdir@/Kanadzuchi
pkgdata_DATA = API.pm Address.pm Archive.pm Exceptions.pm Log.pm Mail.pm \
	Mbox.pm Metadata.pm RDB.pm RFC2606.pm RFC2822.pm Statistics.pm \
	String.pm Time.pm UI.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

