# $Id: Cellphone.pm,v 1.1.2.1 2011/03/09 07:22:56 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
#                                                             
#   ####        ###  ###         ##                           
#  ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
#  ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
#  ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
#  ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
#   ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
#                         ##                                  
package Kanadzuchi::Mail::Group::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major cellular phone provider's domains in The World
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $class = shift();
	return {
		'globalstar' => [
			# Globalstar; http://globalstar.com/
			qr{\Amsg[.]globalstarusa[.]com},
		],
		'iridium' => [
			# Iridium Communications Inc.; http://iridium.com/
			qr{\Amsg[.]iridium[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'globalstar'	=> 'Generic',
		'iridium'	=> 'Generic',
	};
}

1;
__END__
