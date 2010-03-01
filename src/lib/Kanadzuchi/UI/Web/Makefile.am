# $Id: Makefile.am,v 1.1 2010/03/01 21:00:19 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/UI/Web,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/UI/Web
pkgdatadir = @libdir@/Kanadzuchi/UI/Web
pkgdata_DATA = Index.pm MasterTables.pm Profile.pm Search.pm Summary.pm \
	Test.pm Token.pm Update.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

