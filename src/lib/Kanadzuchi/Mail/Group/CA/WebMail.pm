# $Id: WebMail.pm,v 1.4.2.1 2011/03/24 05:40:58 ak Exp $
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
		'hush' => [
			# Hushmail http://www.hushmail.com/
			qr{\Ahushmail[.](?:com|me)\z},
			qr{\Ahush[.](?:com|ai)\z},
			qr{\Amac[.]hush[.]com\z},
		],
		'zworg' => [
			# Zworg.com; https://zworg.com/
			qr{\Azworg[.]com\z},
			qr{\A(?:irk|mailcanada)[.]ca\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'hush'		=> 'Generic',
		'zworg'		=> 'Generic',
	};
}

1;
__END__
