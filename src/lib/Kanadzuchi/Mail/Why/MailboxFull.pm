# $Id: MailboxFull.pm,v 1.6 2010/07/04 23:46:53 ak Exp $
# -Id: MailboxFull.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: MailboxFull.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                       
 ##  ##         ##  ###  ##                  ######        ###  ###    
 ######  ####        ##  ##      #### ##  ## ##     ##  ##  ##   ##    
 ######     ## ###   ##  #####  ##  ## ####  ####   ##  ##  ##   ##    
 ##  ##  #####  ##   ##  ##  ## ##  ##  ##   ##     ##  ##  ##   ##    
 ##  ## ##  ##  ##   ##  ##  ## ##  ## ####  ##     ##  ##  ##   ##    
 ##  ##  ##### #### #### #####   #### ##  ## ##      ##### #### ####   
package Kanadzuchi::Mail::Why::MailboxFull;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'mailboxfull'
sub exemplaria
{
	my $class = shift();
	return [
		qr{account is over quota},
		qr{account is temporarily over quota},
		qr{dd sorry, your message to .+ cannot be delivered[.] This account is over quota},
		qr{exceeded storage allocation},
		qr{mailbox full},
		qr{mailbox is full},
		qr{recipient rejected: mailbox would exceed maximum allowed storage},
		qr{too much mail data},
	];
}

1;
__END__
