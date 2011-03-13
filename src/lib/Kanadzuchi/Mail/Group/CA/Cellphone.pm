# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 06:35:53 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CA::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::CA::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Canada
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]ca\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'aliant' => [
			# Bell Aliant; http://bell.aliant.ca/
			qr{\Awirefree[.]informe[.]ca\z},
		],
		'bell' => [
			# Bell Canada; http://www.bell.ca/
			qr{\Atxt[.]bell(?:mobility)?.ca\z},
			qr{\Abellmobility[.]ca\z}
		],
		'fido' => [
			# Fido Solutions; http://www.fido.ca/
			qr{\Afido[.]ca\z},
		],
		'mts' => [
			# Manitoba Telecom Services; http://www.mts.ca/
			qr{\Atext[.]mtsmobility[.]com\z},
		],
		'presidentschoice' => [
			# President's Choice: PC; http://www.presidentschoice.ca/
			qr{\Amobiletxt[.]ca\z},
		],
		'rogers' => [
			# Rogers Wireless; http://www.rogers.com/wireless
			qr{\Apcs[.]rogers[.]com\z},
		],
		'sasktel' => [
			# SaskTel; http://www.sasktel.com/
			qr{\Asms[.]sasktel[.]com\z},
			qr{\Apcs[.]sasktelmobility[.]com\z},
		],
		'telus' => [
			# Telus; http://www.telus.com/
			#  See Koodo Mobile; http://www.koodomobile.com/
			qr{\Amsg[.]telus[.]com\z},
		],
		'virgin' => [
			# Virgin Mobile; http://www.virginmobile.com/
			qr{\Avmobile[.]ca\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'aliant'	=> 'Generic',
		'bell'		=> 'Generic',
		'fido'		=> 'Generic',
		'mts'		=> 'Generic',
		'presidentschoice' => 'Generic',
		'rogers'	=> 'Generic',
		'sasktel'	=> 'Generic',
		'telus'		=> 'Generic',
		'virgin'	=> 'Generic',
	};
}

1;
__END__
