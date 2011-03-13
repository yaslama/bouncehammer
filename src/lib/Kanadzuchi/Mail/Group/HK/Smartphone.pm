# $Id: Smartphone.pm,v 1.1.2.1 2011/03/09 06:53:38 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::HK::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::HK::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Hong Kong
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'hkcsl' => [
			# CSL Limited; http://www.hkcsl.com/
			qr{\Acsl[.]blackberry[.]com\z},
		],
		'pccw' => [
			# PCCW Limited; http://www.pccw.com/eng//
			qr{\Apccwmobile[.]blackberry[.]com\z},
		],
		'smartone' => [
			# SmarTone Mobile Communications Limited; http://www.smartone.com.hk/
			# StarTone-Vodafone
			qr{\Asmartone[.]blackberry[.]com\z},
		],
		'three' => [
			# Three.com.hk; http://www.three.com.hk/
			qr{\Athreehk[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'hkcsl'		=> 'Generic',
		'pccw'		=> 'Generic',
		'smartone'	=> 'Generic',
		'three'		=> 'Generic',
	};
}

1;
__END__
