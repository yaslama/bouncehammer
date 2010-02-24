# $Id: RFC2606.pm,v 1.1 2010/02/22 20:10:15 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                  
 #####  ###### ####   ####   ####   ####   ####   
 ##  ## ##    ##  ## ##  ## ##     ##  ## ##      
 ##  ## ####  ##         ## #####  ## ### #####   
 #####  ##    ##      ####  ##  ## ### ## ##  ##  
 ## ##  ##    ##  ## ##     ##  ## ##  ## ##  ##  
 ##  ## ##     ####  ######  ####   ####   ####   
                                                  
package Kanadzuchi::RFC2606;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;

# See http://www.ietf.org/rfc/rfc2606.txt
#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub is_rfc2606
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|r|f|c|2|6|0|6|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether domain part is Reserved TLD or not
	# @Param <str>	(String) Domain part
	# @Return	(Integer) 1 = is RFC2606 Reserved TLD
	#		(Integer) 0 = is not
	my $class = shift();
	my $dpart = shift() || return(0);

	return(1) if( $dpart =~ m{[.](?:test|example|invalid|localhost)\z} );
	return(1) if( $dpart =~ m{example[.](?:com|net|org)\z} );
	return(0);
}

sub is_reserved
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|r|e|s|e|r|v|e|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether domain part is Reserved or not
	# @Param <str>	(String) Domain part
	# @Return	(Integer) 1 = is Reserved TLD
	#		(Integer) 0 = is not
	my $class = shift();
	my $dpart = shift() || return(0);

	return(1) if( $class->is_rfc2606($dpart) );
	return(1) if( $dpart =~ m{example[.]jp\z} );
	return(1) if( $dpart =~ m{example[.](?:ac|ad|co|ed|go|gr|lg|ne|or)[.]jp\z} );
	return(0);
}

1;
__END__
