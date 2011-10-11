# $Id: Rejected.pm,v 1.2.2.2 2011/10/11 03:03:55 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                       
 #####           ##                 ##             ##  
 ##  ##  ####         ####   #### ###### ####      ##  
 ##  ## ##  ##   ##  ##  ## ##      ##  ##  ##  #####  
 #####  ######   ##  ###### ##      ##  ###### ##  ##  
 ## ##  ##       ##  ##     ##      ##  ##     ##  ##  
 ##  ##  ####    ##   ####   ####    ### ####   #####  
              ####                                     
package Kanadzuchi::Mail::Why::Rejected;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Rejected'
sub exemplaria
{
	my $class = shift();
	return [ 
		# Rejected due to envelope from address
		qr{address rejected},
		qr{domain of sender address .+ does not exist},
		qr{sender rejected},
	];
}

1;
__END__
