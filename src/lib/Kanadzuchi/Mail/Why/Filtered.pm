# $Id: Filtered.pm,v 1.3 2010/03/01 23:41:59 ak Exp $
# -Id: Filtered.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: Filtered.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                   
 ###### ##  ###   ##                           ##  
 ##          ## ###### ####  #####   ####      ##  
 ####  ###   ##   ##  ##  ## ##  ## ##  ##  #####  
 ##     ##   ##   ##  ###### ##     ###### ##  ##  
 ##     ##   ##   ##  ##     ##     ##     ##  ##  
 ##    #### ####   ### ####  ##      ####   #####  
package Kanadzuchi::Mail::Why::Filtered;

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
# Regular expressions of 'filtered'
$Patterns = [
	qr(the message was rejected because it contains prohibited virus or spam content)o,
	qr(sorry, your remotehost looks suspiciously like spammer)o,
	qr(message filtered. please see the faqs section on spam)o,
	qr(blocked by policy: no spam please)o,
	qr(message rejected due to suspected spam content)o,
	qr(access denied)o,
	qr(message filtered)o,
	qr(domain of sender address .+ does not exist)o,
];

1;
__END__
