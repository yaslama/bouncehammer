# $Id: Smartphone.pm,v 1.1.2.1 2011/03/10 05:49:17 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::DK::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::DK::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Kingdom of Denmark/Kongeriget Danmark
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'telenor' => [
			# Telenor; http://www.telenor.dk/
			qr{\Atelenor[.]?dk[.]blackberry[.]com\z},
		],
		'telia' => [
			# Telia; http://telia.dk/
			qr{\Ateliadk[.]blackberry[.]com\z},
		],
		'three' => [
			# 3; http://www.3.dk/
			qr{\Atre[.]blackberry[.]com\z},	# ...?
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'telenor'	=> 'Generic',
		'telia'		=> 'Generic',
		'three'		=> 'Generic',
	};
}

1;
__END__
