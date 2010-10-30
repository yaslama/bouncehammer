# $Id: Makefile.am,v 1.53 2010/10/30 17:31:08 ak Exp $
# -Id: Makefile.am,v 1.14 2009/12/01 10:35:23 ak Exp -
# -Id: Makefile.am,v 1.14 2009/08/27 06:05:39 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer, is processed by automake to create Makefile.in.
ENGINENAME = Kanadzuchi
SYSTEMNAME = BounceHammer
SYSVERSION = 2.6.0
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
	@mkdir -p ./.test && test -w ./.test && $(PROVE)

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
	mkdir -pm 0755 @localstatedir@/cache
	mkdir -pm 0755 @localstatedir@/db
	mkdir -pm 0755 @localstatedir@/incoming
	mkdir -pm 0755 @localstatedir@/log
	mkdir -pm 0755 @localstatedir@/mail
	mkdir -pm 0755 @localstatedir@/run
	mkdir -pm 0755 @localstatedir@/spool
	mkdir -pm 0755 @localstatedir@/tmp
	$(CHMOD) g+w  @localstatedir@/db
	$(CHMOD) 1777 @localstatedir@/cache
	$(CHMOD) 1777 @localstatedir@/incoming
	$(CHMOD) 1777 @localstatedir@/run
	$(CHMOD) 1777 @localstatedir@/spool
	$(CHMOD) 1777 @localstatedir@/tmp

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
	rm -f @prefix@/share/template/standard/element/div-pager.??.html
	rm -f @prefix@/share/template/standard/stylesheet/pager.css

	@echo "Uninstall files which are renamed at ver 2.4.0"
	rm -f @prefix@/lib/Kanadzuchi/API/Dispatch.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/NTTDoCoMo.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/aubyKDDI.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Bounced/SoftBank.pm
	rm -f @prefix@/lib/Kanadzuchi/Mail/Why/TooBig.pm
	rm -f @prefix@/lib/Kanadzuchi/Mbox/*.pm
	rm -f @prefix@/share/template/standard/page/*.en.html
	rm -f @prefix@/share/template/standard/page/*.ja.html
	rm -f @prefix@/share/template/standard/element/*.en.html
	rm -f @prefix@/share/template/standard/element/*.ja.html
	rm -f @prefix@/share/template/standard/help/*.html
	rm -rf @prefix@/lib/Kanadzuchi/Mbox/
	rm -rf @prefix@/share/template/standard/help/

	@echo "Uninstall files which are renamed at ver 2.6.0"
	rm -f @prefix@/lib/Kanadzuchi/Mail/Why/Makefile.am
	rm -f @prefix@/lib/Kanadzuchi/MTA/Google.pm

message:
	@echo "-----------------------------------------------------------------------------"
	@echo " ****** Upgrade information is available at ./UPGRADE ******"
	@echo "-----------------------------------------------------------------------------"
	@echo " $(SYSTEMNAME) $(SYSVERSION) "
	@echo "-----------------------------------------------------------------------------"
	@echo " To use BounceHammer Command line tools"
	@echo
	@echo "  1. Setup and start database(PostgreSQL, MySQL, or SQLite)"
	@echo "  2. Create tables"
	@echo "       a. Run @datadir@/script/{PostgreSQL,MySQL,SQLite}*.sql"
	@echo "       b. Run @datadir@/script/mastertable-*.sql"
	@echo "       c. Run @datadir@/script/records-example.sql"
	@echo "  3. Copy @sysconfdir@/bouncehammer.cf-example @sysconfdir@/bouncehammer.cf"
	@echo "  4. Edit @sysconfdir@/bouncehammer.cf "
	@echo "  5. Install the perl module: 'DBD::Pg' or 'DBD::mysql' or 'DBD::SQLite'."
	@echo "  6. @bindir@/* command line tools are avaliable"
	@echo "  7. bin/mailboxparser -v /path/to/message.eml"
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
	@echo " ****** Upgrade information is available at ./UPGRADE ******"
	@echo "-----------------------------------------------------------------------------"
	@echo

