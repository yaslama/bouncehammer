# $Id: Filtered.pm,v 1.6 2010/06/16 12:57:49 ak Exp $
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
# Regular expressions of 'filtered'
sub exemplaria
{
	my $class = shift();
	return [
		qr(the message was rejected because it contains prohibited virus or spam content),
		qr(sorry, your remotehost looks suspiciously like spammer),
		qr(message filtered. please see the faqs section on spam),
		qr(blocked by policy: no spam please),
		qr(message rejected due to suspected spam content),
		qr(message filtered),
		qr(domain of sender address .+ does not exist),
	];
}

1;
__END__
