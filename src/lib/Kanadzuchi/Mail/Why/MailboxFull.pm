# $Id: MailboxFull.pm,v 1.8.2.1 2011/10/11 03:03:55 ak Exp $
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
		qr{dd sorry, your message to .+ cannot be delivered[.] this account is over quota},
		qr{delivery failed: over quota},
		qr{disc quota exceeded},
		qr{exceeded storage allocation},
		qr{mail file size exceeds the maximum size allowed for mail delivery},
		qr{mail quota exceeded},
		qr{mailbox over quota},
		qr{mailbox full},
		qr{mailbox is full},
		qr{maildir over quota},
		qr{not enough storage space in},
		qr{would be over the allowed quota},
		qr{over the allowed quota},
		qr{quota exceeded},
		qr{recipient reached disk quota},
		qr{recipient rejected: mailbox would exceed maximum allowed storage},
		qr{too much mail data},	# @docomo.ne.jp
		qr{user has exceeded quota, bouncing mail},
		qr{user is over quota},
		qr{user over quota[.] [(][#]5[.]1[.]1[)]\z},	# qmail-toaster
		qr{user over quota},
		qr{was automatically rejected: quota exceeded},

	];
}

1;
__END__
