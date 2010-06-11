# $Id: TooBig.pm,v 1.4 2010/06/10 10:03:15 ak Exp $
# -Id: TooBig.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: TooBig.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                             
 ######                #####     ##          
   ##     ####   ####  ##  ##         #####  
   ##    ##  ## ##  ## #####    ###  ##  ##  
   ##    ##  ## ##  ## ##  ##    ##  ##  ##  
   ##    ##  ## ##  ## ##  ##    ##   #####  
   ##     ####   ####  #####    ####     ##  
                                     #####   
package Kanadzuchi::Mail::Why::TooBig;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Message Too Big'
$Patterns = [
	qr(message size exceeds fixed maximum message size)o,
	qr(message size exceeds fixed limit)o,
	qr(message size exceeds maximum value)o,
	qr(message file too big)o,
];

1;
__END__
