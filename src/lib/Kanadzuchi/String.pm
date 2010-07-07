# $Id: String.pm,v 1.7 2010/07/07 11:21:38 ak Exp $
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
	my $class = shift() || return q();
	my $afrom = shift() || return q();
	my $arcpt = shift() || return q();

	# Format: STX(0x02) Sender-Address RS(0x1e) Recipient-Address ETC(0x03)
	return Digest::MD5::md5_hex( 
			sprintf( "\x02%s\x1e%s\x03", lc($afrom), lc($arcpt) ) );
}

sub is_validtoken
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|v|a|l|i|d|t|o|k|e|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Message token validation
	# @Param <str>	(String) Message token(MD5 hex digest)
	# @Return	0 = Invalid message token string
	#		1 = Valid message token string
	my $class = shift();
	my $token = shift() || return(0);

	return(1) if( $token =~ m{\A[0-9a-f]{32}\z} );
	return(0);
}

1;
__END__
