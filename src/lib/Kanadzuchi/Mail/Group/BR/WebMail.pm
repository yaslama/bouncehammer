# $Id: WebMail.pm,v 1.3.2.1 2011/02/25 02:26:13 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::BR::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::BR::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Brazil
sub communisexemplar { return qr{[.]br\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# BOL - O e-mail gratis do Brasil
		# http://www.bol.uol.com.br/
		'bol' => [
			qr{\Abol[.]com[.]br\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'bol'		=> 'Generic',
	};
}

1;
__END__
