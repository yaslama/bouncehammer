# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:31:08 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AR::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::AR::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Argentina/Argentine Republic
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]ar\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'claro' => [
			# Claro, CTI Móvil
			qr{\Asms[.]ctimovil[.]com[.]ar\z},
		],
		'nextel' => [
			# NEXTEL ARGENTINA; http://www.nextel.com.ar/
			qr{\Anextel[.]net[.]ar\z},
		],
		'personal' => [
			# Telecom Personal S.A.; http://www.telecom.com.ar/
			qr{\Aalertas[.]personal[.]com[.]ar\z},
		],
		'movistar' => [
			# Movistar; http://www.movistar.com/
			qr{\Amovistar[.]com[.]ar\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'claro'		=> 'Generic',
		'movistar'	=> 'Generic',
		'nextel'	=> 'Generic',
		'personal'	=> 'Generic',
	};
}

1;
__END__
