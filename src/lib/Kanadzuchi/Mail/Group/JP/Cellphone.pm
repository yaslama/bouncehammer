# $Id: Cellphone.pm,v 1.2 2010/02/21 20:36:58 ak Exp $
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

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::Mail::Group';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $domains = {
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

my $classes = {
	'nttdocomo' => 'NTTDoCoMo',
	'aubykddi'  => 'aubyKDDI',
	'softbank'  => 'SoftBank',
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub detectus
{
	# +-+-+-+-+-+-+-+-+
	# |d|e|t|e|c|t|u|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };

	return({}) unless( $dpart =~ m{(?>ne[.]jp\z)} );

	foreach my $d ( keys(%$domains) )
	{
		if( grep { $dpart =~ $_ } @{$domains->{$d}} )
		{
			$mdata->{'class'} = $Kanadzuchi::Mail::Group::ClassName.q{::}.$classes->{$d};
			$mdata->{'group'} = 'cellphone';
			$mdata->{'provider'} = $d;
			require $Kanadzuchi::Mail::Group::ClassPath.'/'.$classes->{$d}.'.pm';
			last();
		}
	}

	return($mdata);
}

sub is_cellphone
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|c|e|l|l|u|l|a|r|p|h|o|n|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether addr is cellphone or not
	# @Param <str>	(String) Domain part
	# @Return	(Integer) 1 = is cellularphone
	#		(Integer) 0 = is not cellularphone
	my $class = shift();
	my $dpart = shift() || return(0);

	foreach my $d ( keys(%$domains) )
	{
		return(1) if( grep { $dpart =~ $_ } @{$domains->{$d}} );
	}
	return(0);
}

1;
__END__
