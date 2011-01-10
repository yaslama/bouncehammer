# $Id: Smartphone.pm,v 1.1.2.1 2011/01/08 20:45:44 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                   
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major smartphone provider's domains in The World
sub nominisexemplaria
{
	my $class = shift();
	return {
		'vertu' => [
			# Vertu.Me; http://www.vertu.me/
			qr{\Avertu[.]me\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'vertu'		=> 'Generic',
	};
}

1;
__END__
