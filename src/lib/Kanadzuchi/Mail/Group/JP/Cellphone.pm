# $Id: Cellphone.pm,v 1.4 2010/06/12 13:20:28 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::JP::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Domains = {
	'nttdocomo' => [ 
		qr{(?>\Adocomo[.]ne[.]jp\z)},
	],
	'aubykddi'  => [
		qr{(?>\Aezweb[.]ne[.]jp\z)},
		qr{(?>\A[0-9a-z]{2}[.]ezweb[.]ne[.]jp\z)},
		qr{(?>\A[0-9a-z][-0-9a-z]{0,8}[0-9a-z][.]biz[.]ezweb[.]ne[.]jp\z)},
	],
	'softbank'  => [
		qr{(?>\Asoftbank[.]ne[.]jp\z)},
		qr{(?>\A[dhtcrksnq][.]vodafone[.]ne[.]jp\z)},
		qr{(?>\Ajp-[dhtcrksnq][.]ne[.]jp\z)},
		qr{(?>\Adisney[.]ne[.]jp\z)},
	],
};

my $Classes = {
	'nttdocomo'	=> 'JP::NTTDoCoMo',
	'aubykddi'	=> 'JP::aubyKDDI',
	'softbank'	=> 'JP::SoftBank',
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };
	my $cpath = q();

	return($mdata) unless( $dpart =~ m{(?>[.]ne[.]jp\z)} );

	foreach my $d ( keys(%$Domains) )
	{
		next() unless( grep { $dpart =~ $_ } @{ $Domains->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced|.'::'.$Classes->{$d};
		$mdata->{'group'} = 'cellphone';
		$mdata->{'provider'} = $d;

		$cpath =  $mdata->{'class'};
		$cpath =~ y{:}{/}s;
		$cpath .= '.pm';

		require $cpath;
		last();
	}

	return($mdata);
}

1;
__END__
