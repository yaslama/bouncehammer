# $Id: Filtered.pm,v 1.8.2.2 2011/06/25 10:50:31 ak Exp $
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
		qr{because the recipient is only accepting mail from specific email addresses},	# AOL Phoenix
		qr{due to extended inactivity new mail is not currently being accepted for this mailbox},
		qr{http://postmaster[.]facebook[.]com/.+refused due to recipient preferences},	# Facebook
		qr{this account has been disabled or discontinued},
		qr{user not found:},	# Filter on MAIL.RU
	];
}

1;
__END__
