# $Id: String.pm,v 1.4 2010/02/21 20:24:12 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::

  ##### ##            ##                 
 ###  ###### #####        #####   #####  
  ###   ##   ##  ##  ###  ##  ## ##  ##  
   ###  ##   ##       ##  ##  ## ##  ##  
    ### ##   ##       ##  ##  ##  #####  
 #####   ### ##      #### ##  ##     ##  
                                 #####   
package Kanadzuchi::String;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use Digest::MD5;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub token
{
	# +-+-+-+-+-+
	# |t|o|k|e|n|
	# +-+-+-+-+-+
	#
	# @Description	Create message token from addresser and recipient 
	# @Param	(String) Sender address
	# @Param	(String) Recipient address
	# @Return	(String) Message token(MD5 hex digest)
	#		(String) Blank/failed to create token
	# @See		http://en.wikipedia.org/wiki/ASCII
	#		http://search.cpan.org/~gaas/Digest-MD5-2.39/MD5.pm
	my $class = shift() || return(q{});
	my $afrom = shift() || return(q{});
	my $arcpt = shift() || return(q{});

	# Format: STX(0x02) Sender-Address RS(0x1e) Recipient-Address ETC(0x03)
	return( Digest::MD5::md5_hex( 
			sprintf( "\x02%s\x1e%s\x03", lc($afrom), lc($arcpt) ) ));
}

1;
__END__
