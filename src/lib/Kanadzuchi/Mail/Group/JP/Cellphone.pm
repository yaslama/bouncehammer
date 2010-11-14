# $Id: Cellphone.pm,v 1.7 2010/11/13 19:14:32 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::JP::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Japan
sub communisexemplar { return qr{[.]ne[.]jp\z}; }
sub nominisexemplaria
{
	my $self = shift();
	return {
		'nttdocomo' => [ 
			qr{\Adocomo[.]ne[.]jp\z},
		],
		'aubykddi'  => [
			qr{\Aezweb[.]ne[.]jp\z},
			qr{\A[0-9a-z]{2}[.]ezweb[.]ne[.]jp\z},
			qr{\A[0-9a-z][-0-9a-z]{0,8}[0-9a-z][.]biz[.]ezweb[.]ne[.]jp\z},
		],
		'softbank'  => [
			qr{\Asoftbank[.]ne[.]jp\z},
			qr{\A[dhtcrksnq][.]vodafone[.]ne[.]jp\z},
			qr{\Ajp-[dhtcrksnq][.]ne[.]jp\z},
			qr{\Adisney[.]ne[.]jp\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'nttdocomo'	=> 'Generic',
		'aubykddi'	=> 'Generic',
		'softbank'	=> 'Generic',
	};
}

1;
__END__
