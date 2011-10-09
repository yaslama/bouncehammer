# $Id: NotAccept.pm,v 1.1.2.2 2011/10/08 13:49:14 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                            
 ##  ##          ##     ##                            ##    
 ### ##   #### ######  ####   #### #### ####  ##### ######  
 ######  ##  ##  ##   ##  ## ##   ##   ##  ## ##  ##  ##    
 ## ###  ##  ##  ##   ###### ##   ##   ###### ##  ##  ##    
 ##  ##  ##  ##  ##   ##  ## ##   ##   ##     #####   ##    
 ##  ##   ####    ### ##  ##  #### #### ####  ##       ###  
                                              ##            
package Kanadzuchi::Mail::Why::NotAccept;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Not Accept'
sub exemplaria
{
	my $class = shift();
	return [
		# Rejected due to IP address or hostname.
		qr{dns lookup failure: .+ try again later},
		qr{domain does not exist:},
		qr{domain of sender address .+ does not exist},
		qr{http://www[.]spamhaus[.]org},
		qr{invalid domain, see [<]url:.+[>]},
		qr{mail server at .+ is blocked},
		qr{mx records for .+ violate section .+},
		qr{name service error for },	# Malformed MX RR or host not found
		qr{rfc 1035 violation: recursive cname records for},
		qr{sorry, your remotehost looks suspiciously like spammer},
		qr{we do not accept mail from hosts with dynamic ip or generic dns ptr-records}, # MAIL.RU
		qr{we do not accept mail from dynamic ips}, # MAIL.RU
	];
}

1;
__END__
