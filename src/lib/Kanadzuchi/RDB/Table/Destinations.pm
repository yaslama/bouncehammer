# $Id: Destinations.pm,v 1.5 2010/03/01 23:42:08 ak Exp $
# -Id: Destinations.pm,v 1.1 2009/08/29 09:07:37 ak Exp -
# -Id: Destinations.pm,v 1.2 2009/04/29 10:13:00 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Table::
                                                                                     
 ####                   ##      ##                 ##      ##                        
 ## ##   ####   ##### ######        #####   #### ######         ####  #####   #####  
 ##  ## ##  ## ##       ##     ###  ##  ##     ##  ##     ###  ##  ## ##  ## ##      
 ##  ## ######  ####    ##      ##  ##  ##  #####  ##      ##  ##  ## ##  ##  ####   
 ## ##  ##         ##   ##      ##  ##  ## ##  ##  ##      ##  ##  ## ##  ##     ##  
 ####    ####  #####     ###   #### ##  ##  #####   ###   ####  ####  ##  ## #####   
package Kanadzuchi::RDB::Table::Destinations;

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
	# @Description	Validate reason
	# @Param	<None>
	# @Return	(Integer) 1 = Valid
	#		(Integer) 0 = Invalid
	my $self = shift();
	return(0) if( length($self->{name}) == 0 );	# Name is empty
	return(0) if( length($self->{name}) > 255 );	# Too long

	# Check the domain name
	return(1) if( Kanadzuchi::RFC2822->is_domainpart($self->{'name'}) );
	return(0);	# NG, does not seem to a domain name
}

1;
__END__
