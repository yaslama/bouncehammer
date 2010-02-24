# $Id: UserUnknown.pm,v 1.2 2010/02/21 20:37:03 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                 
 ##  ##                       ##  ##         ##                                  
 ##  ##   #####  ####  #####  ##  ##  #####  ##     #####   ####  ##  ## #####   
 ##  ##  ##     ##  ## ##  ## ##  ##  ##  ## ## ##  ##  ## ##  ## ##  ## ##  ##  
 ##  ##   ####  ###### ##     ##  ##  ##  ## ####   ##  ## ##  ## ###### ##  ##  
 ##  ##      ## ##     ##     ##  ##  ##  ## ## ##  ##  ## ##  ## ###### ##  ##  
  ####   #####   ####  ##      ####   ##  ## ##  ## ##  ##  ####  ##  ## ##  ##  
package Kanadzuchi::Mail::Why::UserUnknown;

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
# Regular expressions of 'User Unknown'
$Patterns = [
	qr(user unknown\z)o,
	qr(no such mailbox)o,
	qr(no such user here)o,
	qr(destination server rejected recipients)o,
	qr(recipient address rejected: user unknown in relay recipient table)o,
	qr(recipient address rejected: user unknown in local recipient table)o,
	qr(recipient address rejected: user unknown in virtual mailbox table)o,
	qr(recipient address rejected: user unknown in virtual alias table)o,
	qr(recipient address rejected: user .+ does not exist)o,
	qr(recipient address rejected: unknown user)o,
	qr(recipient address rejected: invalid user)o,
	qr(delivery error: dd this user doesn[']?t have a )o,
	qr(sorry, user unknown)o,
	qr(sorry, no mailbox here by that name)o,
	qr(mailbox not present)o,
	qr(requested action not taken: mailbox unavailable)o,
	qr(recipient rejected: mailbox would exceed maximum allowed storage)o,
	qr(recipient is not local)o,
	qr(unknown address)o,
	qr(unknown recipient)o,
	qr([#]5[.]1[.]1 bad address)o,
];

1;
__END__
