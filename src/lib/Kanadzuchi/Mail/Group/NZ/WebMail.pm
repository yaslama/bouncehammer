# $Id: WebMail.pm,v 1.2.2.2 2011/03/24 05:40:59 ak Exp $
# Copyright (C) 2010-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::NZ::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::NZ::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in New Zealand
sub nominisexemplaria
{
	my $class = shift();
	return {
		'coolkiwi' => [
			# Cool Kiwi http://coolkiwi.com/
			qr{\Acoolkiwi[.](?:co[.]nz|com)\z},
		],
		'orcon' => [
			# http://www.orcon.net.nz/
			qr{\Aorcon[.]net[.]nz\z},
		],
		'vodafone' => [
			# https://webmail.vodafone.co.nz/vfwebmail/
			qr{\A(?:vodafone|es|ihug|pcconnect|quik|wave)[.]co[.]nz\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'coolkiwi'	=> 'Generic',
		'orcon'		=> 'Generic',
		'vodafone'	=> 'Generic',
	};
}

1;
__END__
