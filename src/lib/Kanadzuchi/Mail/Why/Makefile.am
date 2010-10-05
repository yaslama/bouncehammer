# $Id: Makefile.am,v 1.3 2010/10/05 11:19:09 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/lib/Kanadzuchi/Mail/Why,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Why
pkgdatadir = @libdir@/Kanadzuchi/Mail/Why
pkgdata_DATA = ExceedLimit.pm Filtered.pm HostUnknown.pm MailboxFull.pm \
		RelayingDenied.pm SystemFull.pm MesgTooBig.pm \
		UserUnknown.pm Rejected.pm SecurityError.pm \
		SystemError.pm ContentError.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

