# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 07:13:35 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::PR::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::PR::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Commonwealth of Puerto Rico
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]pr\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'centennial' => [
			# Centennial Communications; http://www.centennialwireless.com/
			qr{\Acwemail[.]com\z},
		],
		'claro' => [
			# Claro; http://www.americamovil.com/
			qr{\Avtexto[.]com\z}
		],
		'tracfone' => [
			# TracFone Wireless; http://www.tracfone.com/
			qr{\Amypixmessages[.]com\z},	# Straight Talk
			qr{\Ammst5[.]tracfone[.]com\z},	# Direct
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'centennial'	=> 'Generic',
		'claro'		=> 'Generic',
		'tracfone'	=> 'Generic',
	};
}

1;
__END__
