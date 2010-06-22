# $Id: Makefile.am,v 1.43 2010/06/21 10:14:04 ak Exp $
# -Id: Makefile.am,v 1.14 2009/12/01 10:35:23 ak Exp -
# -Id: Makefile.am,v 1.14 2009/08/27 06:05:39 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer, is processed by automake to create Makefile.in.
ENGINENAME = Kanadzuchi
SYSTEMNAME = BounceHammer
SYSVERSION = 2.4.0
CMD_MODULE = ./Modules.PL
CMD_IMPLEM = ./Implement.PL
PATCH_TBOP = ./diff/perl-TB-option-on-filehandle.patch
if WEBUI
SUBDIRS = src template
else
SUBDIRS = src
endif

.PHONY: clean
all-am: Makefile apply-patch
install-am: sublocalstatedir message
clean-am: reverse-patch
	rm -f ./*~ ./*.bak ./*.tmp ./*.db ./diff/*.done
	find . -name '*.rej' -type f -exec rm -f {} \;
	find . -name '*.rej.orig' -type f -exec rm -f {} \;
	rm -fr ./.temp ./.test
	rm -f /tmp/hammer.1970-01-01.11111111.111111.tmp
	rm -f /tmp/bouncehammer-test.db

distclean-am: clean-am
	rm -fr ./dist

check-pm:
	@test -x $(PERL) && test -f $(CMD_MODULE) && $(PERL) $(CMD_MODULE) check

check-implement:
	@test -x $(PERL) && test -f $(CMD_IMPLEM) && $(PERL) $(CMD_IMPLEM) tb

test:
	@mkdir -p ./.test && test -w ./.test && $(PROVE) -w

apply-patch:
	if [ "$(PI_IMPLEMENT_TB)" = "NO" ]; then \
		$(PATCH) -tuNs -p0 < $(PATCH_TBOP) || true ;\
		$(TOUCH) $(PATCH_TBOP).done ;\
	else \
		true ;\
	fi

reverse-patch:
	if [ "$(PI_IMPLEMENT_TB)" = "NO" ]; then \
		test -f $(PATCH_TBOP).done && $(PATCH) -tuRs -p0 < $(PATCH_TBOP) || true ;\
		rm -f $(PATCH_TBOP).done ;\
	fi

sublocalstatedir:
	mkdir -pm 0755 @localstatedir@/{cache,db,incoming,log,run,spool,tmp}
	$(CHMOD) g+w  @localstatedir@/db
	$(CHMOD) 1777 @localstatedir@/{cache,incoming,run,spool,tmp}

uninstall-old-files:
	@echo "Uninstall files which are removed at ver 2.3.0"

	rm -f @prefix@/lib/Kanadzuchi/RDB.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/MasterTable.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/Addressers.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/BounceLogs.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/Destinations.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/HostGroups.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/Providers.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/Reasons.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Schema/SenderDomains.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/Addressers.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/Destinations.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/HostGroups.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/Providers.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/Reasons.pm
	rm -f @prefix@/lib/Kanadzuchi/RDB/Table/SenderDomains.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Stored/RDB.pm
	rm -f @prefix@/share/template/standard/element/div-pager.en.html
	rm -f @prefix@/share/template/standard/element/div-pager.ja.html
	rm -f @prefix@/share/template/standard/stylesheet/pager.css

	@echo "Uninstall files which are renamed at ver 2.3.4"
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/NTTDoCoMo.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/aubyKDDI.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/SoftBank.pm

message:
	@echo
	@echo "-----------------------------------------------------------------------------"
	@echo " $(SYSTEMNAME) $(SYSVERSION) "
	@echo "-----------------------------------------------------------------------------"
	@echo " To use BounceHammer Command line tools"
	@echo
	@echo "  1. Setup and start database(PostgreSQL, MySQL, or SQLite)"
	@echo "  2. Create tables"
	@echo "       a. Run @datadir@/script/{PostgreSQL,MySQL,SQLite}.sql"
	@echo "       b. Run @datadir@/script/mastertable-*.sql"
	@echo "       c. Run @datadir@/script/records-example.sql"
	@echo "  3. Copy @sysconfdir@/bouncehammer.cf-example @sysconfdir@/bouncehammer.cf"
	@echo "  4. Edit @sysconfdir@/bouncehammer.cf "
	@echo "  5. Install the perl module: 'DBD::Pg' or 'DBD::mysql' or 'DBD::SQLite'."
	@echo "  6. @bindir@/* command line tools are avaliable"
	@echo
if WEBUI
	@echo "-----------------------------------------------------------------------------"
	@echo " To use BounceHammer WebUI"
	@echo
	@echo "  1. Configure your web server, turn 'ExecCGI' on "
	@echo "  2. Copy @sysconfdir@/webui.cf-example @sysconfdir@/webui.cf"
	@echo "  3. Edit @sysconfdir@/webui.cf "
	@echo "  4. Copy @datadir@/script/bouncehammer.cgi to 'DocumentRoot'"
	@echo "  5. Do not forget chmod a+x 'DocumentRoot'/bouncehammer.cgi"
	@echo "  6. Open 'http://yourhost/path/to/docroot/bouncehammer.cgi/index' "
	@echo
endif
	@echo "-----------------------------------------------------------------------------"
	@echo " To show this screen, type 'make message' and hit 'Return' key"
	@echo " See more description at BounceHmammer website; http://bouncehammer.jp/"
	@echo "-----------------------------------------------------------------------------"
	@echo

