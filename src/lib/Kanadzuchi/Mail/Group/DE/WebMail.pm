# $Id: WebMail.pm,v 1.4 2010/06/28 13:19:10 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::DE::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::DE::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Germany(Bundesrepublik Deutschland)
sub communisexemplar { return qr{[.]de\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# GMX - http://www.gmx.net/
		'gmx.de' => [
			qr{\Agmx[.]de\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'gmx.de'	=> 'Generic',
	};
}

1;
__END__
