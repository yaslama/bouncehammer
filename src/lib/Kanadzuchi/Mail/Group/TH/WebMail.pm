# $Id: WebMail.pm,v 1.1.2.1 2011/03/24 05:40:59 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::TH::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::TH::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in The Kingdom of Thailand
# sub communisexemplar { return qr{[.]tw\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'thaimail' => [
			# ThaiMail; http://www.thaimail.com/
			qr{\Athaimail[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'thaimail'	=> 'Generic',
	};
}

1;
__END__
