# $Id: SecurityError.pm,v 1.2.2.1 2011/06/25 10:50:31 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                       
  #####                             ## ##          ######                              
 ###     ####   #### ##  ## #####    ###### ##  ## ##     #####  #####   ####  #####   
  ###   ##  ## ##    ##  ## ##  ## ### ##   ##  ## ####   ##  ## ##  ## ##  ## ##  ##  
   ###  ###### ##    ##  ## ##      ## ##   ##  ## ##     ##     ##     ##  ## ##      
    ### ##     ##    ##  ## ##      ## ##    ##### ##     ##     ##     ##  ## ##      
 #####   ####   ####  ##### ##     #### ###    ##  ###### ##     ##      ####  ##      
                                            ####                                       
package Kanadzuchi::Mail::Why::SecurityError;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Security Error'
sub exemplaria
{
	my $class = shift();
	return [ 
		qr{blocked by spamAssassin},		# rejected by SpamAssassin
		qr{mail appears to be unsolicited},	# rejected due to spam
		qr{rejected due to spam content},	# rejected due to spam
		qr{sorry, that domain isn'?t in my list of allowed rcpthosts},
		qr{sorry, your don'?t authenticate or the domain isn'?t in my list of allowed rcpthosts},
		qr{spambouncer identified sPAM},	# SpamBouncer identified SPAM
		qr{the message was rejected because it contains prohibited virus or spam content},
	];
}

1;
__END__
