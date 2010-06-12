# $Id: WebMail.pm,v 1.4 2010/06/12 13:20:29 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::JP::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains(Japan)
my $Domains = {
	'goo' => [
		# goo mail, http://mail.goo.ne.jp/goomail/index.ghtml
		qr{(?>\Amail[.]goo[.]ne[.]jp\z)},
		qr{(?>\Agoo[.]jp\z)},
	],
	'nttdocomo' => [
		# DoCoMo web mail powered by goo; http://dwmail.jp/
		qr{(?>\Adwmail[.]jp\z)},
	],
	'aubykddi' => [
		# KDDI auone(Gmail); http://auone.jp/
		qr{(?>\Aauone[.]jp\z)},
	],
	'livedoor' => [
		# livedoor mail(Gmail) http://mail.livedoor.com/
		qr{(?>\Alivedoor[.]com\z)},
	],
};

my $Classes = {
	'goo'		=> 'Generic',
	'nttdocomo'	=> 'Generic',
	'aubykddi'	=> 'Generic',
	'livedoor'	=> 'Generic',
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

	foreach my $d ( keys(%$Domains) )
	{
		next() unless( grep { $dpart =~ $_ } @{ $Domains->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::|.$Classes->{$d};
		$mdata->{'group'} = 'webmail';
		$mdata->{'provider'} = $d;
		last();
	}

	return($mdata);
}

1;
__END__
