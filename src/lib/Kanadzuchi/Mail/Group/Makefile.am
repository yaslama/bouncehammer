# $Id: Makefile.am,v 1.25.2.9 2011/03/13 06:14:53 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/Mail/Group,
# is processed by automake to create Makefile.in.

SUBDIRS = AE AL AR AT AU AW BE BG BM BR BS CA CH CL CN CO CR CZ DE DK DO
	  EC EG ES FR GR GT HK HN HR HU ID IE IN IL IR IS IT JM JP KE KR 
	  LB LK LU LV MA ME MK MO MU MX MY NG NI NL NO NP NZ OM 
	  PA PE PH PK PL PR PT PY RO RU SA SE SG SK SR SV TH TR TW 
	  UA UG UK US UY VE VN ZA
distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Group
instdir = @prefix@/lib/Kanadzuchi/Mail/Group
modules = Neighbor.pm
pkgdatadir = @libdir@/Kanadzuchi/Mail/Group
pkgdata_DATA = Cellphone.pm Smartphone.pm Webmail.pm

all-am: distlib
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

distlib:
	test -d $(distdir) || mkdir -p $(distdir)
	$(CAT) $(modules) | $(SED) -e 's|__KANADZUCHIROOT__|@prefix@|g' \
		-e 's|\([^:]\)//|\1/|g' > $(distdir)/$(modules)

install-am: all-am
	test -d $(instdir) || mkdir -p $(instdir)
	for L in $(modules) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$L $(instdir)/ ;\
	done
	test -d $(pkgdatadir) || mkdir -p $(pkgdatadir)
	for P in $(pkgdata_DATA) ; do \
		$(INSTALL) -c -m 0644 $(distdir)/$$P $(pkgdatadir)/ ;\
	done

uninstall-am:
	rm -f $(instdir)/$(modules)
	rm -f $(pkgdatadir)/*.pm

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

