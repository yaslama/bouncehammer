# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 07:20:22 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::UK::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::UK::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in The United Kingdom
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]uk\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'aql' => [
			# aql; http://aql.com/
			qr{\Atext[.]aql[.]com\z},	# http://aql.com/sms/email-to-sms/
		],
		'o2' => [
			# O2 (officially Telefónica O2 UK) ; http://www.o2.co.uk/
			qr{\Amobile[.]celloneusa[.]com\z},	# 44number@
			qr{\Ammail[.]co[.]uk\z},
			qr{\Ao2imail[.]co[.]uk\z},		# Cannot resolve ARR, MXRR
		],
		'orange' => [
			# Orange U.K.; http://www.orange.co.uk/
			qr{\Aorange[.]net\z},		# 0number@
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.net/
			qr{\At-mobile[.]uk[.]net\z},
		],
		'txtlocal' => [
			# Txtlocal; http://www.txtlocal.co.uk/
			qr{\Atxtlocal[.]co[.]uk\z},
		],
		'vodafone' => [
			# Vodafone; http://www.vodafone.com/
			qr{\Avodafone[.]net\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'aql'		=> 'Generic',
		'o2'		=> 'Generic',
		'orange'	=> 'Generic',
		't-mobile'	=> 'Generic',
		'txtlocal'	=> 'Generic',
		'vodafone'	=> 'Generic',
	};
}

1;
__END__
