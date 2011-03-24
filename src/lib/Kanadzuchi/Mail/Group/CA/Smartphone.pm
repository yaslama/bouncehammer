# $Id: Smartphone.pm,v 1.1.2.2 2011/03/22 06:41:25 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CA::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::CA::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Canada
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]ca\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'bell' =>[
			# Fido Solutions; http://www.fido.ca/
			qr{\Abell[.]blackberry[.](?:com|net)\z},
		],
		'fido' => [
			# Fido Solutions; http://www.fido.ca/
			qr{\Afido[.]blackberry[.](?:com|net)\z},
		],
		'mts' => [
			# Manitoba Telecom Services; http://www.mts.ca/
			qr{\Amtsm[.]blackberry[.]com\z},
		],
		'rogers' => [
			# Rogers Communications; http://www.rogers.com/
			qr{\Arogers[.]blackberry[.](?:com|net)\z},
		],
		'tbaytel' => [
			# Tbaytel; http://www.tbaytel.net/
			qr{\Atbaytel[.]blackberry[.]com\z},
		],
		'telus' => [
			# Telus; http://www.telus.com/
			qr{\Atelus[.]blackberry[.](?:com|net)\z},
		],
		'virgin' => [
			qr{\Avirginmobile[.]blackberry[.]com\z},
		],
		'wind' => [
			# WIND Mobile; http://www.windmobile.ca/
			qr{\Awind[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'bell'		=> 'Generic',
		'fido'		=> 'Generic',
		'mts'		=> 'Generic',
		'rogers'	=> 'Generic',
		'tbaytel'	=> 'Generic',
		'telus'		=> 'Generic',
		'virgin'	=> 'Generic',
		'wind'		=> 'Generic',
	};
}

1;
__END__
