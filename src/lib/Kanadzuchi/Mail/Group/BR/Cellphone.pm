# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:35:04 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::BR::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::BR::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Brazil
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
sub communisexemplar { return qr{[.]br\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'claro' => [
			# Claro; http://www.americamovil.com/
			qr{\Aclarotorpedo[.]com[.]br\z},
		],
		'vivo' => [
			# Vivo S.A.; http://www.vivo.com.br/
			qr{\Atorpedoemail[.]com[.]br\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'claro'		=> 'Generic',
		'vivo'		=> 'Generic',
	};
}

1;
__END__
