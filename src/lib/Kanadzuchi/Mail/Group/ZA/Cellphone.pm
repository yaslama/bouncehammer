# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 07:21:48 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::ZA::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::ZA::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in South Africa/Zuid-Afrika
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]za\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'mtngroup' => [
			# MTN Group; http://www.mtn.com/
			qr{\Asms[.]co[.]za\z},
		],
		'vodafone' => [
			# Vodacom; http://www.vodacom.co.za/
			qr{\Avoda[.]co[.]za\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'mtngroup'	=> 'Generic',
		'vodafone'	=> 'Generic',
	};
}

1;
__END__
