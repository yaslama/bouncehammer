# $Id: Makefile.am,v 1.5 2010/03/25 08:09:56 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer/src/etc, is processed by 
# automake to create Makefile.in.

sysconf_DATA = aliases-example bouncehammer.cf-example crontab-example \
	neighbor-domains-example prove.cf test-run.cf webui.cf-example \
	httpd.conf-example
distdir = $(BUILDROOT)/dist/etc
instdir = @sysconfdir@

all-am: distconf
distconf:
	test -d $(distdir) || mkdir -p $(distdir)
	for CF in $(sysconf_DATA); do \
		$(CAT) $$CF | $(SED) \
			-e 's|__KANADZUCHIROOT__|@prefix@|g' \
			-e 's|__KANADZUCHIETC__|@sysconfdir|g' \
			-e 's|__KANADZUCHIDATA__|@datarootdir@|g' \
			-e 's|__KANADZUCHILIB__|@prefix@/lib|g' \
			-e 's|__KANADZUCHIBIN__|@bindir@|g' \
			-e 's|__KANADZUCHIVAR__|@localstatedir@|g' \
			-e 's|\([^:]\)//|\1/|g' > $(distdir)/$$CF ; \
	done

install-am: distconf subsysconfdir
	for CF in $(sysconf_DATA); do \
		$(INSTALL) -m 0644 $(distdir)/$$CF $(instdir)/ ;\
	done

subsysconfdir:
	test -d $(instdir) || mkdir -p 0755 $(instdir)

.PHONY: clean
clean:
	rm -f $(distdir)/*-example
	rm -f $(distdir)/*.cf

