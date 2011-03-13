# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 07:20:38 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::US::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::US::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in The United States of America
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]us\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift();
	return {
		'alaskacomm' => [
			# Alaska Communications; http://www.alaskacommunications.com/
			qr{\Amsg[.]acsalaska[.]com\z},
		],
		'alltel' => [
			# AllTel Wireless; http://www.alltel.com
			qr{\Amessage[.]alltel[.]com\z},		# SMS & MMS
			qr{\Atext[.]wireless[.]alltel[.]com\z},	# SMS
			qr{\Amms[.]alltel[.]net\z},		# MMS
		],
		'att' => [
			# AT&T Wireless; http://wireless.att.com/home/
			qr{\A(?:txt|mms|page)[.]att[.]net\z},	# SMS, MMS, AT&T Enterprise Paging
			qr{\Ammode[.]com\z},			# AT&T grandfathered customers
			qr{\Acingularme[.]com\z},		# AT&T Mobility (Formerly Cingular)
			qr{\Amobile[.]mycingular[.]com\z},
			qr{\Asms[.]smartmessagingsuite[.]com\z},# AT&T Global Smart Messaging Suite
			qr{\Acingular[.]com\z},			# Cingular (Postpaid)
			qr{\Acingulartext[.]com\z},		# Cingular (GoPhone prepaid)
		],
		'boostmobile' => [
			# Boost Mobile; http://www.boostmobile.com/
			qr{\Amyboostmobile[.]com\z},
		],
		'cellularone' => [
			# Cellular One; http://www.cellularone.com/
			qr{\Amobile[.]celloneusa[.]com\z},
		],
		'cellularsouth' => [
			# Cellular South; http://www.cellularsouth.com/
			qr{\Acsouth1[.]com\z},
		],
		'centennial' => [
			# Centennial Communications; http://www.centennialwireless.com/
			qr{\Acwemail[.]com\z},
		],
		'cincinatibell' => [
			# Cincinnati Bell; http://www.cincinnatibell.com/
			qr{\A(?:mms[.])?gocbw[.]com\z},		# MMS, SMS
		],
		'crecket' => [
			# Cricket Wireless; http://www.mycricket.com/
			qr{\A(?:mms|sms)[.]mycricket[.]com\z},	# MMS, SMS
		],
		'gci' => [
			# GCI, General Communication Inc.; http://www.gci.com/
			qr{\Amobile[.]gci[.]net\z},
		],
		'gsc' => [
			# Golden State Cellular; http://www.goldenstatecellular.com/
			qr{\Agscsms[.]com\z},
		],
		'helio' => [
			# Helio; http://www.heliomag.com/
			qr{\Amyhelio[.]com\z},
		],
		'iwireless' => [
			# i wireless; http://www.iwireless.com/
			qr{\Aiwspcs[.]net\z},		# T-Mobile, <phone-number>iws@
			qr{\Aiwirelesshometext[.]com},	# Sprint PCS
		],
		'metropcs' => [
			# MetroPCS Communications, Inc.; http://www.metropcs.com/
			qr{\Amymetropcs[.]com\z},
		],
		'pioneercellular' => [
			# Pioneer Cellular; https://www.wirelesspioneer.com/
			qr{\Azsend[.]com\z},		# 9-digit-number@
		],
		'pocketcomm' => [
			# Pocket Communications; http://www.pocket.com/
			qr{\Asms[.]pocket[.]com\z},
		],
		'qwest' => [
			# Qwest Wireless; http://www.qwest.com/wireless
			qr{\Aqwestmp[.]com\z},
		],
		'southcentralcomm' => [
			# South Central Communications; http://www.southcentralcommunications.net/
			qr{\Arinasms[.]com\z},		# SMS
		],
		'sprint' => [
			# Sprint Nextel Corporation; http://sprint.com/
			qr{\Amessaging[.]sprintpcs[.]com\z},		# SMS
			qr{\Apm[.]sprint[.]com\z},			# MMS
			qr{\A(page|messaging)[.]nextel[.]com\z},	# Rich messaging, SMS
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.net/
			qr{\Atmomail[.]net\z},	# MMS, number can and by default properly begins with "1" (the US country code)
		],
		'tracfone' => [
			# TracFone Wireless; http://www.tracfone.com/
			qr{\Amypixmessages[.]com\z},	# Straight Talk
			qr{\Ammst5[.]tracfone[.]com\z},	# Direct
		],
		'uscellular' => [
			# U.S. Cellular, http://www.uscc.com/
			qr{\A(?:email|mms)[.]uscc[.]net\z},	# SMS,MMS
		],
		'verizon' => [
			# Verizon Wireless; http://www.verizonwireless.com/
			qr{\A(?:vtext|vzwpix)[.]com\z},		# SMS,MMS
		],
		'viaero' => [
			# Viaero Wireless; http://www.viaero.com/
			qr{\A(?:viaerosms|mmsviaero)[.]com\z},	# SMS,MMS
		],
		'virgin' => [
			# Virgin Mobile; http://www.virginmobile.com/
			# http://www.virgin.com/gateways/mobile/
			qr{\A(?:vmobl|vmpix)[.]com\z},		# SMS,MMS
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'alaskacomm'	=> 'Generic',
		'alltel'	=> 'Generic',
		'att'		=> 'Generic',
		'boostmobile'	=> 'Generic',
		'cellularone'	=> 'Generic',
		'cellularsouth'	=> 'Generic',
		'centennial'	=> 'Generic',
		'cincinatibell'	=> 'Generic',
		'crecket'	=> 'Generic',
		'gci'		=> 'Generic',
		'gsc'		=> 'Generic',
		'helio'		=> 'Generic',
		'iwireless'	=> 'Generic',
		'metropcs'	=> 'Generic',
		'pioneercellular' => 'Generic',
		'pocketcomm'	=> 'Generic',
		'qwest'		=> 'Generic',
		'southcentralcomm' => 'Generic',
		'sprint'	=> 'Generic',
		't-mobile'	=> 'Generic',
		'tracfone'	=> 'Generic',
		'uscellular'	=> 'Generic',
		'verizon'	=> 'Generic',
		'viaero'	=> 'Generic',
		'virgin'	=> 'Generic',
	};
}

1;
__END__
