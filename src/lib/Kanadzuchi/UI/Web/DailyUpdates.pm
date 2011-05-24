# $Id: DailyUpdates.pm,v 1.2.2.1 2011/05/24 02:43:18 ak Exp $
# -Id: Summary.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Summary.pm,v 1.1 2009/08/18 02:37:53 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                                                  
 ####           ##  ###         ##  ##             ##          ##                 
 ## ##  ####         ##  ##  ## ##  ##  #####      ##   #### ###### ####   #####  
 ##  ##    ##  ###   ##  ##  ## ##  ##  ##  ##  #####      ##  ##  ##  ## ##      
 ##  ## #####   ##   ##  ##  ## ##  ##  ##  ## ##  ##   #####  ##  ######  ####   
 ## ## ##  ##   ##   ##   ##### ##  ##  #####  ##  ##  ##  ##  ##  ##         ##  
 ####   #####  #### ####    ##   ####   ##      #####   #####   ### ####  #####   
                         ####           ##                                        
package Kanadzuchi::UI::Web::DailyUpdates;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::BdDR::DailyUpdates;
use Kanadzuchi::BdDR::Page;
use Kanadzuchi::Statistics;
use Kanadzuchi::Metadata;
use Kanadzuchi::Crypt;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $UIConfiguration = {
	'descend'	=> ( 1 << 0 ),	# Descending order
	'semilog'	=> ( 1 << 1 ),	# Use semi-Log graph
	'vestimated'	=> ( 1 << 2 ),	# Estimated number of bounces
	'vinserted'	=> ( 1 << 3 ),	# Measured value of inserted
	'vupdated'	=> ( 1 << 4 ),	# Measured value of updated
	'vskipped'	=> ( 1 << 5 ),	# Measured value of skipped
	'vfailed'	=> ( 1 << 6 ),	# Measured value of failed
	'vexecuted'	=> ( 1 << 7 ),	# Measured value of executed
	'minserted'	=> ( 1 << 8 ),	# Mean of inserted
	'mupdated'	=> ( 1 << 9 ),	# Mean of updated
	'mskipped'	=> ( 1 << 10 ),	# Mean of skipped
	'mfailed'	=> ( 1 << 11 ),	# Mean of failed
	'mexecuted'	=> ( 1 << 12 ),	# Mean of executed
};

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub dailyupdates
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |d|a|i|l|y|u|p|d|a|t|e|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Daily Updates on the Web
	my $self = shift();
	my $file = 'dailyupdates.html';
	my $bddr = $self->{'database'};
	my $drpp = { 'd' => 31, 'w' => 188, 'm' => 732, 'y' => 3660 };
	my $cgiq = $self->query();
	my $post = $cgiq->param('fe_havepostdata') || 0;

	my $iexplorer = $ENV{'HTTP_USER_AGENT'} =~ m{[(]compatible; MSIE \d+[.]\d+} ? 1 : 0;
	my $operation = 0;
	my $uioptions = {};

	my $pi_totals = $self->param('pi_totalsby') || $cgiq->param('fe_totalsby') || 'd,0';
	my($stotalsby,$descorder) = split( ',', $pi_totals );

	$descorder = defined $cgiq->param('fe_descend') ? 1 : defined $descorder ? $descorder : 0;
	$stotalsby = substr( $stotalsby, 0, 1 );
	$stotalsby = 'd' unless( $stotalsby =~ m{\A(?:d|w|m|y)} );

	$operation = $self->config2value( {} );
	$uioptions = $self->value2config( $operation );

	my $startpage = $self->param('pi_page') || 1;
	my $resultspp = $self->param('pi_rpp') || $drpp->{ $stotalsby };

	my $latestlog = new Kanadzuchi::BdDR::DailyUpdates::Data( 'handle' => $bddr->handle() );
	my $dailylogs = new Kanadzuchi::BdDR::DailyUpdates::Data( 'handle' => $bddr->handle() );
	my $wherecond = {};		# (Ref->Hash) WHERE Condition
	my $diterator = undef();	# (Kanadzuchi::Iterator)
	my $dusummary = undef();	# (Kanadzuchi::Statistics)
	my $summarizd = {};		# (Ref->Array) Summarized data
	my $paginated = undef();	# (Kanadzuchi::BdDR::Page)
	my $dailydata = [];		# (Ref->Array)
	my $thelatest = [];		# (Ref->Array)
	my $eachdatum = [];		# (Ref->Array) Each datum
	my $countofdu = $dailylogs->db->count( $wherecond );

	$dusummary = new Kanadzuchi::Statistics();
	$paginated = new Kanadzuchi::BdDR::Page(
				'resultsperpage' => $resultspp,
				'colnameorderby' => 'thedate',
				'descendorderby' => $descorder,
			);
	$paginated->set( $countofdu );
	$paginated->skip( $startpage );

	$dailylogs->totalsby( $stotalsby );
	$dailylogs->quaerit( $wherecond, $paginated, $stotalsby );
	$dailylogs->congregat() unless( $stotalsby eq 'd' );

	# Sort
	if( $stotalsby eq 'd' )
	{
		$dailydata = $dailylogs->data();
		map { $_->{'thetime'} = $_->{'thetime'}->epoch() } @$dailydata;
	}
	else
	{
		map { $_->{'thetime'} = $_->{'thetime'}->epoch() } @{ $dailylogs->subtotal() };
		$dailydata = Kanadzuchi::Metadata->mergesort( $dailylogs->subtotal(), 'thetime' );
		$dailydata = [reverse @$dailydata] if( $descorder );
	}

	SUMMARY: foreach my $x ( qw|inserted updated skipped failed executed estimated| )
	{
		$eachdatum = [ map { $_->{ $x } } @$dailydata ];
		$summarizd->{'sum'}->{ $x } = $dusummary->sum( $eachdatum );
		$summarizd->{'min'}->{ $x } = $dusummary->min( $eachdatum );
		$summarizd->{'mean'}->{ $x } = $dusummary->mean( $eachdatum );
		$summarizd->{'max'}->{ $x } = $dusummary->max( $eachdatum );
		$summarizd->{'stddev'}->{ $x } = $dusummary->sd( $eachdatum );

		foreach my $y ( qw|sum min mean max stddev| )
		{
			next() if( $summarizd->{ $y }->{ $x } eq 'NA' );
			$summarizd->{ $y }->{ $x } = sprintf("%0.2f",$summarizd->{ $y }->{ $x });
		}
	}

	# The latest; Today and yesterday
	THE_LATEST: {
		my $d = [ 
			{ 'name' => 'today', 'time' => Time::Piece->new() },
			{ 'name' => 'yesterday', 'time' => Time::Piece->new( time - 86400 ) },
		];
		my $p = Kanadzuchi::BdDR::Page->new( 'resultsperpage' => 2 );
		my $r = {};

		foreach my $x ( @$d )
		{
			$latestlog->quaerit( { 'thedate' => $x->{'time'}->ymd('-') }, $p, 'd' );
			$r = shift @{ $latestlog->data() };
			next() unless $r->{'thedate'};
			$r->{'name'} = $x->{'name'};
			push( @$thelatest, $r );
		}

		# Neither today's nor yesterday's record exists
		unless( scalar @$thelatest )
		{
			$p->resultsperpage(1);
			$p->descendorderby(1);
			$latestlog->quaerit( {}, $p, 'd' );
			$r = shift @{ $latestlog->data() };

			if( $r->{'thedate'} )
			{
				$r->{'name'} = 'latest';
				push( @$thelatest, $r );
			}
		}
	}

	DISPLAYING: foreach my $time ( @$dailydata, @$thelatest )
	{
		$time->{'modifieddate'} = $time->{'modified'}->ymd('-');
		$time->{'modifiedtime'} = $time->{'modified'}->hms(':');
	}

	# No data
	$self->e( 'nosuchrecord' ) unless $countofdu;

	$self->tt_params(
		'pv_contentsname' => 'dailyupdates',
		'pv_pagination' => $paginated,
		'pv_iexplorer' => $iexplorer,
		'pv_dailydata' => $dailydata,
		'pv_thelatest' => $thelatest,
		'pv_uioptions' => { 
			'serialized' => ${ Kanadzuchi::Metadata->to_string($uioptions,1) },
			'config' => $uioptions,
			'value' => $operation, },
		'pv_totalsby' => $dailylogs->totalsby(),
		'pv_summary' => $summarizd,
	);
	return $self->tt_process($file);
}

sub value2config
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |v|a|l|u|e|2|c|o|n|f|i|g|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get UI Configurations for DailyUpdates
	# @Param [int]	(Integer) Option value
	# @Return	(Ref->Hash) UI Configuration
	#
	my $self = shift();
	my $optv = shift() || $self->param('pi_uioption') || 0;
	my $cgiq = $self->query() || q();
	my $defs = $UIConfiguration;
	my $conf = {};
	my $sent = q();

	if( ! $cgiq || ! $optv || $optv !~ m{\A\d+\z} )
	{
		map { $conf->{$_} = 1 } ( qw|vestimated vinserted vupdated vskipped| );
		return $conf;
	}

	$sent = $cgiq->param('fe_graph') || q();
	if( $sent eq 'semilog' || $optv & $defs->{'semilog'} )
	{
		$conf->{'semilog'} = 1;
	}

	foreach my $c ( keys %$defs )
	{
		next() if( $c eq 'semilog' );
		$sent = $cgiq->param('fe_'.$c) || q();
		$conf->{ $c } = 1 if( $sent eq 'on' || $optv & $defs->{ $c } );
	}

	return $conf;
}

sub config2value
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |c|o|n|f|i|g|2|v|a|l|u|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get the config value for DailyUpdates
	# @Param <ref>	(Ref->Hash) Configuration
	# @Return	(Integer) Value
	#
	my $self = shift();
	my $conf = shift();
	my $cgiq = $self->query() || q();
	my $optv = 0;
	my $sent = q();
	my $defs = $UIConfiguration;

	if( ! $cgiq || ref($conf) ne q|HASH| )
	{
		map { $optv |= $defs->{$_} } (qw|vestimated vinserted vupdated vskipped| );
		return $optv;
	}

	$sent = $cgiq->param('fe_graph') || q();
	if( $conf->{'semilog'} || $sent eq 'semilog' )
	{
		$optv |= $defs->{'semilog'};
	}

	foreach my $c ( keys %$defs )
	{
		next() if( $c eq 'semilog' );
		$sent = $cgiq->param('fe_'.$c) || q();
		$optv |= $defs->{ $c } if( $conf->{ $c } || $sent );
	}

	return $optv;
}

1;
__END__
