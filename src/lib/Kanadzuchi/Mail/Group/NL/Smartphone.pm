# $Id: Smartphone.pm,v 1.1.2.3 2011/03/11 06:15:49 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::NL::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::NL::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in the Netherlands/Koninkrijk der Nederlanden
# and Netherlands Antilles/Nederlandse Antillen.
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]nl\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'kpn' => [
			# KPN; http://www.kpn.com/
			qr{\Akpn[.]blackberry[.]com\z},
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.nl/
			qr{\Ainstantemail[.]t-mobile[.]nl\z},
		],
		'uts' => [
			# UTS/Netherlands Antilles; http://www.uts.an/
			qr{\Auts[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'kpn'		=> 'Generic',
		't-mobile'	=> 'Generic',
		'uts'		=> 'Generic',
	};
}

1;
__END__
