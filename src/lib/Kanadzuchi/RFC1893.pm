# $Id: RFC1893.pm,v 1.5 2010/07/07 11:21:37 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                
 #####  ###### ####   ##   ####   ####  ######  
 ##  ## ##    ##  ## ###  ##  ## ##  ##     ##  
 ##  ## ####  ##    ####   ####  ##  ##   ###   
 #####  ##    ##      ##  ##  ##  #####     ##  
 ## ##  ##    ##  ##  ##  ##  ##     ## ##  ##  
 ##  ## ##     #### ###### ####   ####   ####   
package Kanadzuchi::RFC1893;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $StandardCode = {
	'temporary' => {
		'undefined'	=> 400,
		'hasmoved'	=> 416,
		'mailboxfull'	=> 422,
		'exceedlimit'	=> 423,
		'systemfull'	=> 431,
	},
	'permanent' => {
		'undefined'	=> 500,
		'userunknown'	=> 511,
		'hostunknown'	=> 512,
		'hasmoved'	=> 516,
		'filtered'	=> 520,
		'mailboxfull'	=> 522,
		'exceedlimit'	=> 523,
		'systemfull'	=> 531,
		'notaccept'	=> 532,
		'mesgtoobig'	=> 534,
		'mailererror'	=> 500,
		'securityerr'	=> 570,
	},
};

my $InternalCode = {
	'temporary' => {
		'undefined'	=> 480,
		'hasmoved'	=> 483,
		'mailboxfull'	=> 485,
		'exceedlimit'	=> 486,
		'systemfull'	=> 487,
		'suspended'	=> 488,
	},
	'permanent' => {
		'undefined'	=> 580,
		'userunknown'	=> 581,
		'hostunknown'	=> 582,
		'hasmoved'	=> 583,
		'filtered'	=> 584,
		'mailboxfull'	=> 585,
		'exceedlimit'	=> 586,
		'systemfull'	=> 587,
		'notaccept'	=> 591,
		'mesgtoobig'	=> 592,
		'mailererror'	=> 593,
		'securityerr'	=> 594,
		'onhold'	=> 597,
	},
};


# See http://www.ietf.org/rfc/rfc1893.txt
#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub int2code
{
	# +-+-+-+-+-+-+-+-+
	# |i|n|t|2|c|o|d|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Integer -> D.S.N. e.g.) 511 -> 5.1.1
	# @Param <str>	(Integer)
	# @Return	(String) D.S.N.
	#		(String) Empty = Invalid number
	my $class = shift();
	my $intsc = shift() || return q();
	my $dsnsc = q();

	$dsnsc = $1.q{.}.$2.q{.}.$3 if( $intsc =~ m{\A([245])(\d)(\d)\z} );
	return $dsnsc;
}

sub standardcode
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |s|t|a|n|d|a|r|d|c|o|d|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get D.S.N(defined in RFC1893, int) by the reason
	# @Param <str>	(String) Reason name
	# @Param <str>	(String) 'temporary' or 'permanent'
	# @Return	(Integer) D.S.N.
	#		(Integer) 0 = invalid reason name
	my $class = shift();
	my $cname = shift() || return(0);
	my $klass = shift() || q(permanent);
	my $icode = 0;

	if( $klass eq 'permanent' || $klass eq 'temporary' )
	{
		return( $StandardCode->{$klass}->{$cname} || 0 );
	}
	else
	{
		return(0);
	}
}

sub internalcode
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|n|t|e|r|n|a|l|c|o|d|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get D.S.N(defined in this file, int) by the reason
	# @Param <str>	(String) Reason name
	# @Param <str>	(String) 'temporary' or 'permanent'
	# @Return	(Integer) D.S.N.
	#		(Integer) 0 = invalid reason name
	my $class = shift();
	my $cname = shift() || return(0);
	my $klass = shift() || q(permanent);
	my $icode = 0;

	if( $klass eq 'permanent' || $klass eq 'temporary' )
	{
		return( $InternalCode->{$klass}->{$cname} || 0 );
	}
	else
	{
		return(0);
	}
}

1;
__END__
