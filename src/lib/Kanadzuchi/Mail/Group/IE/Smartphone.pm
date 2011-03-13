# $Id: Smartphone.pm,v 1.1.2.2 2011/03/10 05:58:06 ak Exp $
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::IE::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::IE::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Ireland
# sub communisexemplar { return qr{[.]ie\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'three' => [
			# 3 Ireland; http://three.ie/
			qr{\A3ireland[.]blackberry[.]com\z},
		],
		'o2' => [
			# O2 Ireland; http://www.o2online.ie/
			qr{\Ao2mail[.]ie\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'three'		=> 'Generic',
		'o2'		=> 'Generic',
	};
}

1;
__END__
