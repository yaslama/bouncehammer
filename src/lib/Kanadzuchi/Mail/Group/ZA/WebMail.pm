# $Id: WebMail.pm,v 1.3.2.1 2011/03/24 05:40:59 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::ZA::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::ZA::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in South Africa/Zuid-Afrika
sub communisexemplar { return qr{[.]za\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'mighty' => [
			# http://www.mighty.co.za/
			qr{\Amighty[.]co[.]za\z},
		],
		'webmail.co.za' => [
			# http://www.webmail.co.za/
			qr{\A(?:exclusive|executive|home|magic|rave|star|work|web)mail[.]co[.]za\z},
			qr{\Athe(?:cricket|golf|pub|rugby)[.]co[.]za\z},
			qr{\A(?:mailbox|websurfer)[.]co[.]za\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'mighty'	=> 'Generic',
		'webmail.co.za'	=> 'Generic',
	};
}

1;
__END__
