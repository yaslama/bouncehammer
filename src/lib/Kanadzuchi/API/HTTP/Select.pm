# $Id: Select.pm,v 1.3 2010/07/12 17:55:00 ak Exp $
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
use Kanadzuchi::Mail::Stored::BdDR;
use Kanadzuchi::BdDR::Page;
use Kanadzuchi::String;
use Kanadzuchi::Log;


#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub select
{
	# +-+-+-+-+-+-+
	# |s|e|l|e|c|t|
	# +-+-+-+-+-+-+
	#
	# @Description	Send message token and return serialized result.
	# @Param	None
	my $self = shift();
	my $bddr = $self->{'database'};

	my $iterator = undef();	# (Kanadzuchi::Iterator)
	my $knlogger = undef();	# (Kanadzuchi::Log)
	my $paginatd = undef();	# (Kanadzuchi::BdDR::Page)
	my $jsondata = q();	# (String) Serialized data/JSON
	my $wherecnd = {};	# (Ref->Hash) WHERE Condition
	my $whichcol = q();	# (String) column name: id or token
	my $identify = $self->param('pi_identifier') || return q();

	if( $identify =~ m{\A\d+\z} )
	{
		$whichcol = 'id';
		$identify = int $identify;
	}
	elsif( Kanadzuchi::String->is_validtoken(lc $identify) )
	{
		$whichcol = 'token';
		$identify = lc $identify;
	}
	else
	{
		return q();
	}

	$wherecnd->{$whichcol} = $identify;
	$paginatd = new Kanadzuchi::BdDR::Page( 'resultsperpage' => 1 );
	$iterator = Kanadzuchi::Mail::Stored::BdDR->searchandnew(
				$bddr->handle(), $wherecnd, $paginatd );
	return q() unless( $iterator->count() );

	# Create serialized data for the format JSON
	$knlogger = new Kanadzuchi::Log(
				'count' => $iterator->count(),
				'format' => 'json',
				'entities' => $iterator->all() );
	$jsondata = $knlogger->dumper() || q();

	return $jsondata;
}

1;
__END__
