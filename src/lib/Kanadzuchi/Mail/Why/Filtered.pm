# $Id: Filtered.pm,v 1.8.2.1 2011/04/29 06:58:09 ak Exp $
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
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Filtered'
sub exemplaria
{
	my $class = shift();
	return [
		qr{user not found:},	# Filter on MAIL.RU
		qr{because the recipient is only accepting mail from specific email addresses},	# AOL Phoenix
		qr{due to extended inactivity new mail is not currently being accepted for this mailbox},
		qr{this account has been disabled or discontinued},
	];
}

1;
__END__
