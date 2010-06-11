# $Id: HostUnknown.pm,v 1.4 2010/06/10 10:03:15 ak Exp $
# -Id: HostUnknown.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: HostUnknown.pm,v 1.1 2009/05/04 05:17:05 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                 
 ##  ##                  ##   ##  ##         ##                                  
 ##  ##   ####   ##### ###### ##  ##  #####  ##     #####   ####  ##  ## #####   
 ######  ##  ## ##       ##   ##  ##  ##  ## ## ##  ##  ## ##  ## ##  ## ##  ##  
 ##  ##  ##  ##  ####    ##   ##  ##  ##  ## ####   ##  ## ##  ## ###### ##  ##  
 ##  ##  ##  ##     ##   ##   ##  ##  ##  ## ## ##  ##  ## ##  ## ###### ##  ##  
 ##  ##   ####  #####     ###  ####   ##  ## ##  ## ##  ##  ####  ##  ## ##  ##  
package Kanadzuchi::Mail::Why::HostUnknown;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Host Unknown'
$Patterns = [
	qr(recipient address rejected: unknown domain name)o,
	qr(host unknown)o,
];

1;
__END__
