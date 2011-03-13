# $Id: Smartphone.pm,v 1.1.2.3 2011/03/10 05:56:31 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::BE::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::BE::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Kingdom of Belgium
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'base' => [
			# BASE; http://www.base.be/
			qr{\Abase[.]blackberry[.]com\z},
		],
		'mobistar' => [
			# Mobistar; http://www.mobistar.be/
			qr{\Ablackberry[.]mobistar[.]be\z},
		],
		'proximus' => [
			# Proximus; http://www.proximus.be/
			qr{\Aproximus[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'base'		=> 'Generic',
		'mobistar'	=> 'Generic',
		'proximus'	=> 'Generic',
	};
}

1;
__END__
