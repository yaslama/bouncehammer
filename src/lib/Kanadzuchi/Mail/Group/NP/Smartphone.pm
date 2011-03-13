# $Id: Smartphone.pm,v 1.1.2.1 2011/03/09 07:10:07 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::NP::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::NP::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Federal Democratic Republic of Nepal
# See http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'ncell' => [
			# Ncell Private Ltd.; http://www.ncell.com.np/
			#  % dig mx ncell.blackberry.com +short
			#    10 mx02.bis7.eu.blackberry.com.
			#    10 mx03.bis7.eu.blackberry.com.
			#    10 mx04.bis7.eu.blackberry.com.
			#    10 mx01.bis7.eu.blackberry.com.
			# 
			# eu ?
			qr{\Ancell[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'ncell'		=> 'Generic',
	};
}

1;
__END__
