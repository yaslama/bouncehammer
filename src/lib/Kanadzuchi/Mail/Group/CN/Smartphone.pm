# $Id: Smartphone.pm,v 1.1.2.2 2011/03/10 07:10:56 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CN::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::CN::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in People's Republic of China
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'chinamobile' => [
			# China Mobile; http://www.chinamobileltd.com/
			qr{\Achinamobile[.]blackberry[.]com\z},
		],
		'chinaunicom' => [
			# China unicom; http://www.10010.com/
			qr{\Achinaunicom[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'chinamobile'	=> 'Generic',
		'chinaunicom'	=> 'Generic',
	};
}

1;
__END__
