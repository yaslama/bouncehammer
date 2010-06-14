dnl #                                               -*- Autoconf -*-
dnl # Process this file with autoconf to produce a configure script.
dnl # $Id: configure.ac,v 1.41 2010/06/14 10:31:02 ak Exp $
dnl # -Id: configure.ac,v 1.8 2009/12/01 10:35:23 ak Exp -
dnl # -Id: configure.ac,v 1.35 2009/08/27 05:09:04 ak Exp -
dnl # Copyright (C) 2009,2010 Cubicroot Co. Ltd.
AC_PREREQ(2.61)
AC_INIT([BounceHammer], [2.3.4], [bugs@bouncehammer.jp])
AM_INIT_AUTOMAKE([foreign])
AC_PREFIX_DEFAULT(/usr/local/bouncehammer)
AC_CANONICAL_HOST

AC_SUBST(TARGET_OSTYPE)
AC_SUBST(TARGET_HOSTNAME)
AC_SUBST(TARGET_DOMAINNAME)

BUILDROOT=`pwd`
AC_SUBST(BUILDROOT)

dnl # Checks for programs.
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PATH_PROG(SHELL, sh, :, /bin:/usr/bin:/usr/local/bin)

AC_PROG_LN_S
AC_PATH_PROG(CAT, cat, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(CHMOD, chmod, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(TOUCH, touch, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(PATCH, patch, :, /bin:/usr/bin:/usr/local/bin)

AC_PATH_PROGS(GREP, grep egrep, :, /bin:/usr/bin:/usr/local/bin)
if test "x$GREP" = x; then
	AC_MSG_ERROR([*** Cannot find grep program(grep, egrep)])
fi

AC_PATH_PROG(FIND, find, :, /bin:/usr/bin:/usr/local/bin)
if test "x$FIND" = x; then
	AC_MSG_ERROR([*** Cannot find find program])
fi

AC_PATH_PROG(SED, sed, :, /bin:/usr/bin:/usr/local/bin)
if test "x$SED" = x; then
	AC_MSG_ERROR([*** Cannot find sed program])
fi

AC_ARG_ENABLE(webui,
	AC_HELP_STRING( [--enable-webui], [Enable WebUI(default=yes)] ),
	[enable_webui="$enableval"], [enable_webui="yes"])
	AM_CONDITIONAL([WEBUI], [test "x$enable_webui" = "xyes"])
if test "x$enable_webui" = "xyes"; then
	LIST_ARGV='list'
else
	LIST_ARGV='list-no-webui'
fi

AC_ARG_WITH([perl],
	AC_HELP_STRING(
		[--with-perl=PATH],
		[Path to perl binary, ex) /usr/local/bin/perl]),
	[WITH_PERLPATH=$withval],[WITH_PERLPATH=none])
if test "x$WITH_PERLPATH" = "xnone"; then
	AC_PATH_PROG(PERL, perl, :, /usr/local/bin:/usr/bin:/bin)
	if test "x$PERL" = x; then
		AC_MSG_ERROR([*** Cannot find perl program])
	fi
	AC_PATH_PROG(CPAN, cpan, :, /usr/local/bin:/usr//bin:/bin)
	if test "x$CPAN" = x; then
		AC_MSG_ERROR([*** Cannot find cpan program])
	fi
	AC_PATH_PROG(PERLDOC, perldoc, :, /usr/local/bin:/usr/bin:/bin)
	if test "x$PERLDOC" = x; then
		AC_MSG_ERROR([*** Cannot find perldoc program])
	fi
	AC_PATH_PROG(PROVE, prove, :, /usr/local/bin:/usr/bin:/bin)
	if test "x$PROVE" = x; then
		PROVE="$PERL -I./dist/lib"
	else
		PROVE="$PROVE -r --timer -I./dist/lib"
	fi
else
	PERL=$WITH_PERLPATH
	CPAN=`dirname $WITH_PERLPATH`/cpan
	PERLDOC=`dirname $WITH_PERLPATH`/perldoc
	PROVE=`dirname $WITH_PERLPATH`/prove
	if test "x$PROVE" = x; then
		PROVE="$PERL -I./dist/lib"
	else
		PROVE="$PROVE -r --timer -I./dist/lib"
	fi
fi

dnl # Checks for libraries.
MISSING_PERL_MODULES=''
MISSING_MODULE_COUNT=0
for PM in `$PERL ./Modules.PL $LIST_ARGV`; do
	AC_MSG_CHECKING(for $PM)
	if $PERL -M$PM -e '' > /dev/null 2>&1; then
		PM_PATH=`$PERLDOC -Ul $PM`
		AC_MSG_RESULT($PM_PATH)
	else
		AC_MSG_RESULT(no)
		MISSING_PERL_MODULES="$MISSING_PERL_MODULES $PM"
		MISSING_MODULE_COUNT=`expr $MISSING_MODULE_COUNT + 1`
	fi
done

if test -n "$MISSING_PERL_MODULES"; then
	echo
	echo '*** THE FOLLOWING PERL MODULES ARE REQUIRED ***'
	echo
	echo $MISSING_PERL_MODULES | tr ' ' '\n' | $SED 's|^| |g'
	echo
	AC_MSG_ERROR([*** $MISSING_MODULE_COUNT perl modules are missing])
else
	mkdir -p ./dist
fi

dnl # Check perl implementation
AC_MSG_CHECKING(for perl -T and -B operator on filehandles)
PI_TBOPERATOR=`$PERL ./Implement.PL tb`
if test -n "$PI_TBOPERATOR" ; then
	AC_MSG_RESULT(no $PI_TBOPERATOR)
	PI_IMPLEMENT_TB=NO
	AC_SUBST(PI_IMPLEMENT_TB)
else
	AC_MSG_RESULT(yes)
	PI_IMPLEMENT_TB=YES
fi

dnl # Checks for header files.

dnl # Checks for typedefs, structures, and compiler characteristics.

dnl # Checks for library functions.
AC_CONFIG_FILES([Makefile
                 src/Makefile
                 src/bin/Makefile
                 src/cgi/Makefile
                 src/etc/Makefile
                 src/lib/Kanadzuchi/API/Makefile
                 src/lib/Kanadzuchi/Archive/Makefile
                 src/lib/Kanadzuchi/BdDR/BounceLogs/Makefile
                 src/lib/Kanadzuchi/BdDR/Makefile
                 src/lib/Kanadzuchi/Config/Makefile
                 src/lib/Kanadzuchi/Mail/Bounced/Makefile
                 src/lib/Kanadzuchi/Mail/Bounced/JP/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/DE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/EG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/JP/Makefile
                 src/lib/Kanadzuchi/Mail/Group/RU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/UK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/US/Makefile
                 src/lib/Kanadzuchi/Mail/Group/Makefile
                 src/lib/Kanadzuchi/Mail/Makefile
                 src/lib/Kanadzuchi/Mail/Stored/Makefile
                 src/lib/Kanadzuchi/Mail/Why/Makefile
                 src/lib/Kanadzuchi/Makefile
                 src/lib/Kanadzuchi/Mbox/Makefile
                 src/lib/Kanadzuchi/MIME/Makefile
                 src/lib/Kanadzuchi/UI/Makefile
                 src/lib/Kanadzuchi/UI/Web/Makefile
                 src/lib/Makefile
                 src/libexec/Makefile
                 src/sql/Makefile
                 template/Makefile
                 template/standard/Makefile
                 template/standard/element/Makefile
                 template/standard/help/Makefile
                 template/standard/javascript/Makefile
                 template/standard/page/Makefile
                 template/standard/stylesheet/Makefile])
AC_OUTPUT
