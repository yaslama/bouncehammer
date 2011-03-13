# $Id: Smartphone.pm,v 1.1.2.2 2011/03/10 08:48:22 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::MX::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::MX::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in United Mexican States
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]mx\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'iusacell' => [
			# Iusacell; http://www.iusacell.com.mx/
			qr{\Aiusacell[.]blackberry[.]com\z},
		],
		'movistar' => [
			# movistar; http://movistar.com.mx/
			qr{\Amovistar[.]mx[.]blackberry[.]com\z},
		],
		'telcel' => [
			# Telcel; http://telcel.com.mx/ 
			qr{\Atelcel[.]blackberry[.](?:com|net)\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'iusacell'	=> 'Generic',
		'movistar'	=> 'Generic',
		'telcel'	=> 'Generic',
	};
}

1;
__END__
