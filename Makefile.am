# $Id: Makefile.am,v 1.18 2010/02/22 05:58:48 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.

# Define macros #############################################################
ENGINENAME = Kanadzuchi
SYSTEMNAME = BounceHammer
SYSTEMVERSION = 2.0.0

KANADZUCHI_ROOT = @prefix@
KANADZUCHI_SBIN = @sbindir@
KANADZUCHI_DATUM = @datadir@
KANADZUCHI_ETC = @sysconfdir@
KANADZUCHI_BIN = @bindir@
KANADZUCHI_LIB = @libdir@
KANADZUCHI_VAR = @localstatedir@

# Commands
INSTALL = @INSTALL@
PERLDOC = @PERLDOC@
SQLITE = @SQLITE@
SHELL = @SHELL@
XARGS = @XARGS@
CHOWN = @CHOWN@
CHMOD = @CHMOD@
TOUCH = @TOUCH@
PROVE = @PROVE@
FIND = @FIND@
PERL = @PERL@
CPAN = @CPAN@
GREP = @GREP@
SED = @SED@
CAT = @CAT@

# Switches
DEBUG = @ENABLE_DEBUGCODE@


# Define targets ############################################################
.PHONY:	clean
fresh: clean all
all: build
build: build-scripts build-conf build-template
install: build build-dirs install-modules install-progs install-conf install-files message

build-scripts:
	mkdir -p ./dist/{lib,bin} ;\
	mkdir -p ./dist/share/script ;\
	$(CAT) ./src/lib/Kanadzuchi.pm | $(SED) \
			-e 's|__KANADZUCHIROOT__|$(KANADZUCHI_ROOT)|g' \
			-e 's|__KANADZUCHIETC__|$(KANADZUCHI_ETC)|g' \
			-e 's|\([^:]\)//|\1/|g' \
		> ./dist/lib/Kanadzuchi.pm ;\
	/bin/cp -R ./src/lib/Kanadzuchi ./dist/lib/ ;\
	/bin/rm ./dist/lib/Kanadzuchi/Mail/Group/Neighbor.pm ;\
	$(CAT) ./src/lib/Kanadzuchi/Mail/Group/Neighbor.pm | $(SED) \
		-e 's|__KANADZUCHIROOT__|$(KANADZUCHI_ROOT)|g' \
		-e 's|__KANADZUCHIETC__|$(KANADZUCHI_ETC)|g' \
		-e 's|__KANADZUCHIDATA__|$(KANADZUCHI_DATUM)|g' \
		-e 's|__KANADZUCHILIB__|$(KANADZUCHI_LIB)|g' \
		-e 's|__KANADZUCHIBIN__|$(KANADZUCHI_BIN)|g' \
		-e 's|__KANADZUCHIVAR__|$(KANADZUCHI_VAR)|g' \
		-e 's|\([^:]\)//|\1/|g' \
	> ./dist/lib/Kanadzuchi/Mail/Group/Neighbor.pm ;\
	for P in `ls -1 ./src/bin`; do \
		PROGNAME=`basename $$P`; \
		$(CAT) ./src/bin/$$P | $(SED) \
			-e 's|__KANADZUCHIROOT__|$(KANADZUCHI_ROOT)|g' \
			-e 's|__KANADZUCHIETC__|$(KANADZUCHI_ETC)|g' \
			-e 's|__KANADZUCHIDATA__|$(KANADZUCHI_DATUM)|g' \
			-e 's|__KANADZUCHILIB__|$(KANADZUCHI_LIB)|g' \
			-e 's|__KANADZUCHIBIN__|$(KANADZUCHI_BIN)|g' \
			-e 's|__KANADZUCHIVAR__|$(KANADZUCHI_VAR)|g' \
			-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
			-e 's|\([^:]\)//|\1/|g' \
			> ./dist/bin/$$PROGNAME ;\
		if [ "$(ENABLE_DEBUGCODE)" -eq "0" ]; then \
			$(CAT) ./dist/bin/$$PROGNAME | $(GREP) -v 'debugMesg([3-9]' > ./dist/bin/$$PROGNAME.tmp ;\
			/bin/mv ./dist/bin/$$PROGNAME.tmp ./dist/bin/$$PROGNAME ;\
		fi ; \
		$(CHMOD) a+x ./dist/bin/$$PROGNAME ;\
	done ; \
	for CGI in `ls -1 ./src/cgi`; do \
		$(CAT) ./src/cgi/$$CGI | $(SED) \
				-e 's|__KANADZUCHIROOT__|$(KANADZUCHI_ROOT)|g' \
				-e 's|__KANADZUCHIETC__|$(KANADZUCHI_ETC)|g' \
				-e 's|__KANADZUCHIDATA__|$(KANADZUCHI_DATUM)|g' \
				-e 's|__KANADZUCHILIB__|$(KANADZUCHI_LIB)|g' \
				-e 's|__KANADZUCHIBIN__|$(KANADZUCHI_BIN)|g' \
				-e 's|__KANADZUCHIVAR__|$(KANADZUCHI_VAR)|g' \
				-e 's|__PERLEXECUTABLE__|!$(PERL)|g' \
				-e 's|\([^:]\)//|\1/|g' \
			> ./dist/share/script/$$CGI ; \
	done ;\
	/bin/cp -R ./src/sql/* ./dist/share/script/ ;\
	$(CHMOD) 0644 ./dist/share/script/* ;\
	$(CHMOD) a+x ./dist/share/script/*.cgi ;

build-conf:
	mkdir -p ./dist/etc ;\
	for CONF in `ls -1 ./src/etc`; do \
		$(CAT) ./src/etc/$$CONF | $(SED) \
				-e 's|__KANADZUCHIROOT__|$(KANADZUCHI_ROOT)|g' \
				-e 's|__KANADZUCHIETC__|$(KANADZUCHI_ETC)|g' \
				-e 's|__KANADZUCHIDATA__|$(KANADZUCHI_DATUM)|g' \
				-e 's|__KANADZUCHILIB__|$(KANADZUCHI_LIB)|g' \
				-e 's|__KANADZUCHIBIN__|$(KANADZUCHI_BIN)|g' \
				-e 's|__KANADZUCHIVAR__|$(KANADZUCHI_VAR)|g' \
				-e 's|\([^:]\)//|\1/|g' \
			> ./dist/etc/$$CONF ;\
		$(CHMOD) 0644 ./dist/etc/$$CONF ;\
	done ;\
	/bin/cp ./src/etc/test-run.cf ./dist/etc/ ; \
	/bin/cp ./src/etc/neighbor-domains-example ./dist/etc/ ;\
	/bin/cp ./src/etc/crontab-example ./dist/etc ; \
	/bin/cp ./src/etc/aliases-example ./dist/etc ;

build-template:
	mkdir -p ./dist/share/template/standard ; \
	/bin/cp -R ./template/standard/* ./dist/share/template/standard ; \
	$(FIND) ./dist/share/template/standard -type f | $(XARGS) $(CHMOD) 0644 ; 

build-dirs:
	mkdir -pm 0755 $(KANADZUCHI_ROOT) ;\
	mkdir -pm 0755 $(KANADZUCHI_ETC) ;\
	mkdir -pm 0755 $(KANADZUCHI_SBIN) ;\
	mkdir -pm 0755 $(KANADZUCHI_BIN) ;\
	mkdir -pm 0755 $(KANADZUCHI_LIB) ;\
	mkdir -pm 0755 $(KANADZUCHI_DATUM)/{script,template,example} ;\
	mkdir -pm 0755 $(KANADZUCHI_DATUM)/template/standard ;\
	mkdir -pm 0755 $(KANADZUCHI_VAR)/{cache,db,incoming,log,run,spool,tmp} ;\
	$(CHMOD) g+w  $(KANADZUCHI_VAR)/db ;\
	$(CHMOD) 1777 $(KANADZUCHI_VAR)/{cache,incoming,run,spool,tmp} ;

test:
	mkdir -p ./.test ;\
	$(PROVE) -w;

install-modules:
	if [ -w "$(KANADZUCHI_LIB)" ]; then \
		$(INSTALL) -p -m 0644 ./dist/lib/Kanadzuchi.pm $(KANADZUCHI_LIB)/ ;\
		$(INSTALL) -p -m 0644 ./dist/share/script/*.sql $(KANADZUCHI_DATUM)/script/ ;\
		/bin/cp -R ./dist/lib/Kanadzuchi $(KANADZUCHI_LIB)/ ;\
		$(FIND) $(KANADZUCHI_LIB)/Kanadzuchi -type f -name '*.pm' | $(XARGS) $(CHMOD) 0644 ;\
	fi ;

install-progs:
	if [ -w "$(KANADZUCHI_BIN)" ]; then \
		for P in `ls -1 ./dist/bin/`; do \
			$(INSTALL) -p -m 0755 ./dist/bin/$$P $(KANADZUCHI_BIN)/ ;\
		done ;\
	fi ;

install-conf:
	if [ -w "$(KANADZUCHI_ETC)" ]; then \
		$(INSTALL) -p -m 0644 ./dist/etc/bouncehammer.cf-example $(KANADZUCHI_ETC)/ ;\
		$(INSTALL) -p -m 0644 ./dist/etc/webui.cf-example $(KANADZUCHI_ETC)/ ;\
		$(INSTALL) -p -m 0644 ./dist/etc/test-run.cf $(KANADZUCHI_ETC)/ ;\
		$(INSTALL) -p -m 0644 ./dist/etc/aliases-example $(KANADZUCHI_ETC)/ ;\
		$(INSTALL) -p -m 0644 ./dist/etc/crontab-example $(KANADZUCHI_ETC)/ ;\
		$(INSTALL) -p -m 0644 ./dist/etc/neighbor-domains-example $(KANADZUCHI_ETC)/ ;\
	fi;

install-files:
	test -w $(KANADZUCHI_DATUM)/ && \
		/bin/cp -pR ./dist/share/* $(KANADZUCHI_DATUM)/ ;\
	$(FIND) $(KANADZUCHI_DATUM) -type f -exec $(CHMOD) 0644 {} \; ;\
	$(CHMOD) a+x $(KANADZUCHI_DATUM)/script/*.cgi ; \
	test -w $(KANADZUCHI_DATUM)/ && \
		/bin/cp -pR ./examples/* $(KANADZUCHI_DATUM)/example ;\
	$(CHMOD) 0644 $(KANADZUCHI_DATUM)/example/* ;

message:
	@echo ;
	@echo "-----------------------------------------------------------------------------";
	@echo " $(SYSTEMNAME) $(SYSTEMVERSION) " ;
	@echo "-----------------------------------------------------------------------------";
	@echo " To use BounceHammer Command line tools";
	@echo ;
	@echo "  1. Set up and start a database(PostgreSQL, MySQL, or SQLite)" ;
	@echo "  2. Create tables" ;
	@echo "       a. Run $(KANADZUCHI_DATUM)/script/{PostgreSQL,MySQL,SQLite}.sql" ;
	@echo "       b. Run $(KANADZUCHI_DATUM)/script/mastertable-*.sql" ;
	@echo "       c. Run $(KANADZUCHI_DATUM)/script/records-example.sql" ;
	@echo "  3. Copy $(KANADZUCHI_ETC)/bouncehammer.cf-example ";
	@echo "       $(KANADZUCHI_ETC)/bouncehammer.cf";
	@echo "  4. Edit $(KANADZUCHI_ETC)/bouncehammer.cf ";
	@echo "  5. Install a perl module: 'DBD::Pg' or 'DBD::mysql' or 'DBD::SQLite'."
	@echo "  6. $(KANADZUCHI_BIN)/* command line tools are avaliable";
	@echo ;
	@echo "-----------------------------------------------------------------------------";
	@echo " To use BounceHammer WebUI";
	@echo ;
	@echo "  1. Configure your web server, turn 'ExecCGI' on ";
	@echo "  2. Copy $(KANADZUCHI_ETC)/webui.cf-example ";
	@echo "       $(KANADZUCHI_ETC)/webui.cf";
	@echo "  3. Edit $(KANADZUCHI_ETC)/webui.cf ";
	@echo "  4. Copy $(KANADZUCHI_DATUM)/script/bouncehammer.cgi to 'DocumentRoot'" ;
	@echo "  5. Do not forget chmod a+x 'DocumentRoot'/bouncehammer.cgi";
	@echo "  6. Open 'http://yourhost/path/to/docroot/bouncehammer.cgi/index' ";
	@echo ;
	@echo "-----------------------------------------------------------------------------";
	@echo " To show this screen, type 'make message' and hit 'Return' key";
	@echo "-----------------------------------------------------------------------------";
	@echo ;

clean:
	rm -f ./*~ 2> /dev/null ; \
	rm -f ./*.bak 2> /dev/null ; \
	rm -f ./*.tmp 2> /dev/null ; \
	rm -f ./*.db 2> /dev/null ; \
	rm -fr ./.temp/ 2> /dev/null ;\
	rm -fr ./dist/ 2> /dev/null ;\
	rm -fr ./.test 2> /dev/null

uninstall:
	test -w $(KANADZUCHI_BIN) && rm -fr $(KANADZUCHI_BIN)/ ;\
	test -w $(KANADZUCHI_LIB) && rm -fr $(KANADZUCHI_LIB)/ ;\
	test -w $(KANADZUCHI_SBIN) && rm -fr $(KANADZUCHI_SBIN)/ ;\
	test -w $(KANADZUCHI_DATUM) && rm -fr $(KANADZUCHI_DATUM)/ ;

