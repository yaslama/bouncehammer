dnl #                                               -*- Autoconf -*-
dnl # Process this file with autoconf to produce a configure script.
dnl # $Id: configure.ac,v 1.8 2010/03/01 00:09:50 ak Exp $
dnl # Copyright (C) 2009,2010 Cubicroot Co. Ltd.
AC_PREREQ(2.61)
AC_INIT([BounceHammer], [2.0.0], [bugs@bouncehammer.jp])
AM_INIT_AUTOMAKE([foreign])
AC_PREFIX_DEFAULT(/usr/local/bouncehammer)
AC_CANONICAL_HOST

AC_SUBST(TARGET_OSTYPE)
AC_SUBST(TARGET_HOSTNAME)
AC_SUBST(TARGET_DOMAINNAME)

dnl # Checks for programs.
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PATH_PROG(SHELL, sh, :, /bin:/usr/bin:/usr/local/bin)

AC_PROG_LN_S
AC_PATH_PROG(CAT, cat, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(XARGS, xargs, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(CHMOD, chmod, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(CHOWN, chown, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROG(TOUCH, touch, :, /bin:/usr/bin:/usr/local/bin)
AC_PATH_PROGS(SQLITE, sqlite sqlite3, :, /bin:/usr/bin:/usr/local/bin)

AC_PROG_AWK
if test "x$AWK" = x; then
	AC_MSG_ERROR([*** Cannot find awk])
fi

AC_PATH_PROG(FIND, find, :, /bin:/usr/bin:/usr/local/bin)
if test "x$FIND" = x; then
	AC_MSG_ERROR([*** Cannot find find program])
fi

AC_PATH_PROG(SED, sed, :, /bin:/usr/bin:/usr/local/bin)
if test "x$SED" = x; then
	AC_MSG_ERROR([*** Cannot find sed program])
fi

AC_PATH_PROGS(GREP, grep egrep, :, /bin:/usr/bin:/usr/local/bin)
if test "x$GREP" = x; then
	AC_MSG_ERROR([*** Cannot find grep program(grep, egrep)])
fi

AC_ARG_ENABLE(debug,
	AC_HELP_STRING( [--enable-debug], [Turn on debugging(>level 2) ] ),
	[enable_debug="$enableval"], [enable_debug="no"])
if test "x$enable_debug" = "xyes"; then
	ENABLE_DEBUGCODE=1
else
	ENABLE_DEBUGCODE=0
fi
AC_SUBST(ENABLE_DEBUGCODE)

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
for PM in `$PERL ./Modules.PL list`; do
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
fi


dnl # Checks for header files.

dnl # Checks for typedefs, structures, and compiler characteristics.

dnl # Checks for library functions.
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
