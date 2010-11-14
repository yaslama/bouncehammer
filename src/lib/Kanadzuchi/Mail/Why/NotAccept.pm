# $Id: NotAccept.pm,v 1.1 2010/11/13 19:12:55 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                            
 ##  ##          ##     ##                            ##    
 ### ##   #### ######  ####   #### #### ####  ##### ######  
 ######  ##  ##  ##   ##  ## ##   ##   ##  ## ##  ##  ##    
 ## ###  ##  ##  ##   ###### ##   ##   ###### ##  ##  ##    
 ##  ##  ##  ##  ##   ##  ## ##   ##   ##     #####   ##    
 ##  ##   ####    ### ##  ##  #### #### ####  ##       ###  
                                              ##            
package Kanadzuchi::Mail::Why::NotAccept;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Not Accept'
sub exemplaria
{
	my $class = shift();
	return [
		qr{name service error for },	# Malformed MX RR or host not found
	];
}

1;
__END__
