# $Id: WebMail.pm,v 1.2.2.1 2011/03/04 06:58:57 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::LV::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::LV::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Republic of Latvia
sub communisexemplar { return qr{[.]lv\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# http://www.inbox.lv/
		'inbokss' => [
			qr{\Ainbox[.]lv\z},
		],
		# http://www.mail.lv/
		'mail.lv' => [
			qr{\Amail[.]lv\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'inbokss'	=> 'Generic',
		'mail.lv'	=> 'Generic',
	};
}

1;
__END__
