# $Id: Aggregate.pm,v 1.1 2010/07/07 01:04:03 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
   ##                                              ##          
  ####   #####  ##### #####   ####   #####  #### ###### ####   
 ##  ## ##  ## ##  ## ##  ## ##  ## ##  ##     ##  ##  ##  ##  
 ###### ##  ## ##  ## ##     ###### ##  ##  #####  ##  ######  
 ##  ##  #####  ##### ##     ##      ##### ##  ##  ##  ##      
 ##  ##     ##     ## ##      ####      ##  #####   ### ####   
        #####  #####                #####                      
package Kanadzuchi::UI::Web::Aggregate;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::Statistics::Stored::BdDR;
use Kanadzuchi::BdDR::BounceLogs::Masters;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub aggregate_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |a|g|g|r|e|g|a|t|e|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Aggregation
	my $self = shift();
	my $file = 'aggregate.html';
	my $bddr = $self->{'database'};

	my $statistics = undef();	# (Kanazuchi::Statistics::Stored::*) Statistics object
	my $tableclass = q();		# (String) Mastertable class
	my $samplesize = 0;		# (Integer) Sample size
	my $afrequency = 0;		# (Integer) Sum. of frequency
	my $aggregated = {};		# (Ref->Hash) Aggregated Data(Ref->Array)
	my $summarized = {};		# (Ref->Hash) Summarized Data(Ref->Array)
	my $columnname = q();		# (String) Column name
	my $validtable = q();		# (String) Table name for validation

	# Aggregate records in the Database
	$statistics =  new Kanadzuchi::Statistics::Stored::BdDR( 'handle' => $bddr->handle() );
	$tableclass =  q|Kanadzuchi::BdDR::BounceLogs::Masters::Table|;
	$columnname =  lc $self->param('pi_tablename');
	$columnname =~ s{s\z}{};

	$validtable = lc $tableclass->whichtable( lc substr($columnname,0,1) );
	if( ! $validtable || $validtable ne $columnname.'s' )
	{
		$self->e('invalidname', $self->param('pi_tablename') );
		$columnname = q();
	}

	$aggregated = $statistics->aggregate($columnname);
	map { $samplesize += $_->{'size'} } @{ $statistics->cache() } unless $samplesize;
	map { $_->{'ratio'} = sprintf( "%0.4f", $_->{'size'} / $samplesize ) } @$aggregated;
	map { $afrequency += $_->{'freq'} } @{ $statistics->cache() } unless $afrequency;

	# Calculate descriptive statistics
	foreach my $x ( 'size', 'freq' )
	{
		$statistics->sample( [ map { $_->{$x} } @{ $statistics->cache() } ] );
		$statistics->rounding(3);
		$summarized->{$x}->{'sum'} = sprintf("%0.2f", $statistics->sum() );
		$summarized->{$x}->{'min'} = sprintf("%0.2f", $statistics->min() );
		$summarized->{$x}->{'max'} = sprintf("%0.2f", $statistics->max() );
		$summarized->{$x}->{'mean'} = sprintf("%0.2f", $statistics->mean() );
		$summarized->{$x}->{'stddev'} = sprintf("%0.2f", $statistics->stddev() );
	}

	$self->tt_params(
		'columnname' => $columnname,
		'aggregated' => $aggregated,
		'summarized' => $summarized,
	);
	return $self->tt_process($file);
}

1;
__END__
