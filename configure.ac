dnl #                                               -*- Autoconf -*-
dnl # Process this file with autoconf to produce a configure script.
dnl # $Id: configure.ac,v 1.68.2.15 2011/08/23 21:48:42 ak Exp $
dnl # -Id: configure.ac,v 1.8 2009/12/01 10:35:23 ak Exp -
dnl # -Id: configure.ac,v 1.35 2009/08/27 05:09:04 ak Exp -
dnl # Copyright (C) 2009-2011 Cubicroot Co. Ltd.
AC_PREREQ(2.61)
AC_INIT([bounceHammer], [2.7.5], [bugs@bouncehammer.jp])
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

AC_ARG_WITH([perl-extlib],
	AC_HELP_STRING(
		[--with-perl-extlib=DIR],
		[DIR to perl external library directory which hold modules installed by cpanm -l]),
	[WITH_PERLEXTLIB=$withval],[WITH_PERLEXTLIB=none])
if test "x$WITH_PERLEXTLIB" = "xnone"; then
	PERL_EXTLIB='PERL_EXTLIB'
else
	PERL_EXTLIB=$WITH_PERLEXTLIB
fi
AC_SUBST(PERL_EXTLIB)

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

dnl # Inspired from configure script in MRTG source package
printf 'ordering CD from https://cubicroot.jp/order/bouncehammer-cdrom .'
sleep 1
printf '.'
sleep 1
printf '. '
printf 'just kidding ;-)'
echo

dnl # Checks for header files.

dnl # Checks for typedefs, structures, and compiler characteristics.

dnl # Checks for library functions.
AC_CONFIG_FILES([Makefile
                 src/Makefile
                 src/bin/Makefile
                 src/cgi/Makefile
                 src/etc/Makefile
                 src/lib/Kanadzuchi/API/Makefile
                 src/lib/Kanadzuchi/API/HTTP/Makefile
                 src/lib/Kanadzuchi/Archive/Makefile
                 src/lib/Kanadzuchi/BdDR/BounceLogs/Makefile
                 src/lib/Kanadzuchi/BdDR/Makefile
                 src/lib/Kanadzuchi/Config/Makefile
                 src/lib/Kanadzuchi/Mail/Bounced/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AL/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AT/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/AW/Makefile
                 src/lib/Kanadzuchi/Mail/Group/BE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/BG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/BM/Makefile
                 src/lib/Kanadzuchi/Mail/Group/BR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/BS/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CH/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CL/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CN/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CO/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/CZ/Makefile
                 src/lib/Kanadzuchi/Mail/Group/DE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/DK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/DO/Makefile
                 src/lib/Kanadzuchi/Mail/Group/EC/Makefile
                 src/lib/Kanadzuchi/Mail/Group/EG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/ES/Makefile
                 src/lib/Kanadzuchi/Mail/Group/FR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/GR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/GT/Makefile
                 src/lib/Kanadzuchi/Mail/Group/HK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/HN/Makefile
                 src/lib/Kanadzuchi/Mail/Group/HR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/HU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/ID/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IN/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IL/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IS/Makefile
                 src/lib/Kanadzuchi/Mail/Group/IT/Makefile
                 src/lib/Kanadzuchi/Mail/Group/JM/Makefile
                 src/lib/Kanadzuchi/Mail/Group/JP/Makefile
                 src/lib/Kanadzuchi/Mail/Group/KE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/KR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/LK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/LB/Makefile
                 src/lib/Kanadzuchi/Mail/Group/LU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/LV/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MD/Makefile
                 src/lib/Kanadzuchi/Mail/Group/ME/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MO/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MX/Makefile
                 src/lib/Kanadzuchi/Mail/Group/MY/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NI/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NL/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NP/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NO/Makefile
                 src/lib/Kanadzuchi/Mail/Group/NZ/Makefile
                 src/lib/Kanadzuchi/Mail/Group/OM/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PH/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PL/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PT/Makefile
                 src/lib/Kanadzuchi/Mail/Group/PY/Makefile
                 src/lib/Kanadzuchi/Mail/Group/RO/Makefile
                 src/lib/Kanadzuchi/Mail/Group/RS/Makefile
                 src/lib/Kanadzuchi/Mail/Group/RU/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/SV/Makefile
                 src/lib/Kanadzuchi/Mail/Group/TH/Makefile
                 src/lib/Kanadzuchi/Mail/Group/TR/Makefile
                 src/lib/Kanadzuchi/Mail/Group/TW/Makefile
                 src/lib/Kanadzuchi/Mail/Group/UA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/UG/Makefile
                 src/lib/Kanadzuchi/Mail/Group/UK/Makefile
                 src/lib/Kanadzuchi/Mail/Group/US/Makefile
                 src/lib/Kanadzuchi/Mail/Group/UY/Makefile
                 src/lib/Kanadzuchi/Mail/Group/VE/Makefile
                 src/lib/Kanadzuchi/Mail/Group/VN/Makefile
                 src/lib/Kanadzuchi/Mail/Group/ZA/Makefile
                 src/lib/Kanadzuchi/Mail/Group/Makefile
                 src/lib/Kanadzuchi/Mail/Makefile
                 src/lib/Kanadzuchi/Mail/Stored/Makefile
                 src/lib/Kanadzuchi/Mail/Why/Makefile
                 src/lib/Kanadzuchi/Makefile
                 src/lib/Kanadzuchi/MTA/Makefile
                 src/lib/Kanadzuchi/MTA/JP/Makefile
                 src/lib/Kanadzuchi/MTA/US/Makefile
                 src/lib/Kanadzuchi/MTA/User/Makefile
                 src/lib/Kanadzuchi/MIME/Makefile
                 src/lib/Kanadzuchi/Statistics/Makefile
                 src/lib/Kanadzuchi/Statistics/Stored/Makefile
                 src/lib/Kanadzuchi/UI/Makefile
                 src/lib/Kanadzuchi/UI/Web/Makefile
                 src/lib/Makefile
                 src/libexec/Makefile
                 src/sql/Makefile
                 template/Makefile
                 template/l10n/Makefile
                 template/l10n/en/Makefile
                 template/l10n/ja/Makefile
                 template/standard/Makefile
                 template/standard/element/Makefile
                 template/standard/javascript/Makefile
                 template/standard/page/Makefile
                 template/standard/stylesheet/Makefile])
AC_OUTPUT
