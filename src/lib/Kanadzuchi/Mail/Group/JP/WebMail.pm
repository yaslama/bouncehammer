# $Id: WebMail.pm,v 1.7 2010/06/16 08:15:34 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::JP::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Japan
sub nominisexemplaria
{
	my $class = shift();
	return {
		'aubykddi' => [
			# KDDI auone(Gmail); http://auone.jp/
			qr{\Aauone[.]jp\z},
		],
		'goo' => [
			# goo mail, http://mail.goo.ne.jp/goomail/index.ghtml
			qr{\Amail[.]goo[.]ne[.]jp\z},
			qr{\Agoo[.]jp\z},
		],
		'livedoor' => [
			# livedoor mail(Gmail) http://mail.livedoor.com/
			qr{\Alivedoor[.]com\z},
		],
		'nttdocomo' => [
			# DoCoMo web mail powered by goo; http://dwmail.jp/
			qr{\Adwmail[.]jp\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'aubykddi'	=> 'Generic',
		'goo'		=> 'Generic',
		'livedoor'	=> 'Generic',
		'nttdocomo'	=> 'Generic',
	};
}

1;
__END__
