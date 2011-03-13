# $Id: Smartphone.pm,v 1.1.2.3 2011/03/11 01:50:23 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::LU::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::LU::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Grand Duchy of Luxembourg 
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]lu\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'luxgsm' => [
			# LuxGSM; http://www.luxgsm.lu/ 
			qr{\Amobileemail[.]luxgsm[.]lu\z},
		],
		'orange' => [
			# Orange Luxembourg; http://orange.lu/
			# And see ../Smartphone.pm
			qr{\Avoxmobile[.]blackberry[.]com\z},
		],
		'tango' => [
			# Tango; http://www.tango.lu/
			qr{\Atango[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'luxgsm'	=> 'Generic',
		'orange'	=> 'Generic',
		'tango'		=> 'Generic',
	};
}

1;
__END__
