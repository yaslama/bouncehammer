# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:47:04 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::DE::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::DE::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Federal Republic of Germany/Bundesrepublik Deutschland
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]de\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'e-plus' => [
			# E-Plus; http://www.eplus.de/
			qr{\Asmsmail[.]eplus[.]de\z},
		],
		'o2' => [
			# Telefonica; o2online.de
			qr{\Ao2online[.]de\z},
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.net/
			qr{\At-d1-sms[.]de\z},
		],
		'vodafone' => [
			# Vodafone; http://www.vodafone.com/
			qr{\Avodafone-sms[.]de\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'e-plus'	=> 'Generic',
		'o2'		=> 'Generic',
		't-mobile'	=> 'Generic',
		'vodafone'	=> 'Generic',
	};
}

1;
__END__
