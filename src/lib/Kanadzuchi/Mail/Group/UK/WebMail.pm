# $Id: WebMail.pm,v 1.1.2.1 2011/03/04 06:59:13 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
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
		# http://gmx.co.uk/
		'gmx.com' => [
			qr{\Agmx[.]co[.]uk\z},
		],
		# http://www.postmaster.co.uk/
		'spidernetworks' => [
			qr{\Apostmaster[.]co[.]uk\z},
		],
		# http://www.yipple.com/
		'yipple' => [
			qr{\Ayipple[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'gmx.com'	=> 'Generic',
		'spidernetworks'=> 'Generic',
		'yipple'	=> 'Generic',
	};
}

1;
__END__
