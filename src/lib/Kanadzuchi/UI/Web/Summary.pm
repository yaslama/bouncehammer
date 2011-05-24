# $Id: Summary.pm,v 1.15.2.1 2011/05/24 02:43:18 ak Exp $
# -Id: Summary.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Summary.pm,v 1.1 2009/08/18 02:37:53 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                    
  #####                                             
 ###     ##  ## ##  ## ##  ##  ####  #####  ##  ##  
  ###    ##  ## ###### ######     ## ##  ## ##  ##  
   ###   ##  ## ###### ######  ##### ##     ##  ##  
    ###  ##  ## ##  ## ##  ## ##  ## ##      #####  
 #####    ##### ##  ## ##  ##  ##### ##        ##   
                                            ####    
package Kanadzuchi::UI::Web::Summary;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::BdDR::BounceLogs::Masters;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub datasummary
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |d|a|t|a|s|u|m|m|a|r|y|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Data summary page
	my $self = shift();
	my $file = 'summary.html';
	my $bddr = $self->{'database'};

	my $bouncelog = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $bddr->handle() );
	my $numofrecs = $bouncelog->count();
	my $tableconf = $self->{'webconfig'}->{'database'}->{'table'};
	my $maxrecord = $tableconf->{'bouncelogs'}->{'maxrecords'};
	my $tablesumm = {};

	$tablesumm->{'bouncelogs'} = {
		'screenname'	=> 'BounceLogs',
		'totalentries'	=> $numofrecs,
		'capacity'	=> $maxrecord ? sprintf("%0.4f", $numofrecs / $maxrecord ) : 0,
	};

	foreach my $mt ( 'a', 's', 'd' )
	{
		my $mtobj = new Kanadzuchi::BdDR::BounceLogs::Masters::Table( 
					'alias' => $mt, 'handle' => $bddr->handle() );
		my $tname = lc $mtobj->alias();
		my $count = $mtobj->count();
		my $maxrr = $tableconf->{$tname}->{'maxrecords'};
		my $ratio = $maxrr ? sprintf( "%0.4f", $count / $maxrr ) : 0;

		map { $tableconf->{ $tname }->{$_} = 0 
			unless defined $tableconf->{$tname}->{$_} } ( qw|readonly maxrecords| );
		$tablesumm->{ $tname } = {
				'capacity' => $ratio,
				'screenname' => $mtobj->alias(),
				'totalentries' => $count };

	}

	$self->tt_params(
		'pv_tableconf' => $tableconf,
		'pv_tablesumm' => $tablesumm,
	);
	return $self->tt_process($file);
}

1;
__END__
