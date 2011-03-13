# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:33:37 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::BG::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::BG::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Republic of Bulgaria
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]bg\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'globul' => [
			# GLOBUL; http://www.globul.bg/
			qr{\Asms[.]globul[.]bg\z},
		],
		'mtel' => [
			# Mobiltel; http://www.mtel.bg/
			qr{\Asms[.]mtel[.]net\z},
		],
		'vivacom' => [
			# Vivacom; http://www.vivacom.bg/
			qr{\Asms[.]vivacom[.]bg\z},	# (country-code-Vivacom-area-code-number@)
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'globul'	=> 'Generic',
		'mtel'		=> 'Generic',
		'vivacom'	=> 'Generic',
	};
}

1;
__END__
