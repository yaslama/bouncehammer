# $Id: Smartphone.pm,v 1.3.2.5 2011/03/13 06:14:54 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::UK::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::UK::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in the United Kingdom
# and Bailiwick of Guernsey
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]uk\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# orange: see ../Smartphone.pm
		'bt' => [
			# BT; http://www.bt.com/
			qr{\Abt[.]blackberry[.]com\z},
		],
		'o2' => [
			# Telefonica O2 UK Limited.
			# https://www.o2.co.uk/
			qr{\Ao2[.]co[.]uk\z},
			qr{\Ao2email[.]co[.]uk\z},
		],
		'sure' => [
			# Sure (Cable & Wireless) in Guernsey; http://www.surecw.com/
			qr{\Acwguernsey[.]blackberry[.]net\z},
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.co.uk/
			qr{\Ainstantemail[.]t-mobile[.]co[.]uk\z},
		],
		'tesco' => [
			# Tesco Mobile; http://www.tesco.com/mobilenetwork/
			qr{\Atesco[.]blackberry[.]com\z},
		],
		'three' => [
			# Three; http://www.three.co.uk/
			qr{\A3uk[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'bt'		=> 'Generic',
		'o2'		=> 'Generic',
		'sure'		=> 'Generic',
		't-mobile'	=> 'Generic',
		'tesco'		=> 'Generic',
		'three'		=> 'Generic',
	};
}

1;
__END__
