# $Id: Index.pm,v 1.9 2010/08/29 22:26:37 ak Exp $
# -Id: Index.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Index.pm,v 1.3 2009/08/13 07:13:57 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                     
  ####             ##                
   ##   #####      ##   #### ##  ##  
   ##   ##  ##  #####  ##  ## ####   
   ##   ##  ## ##  ##  ######  ##    
   ##   ##  ## ##  ##  ##     ####   
  ####  ##  ##  #####   #### ##  ##  
package Kanadzuchi::UI::Web::Index;
use base 'Kanadzuchi::UI::Web';
use strict;
use warnings;
use Time::Piece;
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::BdDR::BounceLogs::Masters;
use Kanadzuchi::BdDR::DailyUpdates;
use Kanadzuchi::BdDR::Page;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub putindexpage
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|u|t|i|n|d|e|x|p|a|g|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Index page, WebUI Dashboard
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'index.html';
	my $bddr = $self->{'database'};
	my $date = localtime;

	my $bouncelog = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $bddr->handle() );
	my $shortsumm = { 'bouncelogs' => $bouncelog->count() };

	foreach my $mt ( 'a', 's', 'd' )
	{
		my $mtobj = new Kanadzuchi::BdDR::BounceLogs::Masters::Table( 
					'alias' => $mt, 'handle' => $bddr->handle() );
		$shortsumm->{ lc $mtobj->alias() } = $mtobj->count();
	}

	# The latest; Today and yesterday
	my $dailylogs = new Kanadzuchi::BdDR::DailyUpdates::Data( 'handle' => $bddr->handle() );
	my $thelatest = [];

	THE_LATEST: {
		my $days = [ 
			{ 'name' => 'today', 'time' => Time::Piece->new() },
			{ 'name' => 'yesterday', 'time' => Time::Piece->new( time - 86400 ) },
		];
		my $page = Kanadzuchi::BdDR::Page->new( 'resultsperpage' => 2 );
		my $recs = {};
		my $flag = 0;

		foreach my $x ( @$days )
		{
			$dailylogs->quaerit( { 'thedate' => $x->{'time'}->ymd('-') }, $page, 'd' );
			$recs = shift @{ $dailylogs->data() }
				|| {	'thedate' => $x->{'time'}->ymd, 
					'estimated' => -1,
					'inserted' => -1, 
					'updated' => -1, };
			$recs->{'name'} = $x->{'name'};
			$recs->{'dayofweek'} = lc $x->{'time'}->day();
			$recs->{'datestring'} = $x->{'time'}->mon().'/'.$x->{'time'}->mday();
			$recs->{'modifieddate'} = ref $recs->{'modified'} eq q|Time::Piece|
						? $recs->{'modified'}->ymd('/') : '?';
			$recs->{'modifiedtime'} = ref $recs->{'modified'} eq q|Time::Piece| 
						? $recs->{'modified'}->hms(':') : '?';
			push( @$thelatest, $recs );
			$flag += 1 if( $recs->{'estimated'} > -1 );
		}

		if( $flag == 0 )
		{
			$page->resultsperpage(1);
			$page->descendorderby(1);
			$dailylogs->quaerit( {}, $page, 'd' );
			$recs = shift @{ $dailylogs->data() };

			if( $recs->{'thedate'} )
			{
				my $t = Time::Piece->strptime( $recs->{'thedate'}, "%Y-%m-%d");
				$recs->{'name'} = 'latest';
				$recs->{'dayofweek'} = lc $t->day();
				$recs->{'datestring'} = $t->mon().'/'.$t->mday();
				$recs->{'modifieddate'} = ref $recs->{'modified'} eq q|Time::Piece|
							? $recs->{'modified'}->ymd('/') : '?';
				$recs->{'modifiedtime'} = ref $recs->{'modified'} eq q|Time::Piece|
							? $recs->{'modified'}->hms(':') : '?';
				push( @$thelatest, $recs );
			}
		}
	}

	$self->tt_params(
		'pv_datestring' => $date->ymd('-').' '.$date->hms(':'),
		'pv_shortsummary' => $shortsumm,
		'pv_dailyupdates' => $thelatest,
	);

	return $self->tt_process($file);
}

1;
__END__
