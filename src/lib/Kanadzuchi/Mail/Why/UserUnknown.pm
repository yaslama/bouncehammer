# $Id: UserUnknown.pm,v 1.12 2010/12/12 06:19:35 ak Exp $
# -Id: UserUnknown.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: UserUnknown.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                
 ##  ##                      ##  ##         ##                                  
 ##  ##  #####  ####  #####  ##  ##  #####  ##     #####   ####  ##  ## #####   
 ##  ## ##     ##  ## ##  ## ##  ##  ##  ## ## ##  ##  ## ##  ## ##  ## ##  ##  
 ##  ##  ####  ###### ##     ##  ##  ##  ## ####   ##  ## ##  ## ###### ##  ##  
 ##  ##     ## ##     ##     ##  ##  ##  ## ## ##  ##  ## ##  ## ###### ##  ##  
  ####  #####   ####  ##      ####   ##  ## ##  ## ##  ##  ####  ##  ## ##  ##  
package Kanadzuchi::Mail::Why::UserUnknown;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'User Unknown'
sub exemplaria
{
	my $class = shift();
	return [
		qr{[#]5[.]1[.]1 bad address},
		qr{destination server rejected recipients},
		qr{invalid mailbox path},
		qr{invalid recipient:},
		qr{no such mailbox},
		qr{no such user here},
		qr{no such user},
		qr{<.+> not found},
		qr{mailbox not present},
		qr{mailbox unavailable},
		qr{recipient address rejected: access denied},
		qr{recipient address rejected: invalid user},
		qr{recipient address rejected: user .+ does not exist},
		qr{recipient address rejected: user unknown in[ ].+[ ]table},
		qr{recipient address rejected: unknown user},
		qr{recipient is not local},
		qr{said: 550[-\s]5[.]1[.]1[ ].+[ ]user[ ]unknown[ ]},
		qr{sorry, user unknown},
		qr{sorry, no mailbox here by that name},
		qr{this address no longer accepts mail},
		qr{this user doesn[']?t have a .+ account},	# Yahoo!
		qr{undeliverable address},
		qr{unknown address},
		qr{unknown recipient},
		qr{unknown user},
		qr{user missing home directory},
		qr{user unknown},
	];
}

1;
__END__
