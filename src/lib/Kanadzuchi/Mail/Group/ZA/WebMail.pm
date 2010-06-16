# $Id: WebMail.pm,v 1.2 2010/06/16 08:15:56 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::ZA::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::ZA::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in South Africa/Zuid-Afrika
sub communisexemplar { return qr{[.]za\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# Experimental(Not tested)
		# http://www.webmail.co.za/
		'webmail.co.za' => [
			qr{\Awebmail[.]co[.]za\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'webmail.co.za'	=> 'Generic',
	};
}

1;
__END__
