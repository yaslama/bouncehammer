# $Id: Index.pm,v 1.8 2010/08/28 17:22:09 ak Exp $
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
		my $d = [ 
			{ 'name' => 'today', 'time' => Time::Piece->new() },
			{ 'name' => 'yesterday', 'time' => Time::Piece->new( time - 86400 ) },
		];
		my $p = Kanadzuchi::BdDR::Page->new( 'resultsperpage' => 2 );
		my $r = {};
		my $e = 0;

		foreach my $x ( @$d )
		{
			$dailylogs->quaerit( { 'thedate' => $x->{'time'}->ymd('-') }, $p, 'd' );
			$r = shift @{ $dailylogs->data() }
				|| {	'thedate' => $x->{'time'}->ymd, 
					'estimated' => -1,
					'inserted' => -1, 
					'updated' => -1, };
			$r->{'name'} = $x->{'name'};
			$r->{'dayofweek'} = lc $x->{'time'}->day();
			$r->{'datestring'} = $x->{'time'}->mon().'/'.$x->{'time'}->mday();
			$r->{'modifieddate'} = ref $r->{'modified'} eq q|Time::Piece|
						? $r->{'modified'}->ymd('/') : '?';
			$r->{'modifiedtime'} = ref $r->{'modified'} eq q|Time::Piece| 
						? $r->{'modified'}->hms(':') : '?';
			push( @$thelatest, $r );
		}

		unless( scalar @{ $dailylogs->data() } )
		{
			$p->resultsperpage(1);
			$p->descendorderby(1);
			$dailylogs->quaerit( {}, $p, 'd' );
			$r = shift @{ $dailylogs->data() };

			if( $r->{'thedate'} )
			{
				my $t = Time::Piece->strptime( $r->{'thedate'}, "%Y-%m-%d");
				$r->{'name'} = 'latest';
				$r->{'dayofweek'} = lc $t->day();
				$r->{'datestring'} = $t->mon().'/'.$t->mday();
				$r->{'modifieddate'} = ref $r->{'modified'} eq q|Time::Piece|
							? $r->{'modified'}->ymd('/') : '?';
				$r->{'modifiedtime'} = ref $r->{'modified'} eq q|Time::Piece|
							? $r->{'modified'}->hms(':') : '?';
				push( @$thelatest, $r );
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
