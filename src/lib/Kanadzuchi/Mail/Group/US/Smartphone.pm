# $Id: Smartphone.pm,v 1.1.2.2 2011/03/10 05:58:24 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::US::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::US::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in The United States of America.
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]us\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'alltel' => [
			# AllTel Wireless; http://www.alltel.com
			qr{\Aalltel[.]blackberry[.]com\z},
		],
		'att' => [
			# Cingular Wireles -> AT&T Mobility
			qr{\A(?:att|mycingular)[.]blackberry[.](?:com|net)\z},
		],
		'bluegrass' => [
			# Bluegrass Cellular; http://bluegrasscellular.com/
			qr{\Abluegrass[.]blackberry[.]com\z},
		],
		'cbeyond' => [
			# Cbeyond; http://www.cbeyond.net/
			qr{\Acbeyond[.]blackberry[.]com\z},
		],
		'cellcomus' => [
			# Cellcom; http://www.cellcom.com/
			qr{\Acellcom[.]us[.]blackberry[.]com\z},
		],
		'cellularone' => [
			# Cellular One; http://www.cellularone.com/
			qr{\Adobsoncellular[.]blackberry[.]net\z},
			qr{\Acellularone[.]blackberry[.](?:com|net)\z},
		],
		'cellularsouth' => [
			# Cellular South; http://www.cellularsouth.com/
			qr{\Acsouth1[.]blackberry[.]com\z},
		],
		'centennial' => [
			# Centennial Communications; http://www.centennialwireless.com/
			qr{\Acentennial[.]blackberry[.]com\z},
		],
		'cincinatibell' => [
			# Cincinnati Bell; http://www.cincinnatibell.com/
			qr{\Acinbell[.]blackberry[.](?:com|net)\z},
		],
		'earthlink' => [
			# EarthLink; http://www.earthlink.net/
			qr{\Aearthlink[.]blackberry[.]net\z},
		],
		'edgewireless' => [
			# Edge Wireless; http://www.edgewireless.com/ ...? 
			# AT&T
			qr{\Aedgewireless[.]blackberry[.]com\z},
		],
		'metropcs' => [
			# MetroPCS Communications, Inc.; http://www.metropcs.com/
			qr{\Ametropcs[.]blackberry[.]com\z},
		],
		'ntelos' => [
			# nTelos; http://www.ntelos.com/
			qr{\Antelos[.]blackberry[.]com\z},
		],
		'southernlinc' => [
			# SouthernLINC Wireless; http://www.southernlinc.com/
			qr{\Asouthernlinc[.]blackberry[.]com\z},
		],
		# Optus in U.S.A. ?
		'sprint' => [
			# Sprint Nextel; http://www.sprint.com/
			qr{\A(?:nextel|sprint)[.]blackberry[.](?:com|net)\z},
		],
		'tcs' => [
			# TeleCommunication Systems; http://www.telecomsys.com/
			qr{\Atcs[.]blackberry[.]net\z},
		],
		't-mobile' => [
			# T-Mobile; http://www.t-mobile.com/
			qr{\Atmo[.]blackberry[.]net\z},
		],
		'uscellular' => [
			# U.S. Cellular; http://www.uscellular.com/uscellular/
			qr{\Auscellular[.]blackberry[.]com\z},
		],
		'verizon' => [
			# Verizon Wireless; http://www.verizonwireless.com/
			qr{\Avzw[.]blackberry[.]net\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'alltel'	=> 'Generic',
		'att'		=> 'Generic',
		'bluegrass'	=> 'Generic',
		'cbeyond'	=> 'Generic',
		'cellcomus'	=> 'Generic',
		'cellularone'	=> 'Generic',
		'cellularsouth'	=> 'Generic',
		'centennial'	=> 'Generic',
		'cincinatibell'	=> 'Generic',
		'earthlink'	=> 'Generic',
		'edgewireless'	=> 'Generic',
		'metropcs'	=> 'Generic',
		'ntelos'	=> 'Generic',
		'southernlinc'	=> 'Generic',
		'sprint'	=> 'Generic',
		'tcs'		=> 'Generic',
		't-mobile'	=> 'Generic',
		'uscellular'	=> 'Generic',
		'verizon'	=> 'Generic',
	};
}

1;
__END__
