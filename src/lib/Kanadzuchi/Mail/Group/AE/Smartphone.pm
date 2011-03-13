# $Id: Smartphone.pm,v 1.1.2.2 2011/03/11 02:23:15 ak Exp $
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AE::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::AE::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in United Arab Emirates
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'du' => [
			# du; http://du.ae/
			qr{\Adu[.]blackberry[.]com\z},
		],
		'etisalat' => [
			# Etisalat; http://www.etisalat.ae/
			qr{\Aetisalat[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'du'		=> 'Generic',
		'etisalat'	=> 'Generic',
	};
}

1;
__END__
