# $Id: Makefile.am,v 1.23 2010/03/01 23:41:31 ak Exp $
# -Id: Makefile.am,v 1.14 2009/12/01 10:35:23 ak Exp -
# -Id: Makefile.am,v 1.14 2009/08/27 06:05:39 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# This is the auto-Makefile for BounceHammer, is processed by automake to create Makefile.in.
ENGINENAME = Kanadzuchi
SYSTEMNAME = BounceHammer
SYSVERSION = 2.0.0
SUBDIRS = src template

.PHONY: clean
instal-am: sublocalstatedir message
clean-am:
	rm -f ./*~ ./*.bak ./*.tmp ./*.db
	rm -fr ./.temp ./dist ./.test

check-pm:
	@test -x $(PERL) && test -f ./Modules.PL && $(PERL) ./Modules.PL check

test:
	@mkdir -p ./.test && test -w ./.test && $(PROVE) -w

sublocalstatedir:
	@mkdir -pm 0755 @localstatedir@/{cache,db,incoming,log,run,spool,tmp}
	@$(CHMOD) g+w  @localstatedir@/db
	@$(CHMOD) 1777 @localstatedir@/{cache,incoming,run,spool,tmp}

message:
	@echo
	@echo "-----------------------------------------------------------------------------"
	@echo " $(SYSTEMNAME) $(SYSVERSION) "
	@echo "-----------------------------------------------------------------------------"
	@echo " To use BounceHammer Command line tools"
	@echo
	@echo "  1. Set up and start a database(PostgreSQL, MySQL, or SQLite)"
	@echo "  2. Create tables"
	@echo "       a. Run @datadir@/script/{PostgreSQL,MySQL,SQLite}.sql"
	@echo "       b. Run @datadir@/script/mastertable-*.sql"
	@echo "       c. Run @datadir@/script/records-example.sql"
	@echo "  3. Copy @sysconfdir@/bouncehammer.cf-example @sysconfdir@/bouncehammer.cf"
	@echo "  4. Edit @sysconfdir@/bouncehammer.cf "
	@echo "  5. Install a perl module: 'DBD::Pg' or 'DBD::mysql' or 'DBD::SQLite'."
	@echo "  6. @bindir@/* command line tools are avaliable"
	@echo
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
	@echo "-----------------------------------------------------------------------------"
	@echo " To show this screen, type 'make message' and hit 'Return' key"
	@echo " See more description at BounceHmammer website; http://bouncehammer.jp/"
	@echo "-----------------------------------------------------------------------------"
	@echo

