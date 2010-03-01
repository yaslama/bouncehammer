# $Id: MailboxFull.pm,v 1.3 2010/03/01 23:41:59 ak Exp $
# -Id: MailboxFull.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: MailboxFull.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                          
 ##  ##           ##  ###  ##                  ######         ###  ###    
 ######   ####         ##  ##      #### ##  ## ##      ##  ##  ##   ##    
 ######      ##  ###   ##  #####  ##  ## ####  ####    ##  ##  ##   ##    
 ##  ##   #####   ##   ##  ##  ## ##  ##  ##   ##      ##  ##  ##   ##    
 ##  ##  ##  ##   ##   ##  ##  ## ##  ## ####  ##      ##  ##  ##   ##    
 ##  ##   #####  #### #### #####   #### ##  ## ##       ##### #### ####   
package Kanadzuchi::Mail::Why::MailboxFull;

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
# Regular expressions of 'mailboxfull'
$Patterns = [
	qr(mailbox full)o,
	qr(mailbox is full)o,
	qr(too much mail data)o,
	qr(account is over quota)o,
	qr(account is temporarily over quota)o,
	qr(dd sorry, your message to .+ cannot be delivered[.] This account is over quota)o,
	qr(exceeded storage allocation)o,
];

1;
__END__
