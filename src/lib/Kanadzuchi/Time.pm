# $Id: Time.pm,v 1.9 2010/11/13 19:23:03 ak Exp $
# -Id: Time.pm,v 1.1 2009/08/29 09:13:56 ak Exp -
# -Id: Time.pm,v 1.5 2009/07/16 09:05:33 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                            
 ######  ##                 
   ##        ##  ##  ####   
   ##   ###  ###### ##  ##  
   ##    ##  ###### ######  
   ##    ##  ##  ## ##      
   ##   #### ##  ##  ####   
package Kanadzuchi::Time;
use strict;
use warnings;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||o |||n |||s |||t |||a |||n |||t ||
# ||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub BASE_D()    { 86400 }		# 1 day = 86400 sec
sub BASE_Y()    { 365.2425 }		# 1 year = 365.2425 days
sub BASE_L()    { 29.53059 }		# 1 lunar month = 29.53059 days
sub CONST_P()   { 4 * atan2(1,1) }	# PI, 3.1415926535
sub CONST_E()   { exp(1) }		# e, Napier's constant
sub TZ_OFFSET() { 54000 }		# Max time zone offset, 54000 seconds

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $UnitOfTime = {
	'o' => ( BASE_D * BASE_Y * 4 ),	# Olympiad, 4 years
	'y' => ( BASE_D * BASE_Y ),	# Year, Gregorian Calendar
	'q' => ( BASE_D * BASE_Y / 4 ),	# Quarter, year/4
	'l' => ( BASE_D * BASE_L ),	# Lunar month
	'f' => ( BASE_D * 14 ),		# Fortnight, 2 weeks
	'w' => ( BASE_D * 7 ),		# Week, 604800 seconds
	'd' => BASE_D,			# Day
	'h' => 3600,			# Hour
	'b' => 86.4,			# Beat, Swatch internet time: 1000b = 1d
	'm' => 60,			# Minute,
	's' => 1,			# Second
};

my $MathematicalConstant = {
	'e' => CONST_E,
	'p' => CONST_P,
	'g' => CONST_E ** CONST_P,
};

my $MonthName = {
	'Full' => [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 
			'August', 'September', 'October', 'November', 'December' ],
	'Abbr' => [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
			'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ],
};

my $DayOfWeek = {
	'Full' => [ 'Sunday', 'Monday', 'Tuesday', 
			'Wednesday', 'Thursday', 'Friday', 'Saturday' ],
	'Abbr' => [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', ],
};

my $HourName = {
	'Full' => [ 'Midnight',1,2,3,4,5,'Morning',7,8,9,10,11,'Noon',
			13,14,15,16,17,'Evening',19,20,21,22,23 ],
	'Abbr' => [ 0..23 ],
};

my $TimeZoneAbbr = {
	# http://en.wikipedia.org/wiki/List_of_time_zone_abbreviations
	#'ACDT'	=> '+1030',	# Australian Central Daylight Time	UTC+10:30
	#'ACST'	=> '+0930',	# Australian Central Standard Time	UTC+09:30
	#'ACT'	=> '+0800',	# ASEAN Common Time			UTC+08:00
	'ADT'	=> '-0300',	# Atlantic Daylight Time		UTC-03:00
	#'AEDT'	=> '+1100',	# Australian Eastern Daylight Time	UTC+11:00
	#'AEST'	=> '+1000',	# Australian Eastern Standard Time	UTC+10:00
	#'AFT'	=> '+0430',	# Afghanistan Time			UTC+04:30
	'AKDT'	=> '-0800',	# Alaska Daylight Time			UTC-08:00
	'AKST'	=> '-0900',	# Alaska Standard Time			UTC-09:00
	#'AMST'	=> '+0500',	# Armenia Summer Time			UTC+05:00
	#'AMT'	=> '+0400',	# Armenia Time				UTC+04:00
	#'ART'	=> '-0300',	# Argentina Time			UTC+03:00
	#'AST'	=> '+0300',	# Arab Standard Time (Kuwait, Riyadh)	UTC+03:00
	#'AST'	=> '+0400',	# Arabian Standard Time (Abu Dhabi, Muscat) UTC+04:00
	#'AST'	=> '+0300',	# Arabic Standard Time (Baghdad)	UTC+03:00
	'AST'	=> '-0400',	# Atlantic Standard Time		UTC-04:00
	#'AWDT'	=> '+0900',	# Australian Western Daylight Time	UTC+09:00
	#'AWST'	=> '+0800',	# Australian Western Standard Time	UTC+08:00
	#'AZOST'=> '-0100',	# Azores Standard Time			UTC-01:00
	#'AZT'	=> '+0400',	# Azerbaijan Time			UTC+04:00
	#'BDT'	=> '+0800',	# Brunei Time				UTC+08:00
	#'BIOT'	=> '+0600',	# British Indian Ocean Time		UTC+06:00
	#'BIT'	=> '-1200',	# Baker Island Time			UTC-12:00
	#'BOT'	=> '-0400',	# Bolivia Time				UTC-04:00
	#'BRT'	=> '-0300',	# Brasilia Time				UTC-03:00
	#'BST'	=> '+0600',	# Bangladesh Standard Time		UTC+06:00
	#'BST'	=> '+0100',	# British Summer Time (British Standard Time from Feb 1968 to Oct 1971)	UTC+01:00
	#'BTT'	=> '+0600',	# Bhutan Time				UTC+06:00
	#'CAT'	=> '+0200',	# Central Africa Time			UTC+02:00
	#'CCT'	=> '+0630',	# Cocos Islands Time			UTC+06:30
	'CDT'	=> '-0500',	# Central Daylight Time (North America)	UTC-05:00
	#'CEDT'	=> '+0200',	# Central European Daylight Time	UTC+02:00
	#'CEST'	=> '+0200',	# Central European Summer Time		UTC+02:00
	#'CET'	=> '+0100',	# Central European Time			UTC+01:00
	#'CHAST'=> '+1245',	# Chatham Standard Time			UTC+12:45
	#'CIST'	=> '-0800',	# Clipperton Island Standard Time	UTC-08:00
	#'CKT'	=> '-1000',	# Cook Island Time			UTC-10:00
	#'CLST'	=> '-0300',	# Chile Summer Time			UTC-03:00
	#'CLT'	=> '-0400',	# Chile Standard Time			UTC-04:00
	#'COST'	=> '-0400',	# Colombia Summer Time			UTC-04:00
	#'COT'	=> '-0500',	# Colombia Time				UTC-05:00
	'CST'	=> '-0600',	# Central Standard Time (North America)	UTC-06:00
	#'CST'	=> '+0800',	# China Standard Time			UTC+08:00
	#'CVT'	=> '-0100',	# Cape Verde Time			UTC-01:00
	#'CXT'	=> '+0700',	# Christmas Island Time			UTC+07:00
	#'ChST'	=> '+1000',	# Chamorro Standard Time		UTC+10:00
	# 'DST'	=> ''		# Daylight saving time			Depending
	#'DFT'	=> '+0100',	# AIX specific equivalent of Central European Time	UTC+01:00
	#'EAST'	=> '-0600',	# Easter Island Standard Time		UTC-06:00
	#'EAT'	=> '+0300',	# East Africa Time			UTC+03:00
	#'ECT'	=> '-0400',	# Eastern Caribbean Time (does not recognise DST)	UTC-04:00
	#'ECT'	=> '-0500',	# Ecuador Time				UTC-05:00
	'EDT'	=> '-0400',	# Eastern Daylight Time (North America)	UTC-04:00
	#'EEDT'	=> '+0300',	# Eastern European Daylight Time	UTC+03:00
	#'EEST'	=> '+0300',	# Eastern European Summer Time		UTC+03:00
	#'EET'	=> '+0200',	# Eastern European Time			UTC+02:00
	'EST'	=> '+0500',	# Eastern Standard Time (North America)	UTC-05:00
	#'FJT'	=> '+1200',	# Fiji Time				UTC+12:00
	#'FKST'	=> '-0400',	# Falkland Islands Standard Time	UTC-04:00
	#'GALT'	=> '-0600',	# Galapagos Time			UTC-06:00
	#'GET'	=> '+0400',	# Georgia Standard Time			UTC+04:00
	#'GFT'	=> '-0300',	# French Guiana Time			UTC-03:00
	#'GILT'	=> '+1200',	# Gilbert Island Time			UTC+12:00
	#'GIT'	=> '-0900',	# Gambier Island Time			UTC-09:00
	'GMT'	=> '+0000',	# Greenwich Mean Time			UTC
	#'GST'	=> '-0200',	# South Georgia and the South Sandwich Islands	UTC-02:00
	#'GYT'	=> '-0400',	# Guyana Time				UTC-04:00
	'HADT'	=> '-0900',	# Hawaii-Aleutian Daylight Time		UTC-09:00
	'HAST'	=> '-1000',	# Hawaii-Aleutian Standard Time		UTC-10:00
	#'HKT'	=> '+0800',	# Hong Kong Time			UTC+08:00
	#'HMT'	=> '+0500',	# Heard and McDonald Islands Time	UTC+05:00
	'HST'	=> '-1000',	# Hawaii Standard Time			UTC-10:00
	#'IRKT'	=> '+0800',	# Irkutsk Time				UTC+08:00
	#'IRST'	=> '+0330',	# Iran Standard Time			UTC+03:30
	#'IST'	=> '+0530',	# Indian Standard Time			UTC+05:30
	#'IST'	=> '+0100',	# Irish Summer Time			UTC+01:00
	#'IST'	=> '+0200',	# Israel Standard Time			UTC+02:00
	'JST'	=> '+0900',	# Japan Standard Time			UTC+09:00
	#'KRAT'	=> '+0700',	# Krasnoyarsk Time			UTC+07:00
	#'KST'	=> '+0900',	# Korea Standard Time			UTC+09:00
	#'LHST'	=> '+1030',	# Lord Howe Standard Time		UTC+10:30
	#'LINT'	=> '+1400',	# Line Islands Time			UTC+14:00
	#'MAGT'	=> '+1100',	# Magadan Time				UTC+11:00
	'MDT'	=> '-0600',	# Mountain Daylight Time(North America)	UTC-06:00
	#'MIT'	=> '-0930',	# Marquesas Islands Time		UTC-09:30
	#'MSD'	=> '+0400',	# Moscow Summer Time			UTC+04:00
	#'MSK'	=> '+0300',	# Moscow Standard Time			UTC+03:00
	#'MST'	=> '+0800',	# Malaysian Standard Time		UTC+08:00
	'MST'	=> '-0700',	# Mountain Standard Time(North America)	UTC-07:00
	#'MST'	=> '+0630',	# Myanmar Standard Time			UTC+06:30
	#'MUT'	=> '+0400',	# Mauritius Time			UTC+04:00
	#'NDT'	=> '-0230',	# Newfoundland Daylight Time		UTC-02:30
	#'NFT'	=> '+1130',	# Norfolk Time[1]			UTC+11:30
	#'NPT'	=> '+0545',	# Nepal Time				UTC+05:45
	#'NST'	=> '-0330',	# Newfoundland Standard Time		UTC-03:30
	#'NT'	=> '-0330',	# Newfoundland Time			UTC-03:30
	#'OMST'	=> '+0600',	# Omsk Time				UTC+06:00
	'PDT'	=> '-0700',	# Pacific Daylight Time(North America)	UTC-07:00
	#'PETT'	=> '+1200',	# Kamchatka Time			UTC+12:00
	#'PHOT'	=> '+1300',	# Phoenix Island Time			UTC+13:00
	#'PKT'	=> '+0500',	# Pakistan Standard Time		UTC+05:00
	'PST'	=> '-0800',	# Pacific Standard Time (North America)	UTC-08:00
	#'PST'	=> '+0800',	# Philippine Standard Time		UTC+08:00
	#'RET'	=> '+0400',	# R辿union Time				UTC+04:00
	#'SAMT'	=> '+0400',	# Samara Time				UTC+04:00
	#'SAST'	=> '+0200',	# South African Standard Time		UTC+02:00
	#'SBT'	=> '+1100',	# Solomon Islands Time			UTC+11:00
	#'SCT'	=> '+0400',	# Seychelles Time			UTC+04:00
	#'SLT'	=> '+0530',	# Sri Lanka Time			UTC+05:30
	#'SST'	=> '-1100',	# Samoa Standard Time			UTC-11:00
	#'SST'	=> '+0800',	# Singapore Standard Time		UTC+08:00
	#'TAHT'	=> '-1000',	# Tahiti Time				UTC-10:00
	#'THA'	=> '+0700',	# Thailand Standard Time		UTC+07:00
	'UT'	=> '-0000',	# Coordinated Universal Time		UTC
	'UTC'	=> '-0000',	# Coordinated Universal Time		UTC
	#'UYST'	=> '-0200',	# Uruguay Summer Time			UTC-02:00
	#'UYT'	=> '-0300',	# Uruguay Standard Time			UTC-03:00
	#'VET'	=> '-0430',	# Venezuelan Standard Time		UTC-04:30
	#'VLAT'	=> '+1000',	# Vladivostok Time			UTC+10:00
	#'WAT'	=> '+0100',	# West Africa Time			UTC+01:00
	#'WEDT'	=> '+0100',	# Western European Daylight Time	UTC+01:00
	#'WEST'	=> '+0100',	# Western European Summer Time		UTC+01:00
	#'WET'	=> '-0000',	# Western European Time			UTC
	#'YAKT'	=> '+0900',	# Yakutsk Time				UTC+09:00
	#'YEKT'	=> '+0500',	# Yekaterinburg Time			UTC+05:00
};
#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub to_second
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|o|_|s|e|c|o|n|d|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Convert to second
	# @Param <str>	(String) Digit and a unit of time
	# @Return	(Integer) n = seconds
	#		(Integer) 0 = 0 or invalid unit of time
	my $class = shift();
	my $digit = shift() || return(0);
	my $t_sec = 0;
	my @unitc = keys %$UnitOfTime;
	my @mathc = keys %$MathematicalConstant;

	if( $digit =~ m{\A(\d+|\d+[.]\d+)([@unitc])?\z}o )
	{
		$t_sec = $1 * ( defined($2) ? $UnitOfTime->{$2} : $UnitOfTime->{'d'} );
	}
	elsif( $digit =~ m{\A(\d+|\d+[.]\d+)?([@mathc])([@unitc])?\z}o )
	{
		my $_d = defined($1) ? $1 : 1;
		my $_m = $MathematicalConstant->{$2} || 0;
		$t_sec = ( $_d * $_m ) * ( defined($3) ? $UnitOfTime->{$3} : $UnitOfTime->{'d'} );
	}
	else
	{
		$t_sec = 0;
	}

	return $t_sec;
}

sub monthname
{
	# +-+-+-+-+-+-+-+-+-+
	# |m|o|n|t|h|n|a|m|e|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Month name list
	# @Param <flg>	(Integer) require full name
	# @Return	(Ref|Array) Month name
	#
	my $class = shift();
	my $fname = shift() || 0;
	my $keyis = $fname ? 'Full' : 'Abbr';
	return @{ $MonthName->{$keyis} } if wantarray();
	return $MonthName->{ $keyis };
}

sub dayofweek
{
	# +-+-+-+-+-+-+-+-+-+
	# |d|a|y|o|f|w|e|e|k|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	List of day of week
	# @Param <flg>	(Integer) require full name
	# @Return	(Ref|Array) list of day of week
	#
	my $class = shift();
	my $fname = shift() || 0;
	my $keyis = $fname ? 'Full' : 'Abbr';
	return @{ $DayOfWeek->{$keyis} } if wantarray();
	return $DayOfWeek->{ $keyis };
}

sub hourname
{
	# +-+-+-+-+-+-+-+-+
	# |h|o|u|r|n|a|m|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Hour name list
	# @Param <flg>	(Integer) require full name
	# @Return	(Ref|Array) Month name
	#
	my $class = shift();
	my $fname = shift() || 1;
	my $keyis = $fname ? 'Full' : 'Abbr';
	return @{ $HourName->{$keyis} } if wantarray();
	return $HourName->{ $keyis };
}

sub o2d
{
	# +-+-+-+
	# |o|2|d|
	# +-+-+-+
	#
	# @Description	Convert from date offset to date string
	# @Param <int>	(Integer) Offset
	# @Param <del>	(Character) Delimiter
	# @Return	(String) String
	#
	my $class = shift();
	my $dateo = shift() || 0;
	my $delim = shift();
	my $timep = new Time::Piece;
	my $epoch = 0;

	$delim = '-' unless defined $delim;
	return $timep->ymd($delim) unless( $dateo =~ m{\A[-]?\d+\z} );

	# See http://en.wikipedia.org/wiki/Year_2038_problem
	$epoch = $timep->epoch() - $dateo * 86400;
	$epoch = 0 if( $epoch < 0 );
	$epoch = 2 ** 31 - 1 if( $epoch >= 2 ** 31 );
	return Time::Piece->new($epoch)->ymd($delim);
}

sub canonify
{
	# +-+-+-+-+-+-+-+-+
	# |c|a|n|o|n|i|f|y|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Canonify date string; strptime() wrapper
	# @Param <str>	(String) Date string
	# @Param <flag>	(Integer) To return Time::Piece object or not
	# @Param <flag>	(Integer) To quiet or not to quiet
	# @Return	(String|Time::Piece) Canonified date string or Time::Piece object
	# @See		http://en.wikipedia.org/wiki/ISO_8601
	# @See		http://www.ietf.org/rfc/rfc3339.txt
	my $class = shift();
	my $datev = shift() || return q();
	my $toobj = shift() || 0;
	my $quiet = shift() || 0;
	my $piece = { 
		'Y' => undef(),		# (Integer) Year
		'M' => undef(),		# (String) Month Abbr.
		'd' => undef(),		# (Integer) Day
		'a' => undef(),		# (String) Day of week, Abbr.
		'T' => undef(),		# (String) Time
		'z' => undef(),		# (Integer) Timezone offset
	};

	$datev =~ s{[,](\d+)}{, $1};	# Thu,13 -> Thu, 13

	my $timetokens = [split( q{ }, $datev )];
	my $canonified = q();		# (String) Canonified Date/Time string
	my $timepiecex = undef();	# (Time::Piece)

	while( my $p = shift @$timetokens )
	{
		if( $p =~ m{\A[A-Z][a-z]{2}[,]?\z} )
		{
			# Day of week or Day of week; Thu, Apr, ...
			chop($p) if( length($p) == 4 );	# Thu, -> Thu

			if( grep { $p eq $_ } @{ $DayOfWeek->{'Abbr'} } )
			{
				# Day of week; Mon, Thu, Sun,...
				$piece->{'a'} = $p;
			}
			elsif( grep { $p eq $_ } @{ $MonthName->{'Abbr'} } )
			{
				# Month name abbr.; Apr, May, ...
				$piece->{'M'} = $p;
			}
		}
		elsif( $p =~ m{\A\d{1,4}\z} )
		{
			# Year or Day; 2005, 31, 04,  1, ...
			( $p > 31 ) ? ( $piece->{'Y'} = $p ) : ( $piece->{'d'} ||= $p );
		}
		elsif( $p =~ m{\A([0-2]\d):([0-5]\d):([0-5]\d)\z} )
		{
			# Time; 12:34:56, 03:14:15, ...
			$piece->{'T'} = $1.':'.$2.':'.$3 if( $1 < 24 && $2 < 60 && $3 < 60 );
		}
		else
		{
			if( $p =~ m{\A[-+][01]\d{3}\z} )
			{
				# Timezone offset; +0000, +0900, -1000, ...
				$piece->{'z'} ||= $p;
			}
			elsif( $p =~ m{\A[(]?[A-Z]{2,5}[)]?\z} )
			{
				# Timezone abbreviation; JST, GMT, UTC, ...
				$piece->{'z'} ||= __PACKAGE__->abbr2tz($p) || '+0000';
			}
			else
			{
				if( $p =~ m{\A(\d{4})[-/](\d{1,2})[-/](\d{1,2})\z} )
				{
					# Mail.app(MacOS X)'s faked Bounce, Arrival-Date: 2010-06-18 17:17:52 +0900
					$piece->{'Y'} = int($1);
					$piece->{'M'} = $MonthName->{'Abbr'}->[ int($2) - 1 ];
					$piece->{'d'} = int($3);
				}
				elsif( $p =~ m{\A(\d{4})[-/](\d{1,2})[-/](\d{1,2})T([0-2]\d):([0-5]\d):([0-5]\d)\z} )
				{
					# ISO 8601; 2000-04-29T01:23:45
					$piece->{'Y'} = int($1);
					$piece->{'M'} = $MonthName->{'Abbr'}->[ int($2) - 1 ];
					$piece->{'d'} = int($3) if( $3 < 32 );
					$piece->{'T'} = $4.':'.$5.':'.$6 if( $4 < 24 && $5 < 60 && $6 < 60 );
				}
			}
		}

	} # End of while()

	$piece->{'a'} ||= 'Thu';							# There is no day of week
	$piece->{'Y'}  += 1900 if( defined $piece->{'Y'} && $piece->{'Y'} < 200 );	# 99 -> 1999, 102 -> 2002
	$piece->{'z'} ||= __PACKAGE__->second2tz(Time::Piece->new->tzoffset());

	# Check each piece
	if( grep { ! defined $_ } values %$piece )
	{
		warn( ' ***warning: Strange date format ['.$datev.']' ) unless $quiet;
		return $toobj ? undef() : q();
	}

	if( $piece->{'Y'} < 1902 || $piece->{'Y'} > 2037 )
	{
		# -(2^31) ~ (2^31)
		return $toobj ? undef() : q();
	}

	# Build date string
	#   Thu, 29 Apr 2004 10:01:11 +0900
	$canonified = sprintf( "%s, %d %s %d %s %s", $piece->{'a'}, $piece->{'d'}, 
				$piece->{'M'}, $piece->{'Y'}, $piece->{'T'}, $piece->{'z'} );

	return $canonified unless( $toobj );

	eval { $timepiecex = Time::Piece->strptime( $canonified, q{%a, %d %b %Y %T %z} ); };
	return $timepiecex unless $@;

	warn ' ***warning: '.$@ unless $quiet;
	return undef();
}

sub abbr2tz
{
	# +-+-+-+-+-+-+-+
	# |a|b|b|r|2|t|z|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Abbreviation -> Tiemzone
	# @Param <str>	(String) Abbr. e.g.) JST, GMT, PDT
	# @Return	(String) +0900, +0000, -0600
	#		(undef) invalid format
	my $class = shift();
	my $tabbr = shift() || return undef();
	return $TimeZoneAbbr->{ $tabbr };
}

sub tz2second
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|z|2|s|e|c|o|n|d|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Convert to second
	# @Param <str>	(String) Timezone string e.g) +0900
	# @Return	(Integer) n  = seconds
	#		(undef) invalid format
	my $class = shift();
	my $tzstr = shift() || return undef();
	my $digit = {};
	my $tzsec = 0;

	if( $tzstr =~ m{\A([-+])(\d)(\d)(\d{2})\z} )
	{
		$digit = {
			'operator' => $1,
			'hour-10'  => $2,
			'hour-01'  => $3,
			'minutes'  => $4, };
		$tzsec += ( $digit->{'hour-10'} * 10 + $digit->{'hour-01'} ) * 3600;
		$tzsec += ( $digit->{'minutes'} * 60 );
		$tzsec *= -1 if( $digit->{'operator'} eq q{-} );
		return undef() if( abs($tzsec) > TZ_OFFSET );
	}
	elsif( $tzstr =~ m{\A[A-Za-z]+\z} )
	{
		return $class->tz2second( $TimeZoneAbbr->{ $tzstr } );
	}
	else
	{
		return undef();
	}
	
	return $tzsec;
}

sub second2tz
{
	# +-+-+-+-+-+-+-+-+-+
	# |s|e|c|o|n|d|2|t|z|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Convert to Timezone string
	# @Param <int>	(Integer) Second
	# @Return	(String) Timezone offset string
	my $class = shift();
	my $tzsec = shift() || 0;
	my $digit = { 'operator' => q(+) };
	my $tzstr = q();

	return q(+0000) unless($tzsec);
	return q() if( ref($tzsec) && ref($tzsec) ne q|Time::Seconds| );
	return q() if( abs($tzsec) > TZ_OFFSET );	# UTC+14 + 1(DST?)
	$digit->{'operator'} = q{-} if( $tzsec < 0 );

	$digit->{'hours'} = int( abs($tzsec) / 3600 );
	$digit->{'minutes'} = int( ( abs($tzsec) % 3600 ) / 60 );
	$tzstr = sprintf( "%s%02d%02d", $digit->{'operator'}, $digit->{'hours'}, $digit->{'minutes'} );

	return $tzstr;
}

1;
__END__
