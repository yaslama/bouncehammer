# $Id: Providers.pm,v 1.3 2010/02/21 20:42:02 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Table::
                                                                 
 #####                          ##     ##                        
 ##  ## #####   ####  ##  ##           ##   ####  #####   #####  
 ##  ## ##  ## ##  ## ##  ##   ###  #####  ##  ## ##  ## ##      
 #####  ##     ##  ## ##  ##    ## ##  ##  ###### ##      ####   
 ##     ##     ##  ##  ####     ## ##  ##  ##     ##         ##  
 ##     ##      ####    ##     #### #####   ####  ##     #####   
package Kanadzuchi::RDB::Table::Providers;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::RDB::Table';
use strict;
use warnings;
use Kanadzuchi::RFC2822;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub validation
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |v|a|l|i|d|a|t|i|o|n|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Validate provider name
	# @Param	<None>
	# @Return	(Integer) 1 = Valid
	#		(Integer) 0 = Invalid
	my $self = shift();
	return(0) if( ! defined($self->{'name'}) );
	return(0) if( length($self->{'name'}) == 0 );	# Name is empty
	return(0) if( length($self->{'name'}) > 63 );	# Too long
	return(1);
}

1;
__END__
