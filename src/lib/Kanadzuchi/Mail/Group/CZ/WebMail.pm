# $Id: WebMail.pm,v 1.1 2010/06/14 11:23:17 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CZ::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::CZ::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Czech Republic/Czechia
my $Domains = {
	'seznam' => [
		qr{\A(?:seznam|email|post|spoluzaci|stream|firmy)[.]cz\z},
	],
};

my $Classes = {
	'seznam'	=> 'Generic',
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
	
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };

	return($mdata) unless( $dpart =~ m{[.]cz\z} );

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
