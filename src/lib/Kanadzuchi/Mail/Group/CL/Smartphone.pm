# $Id: Smartphone.pm,v 1.1.2.2 2011/03/10 08:48:21 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CL::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::CL::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Republic of Chile
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]cl\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'claro' => [
			# Claro Chile; http://www.clarochile.cl/
			qr{\Aclarochile[.]blackberry[.]com\z},
		],
		'entel' => [
			# Entel; http://www.entel.cl/
			qr{\Aentelpcs[.]blackberry[.](?:com|net)\z},
		],
		'movistar' => [
			# movistar; http://www.movistar.cl/
			qr{\Amovistar[.]cl[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'claro'		=> 'Generic',
		'entel'		=> 'Generic',
		'movistar'	=> 'Generic',
	};
}

1;
__END__
