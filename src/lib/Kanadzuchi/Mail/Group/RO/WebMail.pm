# $Id: WebMail.pm,v 1.1.2.1 2011/04/07 06:53:17 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::RO::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::RO::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Romania
# sub communisexemplar { return qr{[.]ro\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'posta.ro' => [
			# www.posta.ro - Romanias first free webmail since 1997!
			# http://www.posta.ro/
			qr{\A(?:posta|mac|ze)[.]ro\z},
			qr{\Aroposta[.]com\z},
			qr{\A(?:adresamea|scrisoare|scrisori)[.]net\z},
			qr{\A(?:scrisoare|scris|mail|email|freemail|webmail)[.]co[.]ro\z},
			qr{\A(?:eu|europa|ue|matrix|mobil|net|pimp|write|writeme)[.]co[.]ro\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'posta.ro'	=> 'Generic',
	};
}

1;
__END__
