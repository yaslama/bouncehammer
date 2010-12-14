# $Id: Rejected.pm,v 1.2 2010/12/12 06:19:35 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                       
 #####           ##                 ##             ##  
 ##  ##  ####         ####   #### ###### ####      ##  
 ##  ## ##  ##   ##  ##  ## ##      ##  ##  ##  #####  
 #####  ######   ##  ###### ##      ##  ###### ##  ##  
 ## ##  ##       ##  ##     ##      ##  ##     ##  ##  
 ##  ##  ####    ##   ####   ####    ### ####   #####  
              ####                                     
package Kanadzuchi::Mail::Why::Rejected;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Rejected'
sub exemplaria
{
	my $class = shift();
	return [ 
		qr{dns lookup failure: .+ try again later},
		qr{domain does not exist:},
		qr{domain of sender address .+ does not exist},
		qr{invalid domain, see [<]url:.+[>]},
		qr{mail server at .+ is blocked},
		qr{mx records for .+ violate section .+},
		qr{rfc 1035 violation: recursive cname records for},
		qr{sender rejected},
		qr{sorry, your remotehost looks suspiciously like spammer},
	];
}

1;
__END__
