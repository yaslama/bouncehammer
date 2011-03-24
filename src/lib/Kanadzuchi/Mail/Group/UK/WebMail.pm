# $Id: WebMail.pm,v 1.1.2.3 2011/03/24 05:40:59 ak Exp $
# Copyright (C) 2010-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::UK::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::UK::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in the United Kingdom
# sub communisexemplar { return qr{[.]uk\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'spidernetworks' => [
			# http://www.postmaster.co.uk/
			qr{\Apostmaster[.]co[.]uk\z},
		],
		'yipple' => [
			# http://www.yipple.com/
			qr{\Ayipple[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'spidernetworks'=> 'Generic',
		'yipple'	=> 'Generic',
	};
}

1;
__END__
