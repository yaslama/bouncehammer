# $Id: WebMail.pm,v 1.2 2010/06/16 08:15:32 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::IR::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::IR::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Iran
sub communisexemplar { return qr{[.]ir\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# Experimental(Not tested)
		# http://iran.ir/
		'iran.ir' => [
			qr{\Airan[.]ir\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'iran.ir'	=> 'Generic',
	};
}

1;
__END__
