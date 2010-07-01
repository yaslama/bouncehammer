# $Id: WebMail.pm,v 1.4 2010/06/28 13:19:02 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CA::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::CA::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Canada
sub nominisexemplaria
{
	my $class = shift();
	return {
		# Hushmail http://www.hushmail.com/
		'hush' => [
			qr{\Ahushmail[.](?:com|me)\z},
			qr{\Ahush[.](?:com|ai)\z},
			qr{\Amac[.]hush[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'hush'		=> 'Generic',
	};
}

1;
__END__
