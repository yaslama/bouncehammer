# $Id: RelayingDenied.pm,v 1.4 2010/04/02 11:42:26 ak Exp $
# -Id: RelayingDenied.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: RelayingDenied.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                                
 #####        ###                   ##                ####                   ##             ##  
 ##  ##  ####  ##   ####  ##  ##        #####   ##### ## ##   ####  #####         ####      ##  
 ##  ## ##  ## ##      ## ##  ##   ###  ##  ## ##  ## ##  ## ##  ## ##  ##  ###  ##  ##  #####  
 #####  ###### ##   ##### ##  ##    ##  ##  ## ##  ## ##  ## ###### ##  ##   ##  ###### ##  ##  
 ## ##  ##     ##  ##  ##  #####    ##  ##  ##  ##### ## ##  ##     ##  ##   ##  ##     ##  ##  
 ##  ##  #### ####  #####    ##    #### ##  ##     ## ####    ####  ##  ##  ####  ####   #####  
                          ####                 #####                                            
package Kanadzuchi::Mail::Why::RelayingDenied;

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
# Regular expressions of 'Relaying Denied'
$Patterns = [
	qr(relaying denied)o,					# Sendmail
	qr(that domain isn[']t in my list of allowed rcpthost)o,# qmail
	qr(relay denied)o,
	qr(relay not permitted)o,
	qr(relay access denied)o,
];



1;
__END__
