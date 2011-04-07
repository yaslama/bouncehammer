# $Id: WebMail.pm,v 1.1.2.1 2011/04/07 06:53:17 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::SK::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::SK::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in lovakia/Slovak Republic
sub communisexemplar { return qr{[.]sk\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'centrum' => [
			# Centrum.sk; http://pobox.centrum.sk/
			qr{\Apobox[.]sk\z},
		],
		'sme' => [
			# SME.sk; http://post.sme.sk/
			qr{\Apost[.]sk\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'centrum'	=> 'Generic',
		'sme'		=> 'Generic',
	};
}

1;
__END__
