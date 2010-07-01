# $Id: WebMail.pm,v 1.3 2010/06/28 13:19:04 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CN::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::CN::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in China
sub nominisexemplaria
{
	my $class = shift();
	return {
		# NetEase http://www.163.com/
		'netease' => [
			qr{\A(?:163|126|188)[.]com\z},
			qr{\Avip[.]163[.]com\z},
			qr{\Ayeah[.]net\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'netease'	=> 'Generic',
	};
}

1;
__END__
