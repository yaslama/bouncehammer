# $Id: Smartphone.pm,v 1.1.2.1 2011/03/09 06:32:11 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AU::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::AU::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Australia
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		'optus' => [
			# SingTel Optus Pty Limited; http://www.optus.com.au/
			qr{\Aoptus[.]blackberry[.]com\z},
		],
		'telstra' => [
			# Telstra; http://www.telstra.com.au/
			qr{\Atelstra[.]blackberry[.]com\z},
		],
		'three' => [
			# Three Mobile Australia; http://www.three.com.au/
			qr{\Athree[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'optus'		=> 'Generic',
		'telstra'	=> 'Generic',
		'three'		=> 'Generic',
	};
}

1;
__END__
