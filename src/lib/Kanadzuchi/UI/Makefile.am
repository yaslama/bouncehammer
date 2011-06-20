# $Id: Makefile.am,v 1.5.2.1 2011/06/20 03:43:41 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/UI,
# is processed by automake to create Makefile.in.
if WEBUI
SUBDIRS = Web
else
SUBDIRS =
endif
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/UI
pkgdatadir = @libdir@/Kanadzuchi/UI
if WEBUI
pkgdata_DATA = CLI.pm Web.pm
else
pkgdata_DATA = CLI.pm
endif

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm
