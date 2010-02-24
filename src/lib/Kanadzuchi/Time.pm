# $Id: Time.pm,v 1.3 2010/02/21 20:24:12 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                            
 ######  ##                 
   ##        ##  ##  ####   
   ##   ###  ###### ##  ##  
   ##    ##  ###### ######  
   ##    ##  ##  ## ##      
   ##   #### ##  ##  ####   
package Kanadzuchi::Time;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||o |||n |||s |||t |||a |||n |||t ||
# ||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||F |||u |||n |||c |||t |||i |||o |||n |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub BASE_D() { 86400 }		# 1 day = 86400 sec
sub BASE_Y() { 365.2425 }	# 1 year = 365.2425 days
sub BASE_L() { 29.53059 }	# 1 lunar month = 29.53059 days
sub CONST_P(){ 4 * atan2(1,1) }	# PI, 3.1415926535
sub CONST_E(){ exp(1) }		# e, Napier's constant
sub TZ_OFFSET(){ 54000 }	# Max time zone offset, 54000 seconds

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
	my @unitc = keys(%$UnitOfTime);
	my @mathc = keys(%$MathematicalConstant);

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

	return($t_sec);
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
	my $tzstr = shift() || return(undef());
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
		return( undef() ) if( abs($tzsec) > TZ_OFFSET );
	}
	else
	{
		return( undef() );
	}
	
	return($tzsec);
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
	my $tzstr = q{};

	return(q{+0000}) unless($tzsec);
	return(q{}) if( ref($tzsec) );			# Some object
	return(q{}) if( abs($tzsec) > TZ_OFFSET );	# UTC+14 + 1(DST?)
	$digit->{'operator'} = q{-} if( $tzsec < 0 );

	$digit->{'hours'} = int( abs($tzsec) / 3600 );
	$digit->{'minutes'} = int( ( abs($tzsec) % 3600 ) / 60 );
	$tzstr = sprintf( "%s%02d%02d", $digit->{'operator'}, $digit->{'hours'}, $digit->{'minutes'} );

	return($tzstr);
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
	return( @{$MonthName->{$keyis}} ) if( wantarray() );
	return( $MonthName->{$keyis} );
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
	return( @{$DayOfWeek->{$keyis}} ) if( wantarray() );
	return( $DayOfWeek->{$keyis} );
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
	return( @{$HourName->{$keyis}} ) if( wantarray() );
	return( $HourName->{$keyis} );
}

1;
__END__
