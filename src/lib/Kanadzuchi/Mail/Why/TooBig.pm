# $Id: TooBig.pm,v 1.2 2010/02/21 20:37:03 ak Exp $
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

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
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
