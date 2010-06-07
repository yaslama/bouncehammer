# $Id: Makefile.am,v 1.7 2010/05/29 11:34:45 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi,
# is processed by automake to create Makefile.in.

SUBDIRS = API Archive Config Mail Mbox MIME BdDR UI
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi
pkgdatadir = @libdir@/Kanadzuchi
pkgdata_DATA = API.pm Address.pm Archive.pm Exceptions.pm Log.pm Mail.pm \
	Mbox.pm Metadata.pm BdDR.pm RFC1893.pm RFC2606.pm RFC2822.pm \
	Statistics.pm String.pm Time.pm UI.pm Iterator.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

