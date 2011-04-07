# $Id: WebMail.pm,v 1.1.2.1 2011/04/07 06:53:16 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::PT::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::PT::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in République Française/French Republic
# sub communisexemplar { return qr{[.]fr\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'sapo' => [
			# SAPO - Portugal Online!; http://www.sapo.pt/ 
			qr{\Asapo[.]pt\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'sapo'		=> 'Generic',
	};
}

1;
__END__
