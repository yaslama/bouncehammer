# $Id: UserUnknown.pm,v 1.7 2010/07/04 23:46:53 ak Exp $
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
		qr{550 Invalid recipient:},
		qr{no such mailbox},
		qr{no such user here},
		qr{no such user!},
		qr{delivery error: dd this user doesn[']?t have a },
		qr{destination server rejected recipients},
		qr{mailbox not present},
		qr{recipient address rejected: invalid user},
		qr{recipient address rejected: user .+ does not exist},
		qr{recipient address rejected: user unknown in relay recipient table},
		qr{recipient address rejected: user unknown in local recipient table},
		qr{recipient address rejected: user unknown in virtual mailbox table},
		qr{recipient address rejected: user unknown in virtual alias table},
		qr{recipient address rejected: unknown user},
		qr{recipient is not local},
		qr{requested action not taken: mailbox unavailable},
		qr{said: 550[-\s]5[.]1[.]1[ ].+[ ]user[ ]unknown[ ]},
		qr{sorry, user unknown},
		qr{sorry, no mailbox here by that name},
		qr{unknown address},
		qr{unknown recipient},
		qr{unknown user},
		qr{user unknown},
	];
}

1;
__END__
