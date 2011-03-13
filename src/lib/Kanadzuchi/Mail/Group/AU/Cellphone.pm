# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:32:10 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AU::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::AU::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Commonwealth of Australia
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]au\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'optus' => [
			# SingTel Optus Pty Limited; http://www.optus.com.au/
			qr{\Aoptusmobile[.]com[.]au\z},
		],
		'telstra' => [
			# Telstra; http://www.telstra.com.au/
			qr{\A(?:sms[.])?tim[.]telstra[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'optus'		=> 'Generic',
		'telstra'	=> 'Generic',
	};
}

1;
__END__
