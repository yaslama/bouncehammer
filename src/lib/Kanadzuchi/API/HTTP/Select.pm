# $Id: Select.pm,v 1.1 2010/07/12 14:23:12 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::API::HTTP::
                                         
  #####        ###                 ##    
 ###      ####  ##   ####   #### ######  
  ###    ##  ## ##  ##  ## ##      ##    
   ###   ###### ##  ###### ##      ##    
    ###  ##     ##  ##     ##      ##    
 #####    #### ####  ####   ####    ###  
package Kanadzuchi::API::HTTP::Select;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::API::HTTP';

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub selectbytoken
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |s|e|l|e|c|t|b|y|t|o|k|e|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Send message token and return serialized result.
	# @Param	None
	my $self = shift();
	return q() unless length($self->param('token'));

	require Kanadzuchi::Mail::Stored::BdDR;
	require Kanadzuchi::BdDR::Page;
	require Kanadzuchi::Log;

	my $iterat = undef();
	my $zcilog = undef();
	my $string = q();
	my $wherec = { 'token' => lc $self->param('token') };
	my $pagina = Kanadzuchi::BdDR::Page->new( 'resultsperpage' => 1 );

	$iterat = Kanadzuchi::Mail::Stored::BdDR->searchandnew(
			$self->{'database'}->handle(), $wherec, $pagina );
	return q{} unless( $iterat->count() );

	# Create serialized data for the format JSON
	$zcilog = Kanadzuchi::Log->new();
	$zcilog->count( $iterat->count() );
	$zcilog->format( 'json' );
	$zcilog->entities( $iterat->all() );
	$string = $zcilog->dumper() || q();

	return $string;
}

1;
__END__
