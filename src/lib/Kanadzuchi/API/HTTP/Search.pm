# $Id: Search.pm,v 1.3 2010/10/05 11:17:15 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::API::HTTP::
                                           
  #####                            ##      
 ###      ####  ####  #####   #### ##      
  ###    ##  ##    ## ##  ## ##    #####   
   ###   ###### ##### ##     ##    ##  ##  
    ###  ##    ##  ## ##     ##    ##  ##  
 #####    ####  ##### ##      #### ##  ##  
package Kanadzuchi::API::HTTP::Search;

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
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::Address;
use Kanadzuchi::Log;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub search
{
	# +-+-+-+-+-+-+
	# |s|e|a|r|c|h|
	# +-+-+-+-+-+-+
	#
	# @Description	Send query and receive results as JSON format
	# @Param	<None>
	# @Return
	my $self = shift();
	my $bddr = $self->{'database'};

	my $validcols = [];	# (Ref->Array) Valid column names
	my $wherecond = {};	# (Ref->Hash) WHERE Condition for sending query
	my $dbrecords = 0;	# (Integer) The number of records in the db
	my $paginated = new Kanadzuchi::BdDR::Page();
	my $bouncelog = new Kanadzuchi::BdDR::BounceLogs::Table('handle' => $bddr->handle());

	my $thecolumn = $self->param('pi_column') || q();
	my $thestring = $self->param('pi_string') || q();

	my $recordsin = 0;		# (Integer) The number of records in the DB
	my $serializd = q();		# (String) Serialized/json
	my $cgiqueryp = $self->query();

	# Build column names
	push @$validcols, @{ $bouncelog->fields->{'join'} };
	push @$validcols, qw(recipient hostgroup reason token id);

	# Experimental implementation except the column 'recipient'
	return unless grep { lc $thecolumn eq $_ } @$validcols;
	return q() unless( $thestring );

	if( $thecolumn eq 'recipient' || $thecolumn eq 'addresser' )
	{
		$wherecond->{$thecolumn} = Kanadzuchi::Address->canonify( lc $thestring );
	}
	else
	{
		$wherecond->{$thecolumn} = lc $thestring;
	}

	$recordsin = $bouncelog->count( $wherecond, $paginated );

	return q() unless( $recordsin );

	$paginated->resultsperpage( 100 );
	$paginated->set($recordsin);
	$paginated->colnameorderby( 'id' );
	$paginated->descendorderby( 0 );

	# Search and Print
	MAKE_DATA_AS_JSON: while(1)
	{
		my $dataarray = [];		# (Ref->Array) Dumped results
		my $xiterator = Kanadzuchi::Mail::Stored::BdDR->searchandnew( 
						$bddr->handle(), $wherecond, $paginated);

		DUMP_EACH_OBJECT: while( my $obj = $xiterator->next() )
		{
			push( @$dataarray, $obj );
		}

		# Create K::Log object and dump
		my $kanazclog = new Kanadzuchi::Log(
					'count' => scalar @$dataarray,
					'entities' => $dataarray,
					'format' => 'json' );

		$serializd .= $kanazclog->dumper() || q();
		last() unless $paginated->hasnext();
		$paginated->next();
	}

	return $serializd;
}

1;
__END__
