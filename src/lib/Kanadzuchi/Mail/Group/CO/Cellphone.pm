# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:37:54 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CO::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::CO::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Republic of Colombia
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]co\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'comcel' => [
			# Comcel Colombia; http://www.comcel.com/
			qr{\Acomcel[.]com[.]co\z},
		],
		'millicom' => [
			# Millicom International Cellular, also known as Tigo,
			# http://www.tigo.com/, http://www.millicom.com/
			qr{\Asms[.]tigo[.]com[.]co\z},
		],
		'movistar' => [
			# Movistar; http://www.telefonica.com/
			qr{\Amovistar[.]com[.]co\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'comcel'	=> 'Generic',
		'millicom'	=> 'Generic',
		'movistar'	=> 'Generic',
	};
}

1;
__END__
