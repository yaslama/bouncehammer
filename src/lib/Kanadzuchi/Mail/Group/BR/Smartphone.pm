# $Id: Smartphone.pm,v 1.1.2.1 2011/03/09 06:35:04 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::BR::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::BR::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Federative Republic of Brazil
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'claro' => [
			# Claro; http://www.claro.com.br/
			qr{\Aclaro[.]blackberry[.]com\z},
		],
		'nextel' => [
			# NEXTEL; http://m.nextel.com.br/
			qr{\Anextel[.]br[.]blackberry[.]com\z},
		],
		'oi' => [
			# Oi; http://www.oi.com.br/
			qr{\Aoi[.]blackberry[.]com\z},
		],
		'tim' => [
			# TIM Brasil; http://www.tim.com.br/
			qr{\Atimbrasil[.]blackberry[.]com\z},
		],
		'vivo' => [
			# Vivo S.A.; http://www.vivo.com.br/
			qr{\Avivo[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'claro'		=> 'Generic',
		'nextel'	=> 'Generic',
		'oi'		=> 'Generic',
		'tim'		=> 'Generic',
		'vivo'		=> 'Generic',
	};
}

1;
__END__
