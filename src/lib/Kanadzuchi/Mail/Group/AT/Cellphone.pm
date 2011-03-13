# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:31:32 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AT::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::AT::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Republic of Austria/Republik Österreich
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]at\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.net/ http://t-mobile.at/
			qr{\Asms[.]t-mobile[.]at\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		't-mobile'	=> 'Generic',
	};
}

1;
__END__
