# $Id: Summary.pm,v 1.6 2010/03/01 23:42:12 ak Exp $
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

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub summary_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |s|u|m|m|a|r|y|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Draw summary in HTML
	my $self = shift();
	my $file = q(summary.).$self->{'language'}.q(.html);

	my $robj = 0;	# Require object as a return value
	my $pgcf = {
		'currentpagenum' => 1,
		'resultsperpage' => 1,
		'colnameorderby' => q(id),
	};

	my $tableconf = $self->{'settings'}->{'database'}->{'table'};
	my $tablesumm = {};

	# Count the number of records in BounceLogs table
	# Receive 1 result for counting
	require Kanadzuchi::Mail::Stored::RDB;
	Kanadzuchi::Mail::Stored::RDB->searchandnew( $self->{'database'}, {}, \$pgcf, $robj );

	$tablesumm->{'bouncelogs'} = {
		'screenname'	=> q(BounceLogs),
		'totalentries'	=> $pgcf->{'totalentries'},
		'capacity'	=> $tableconf->{'bouncelogs'}->{'maxrecords'}
			? sprintf("%0.4f", $pgcf->{'totalentries'} / $tableconf->{'bouncelogs'}->{'maxrecords'})
			: 0,
	};

	# Count the number of records in SenderDoamins table
	require Kanadzuchi::RDB::Table::SenderDomains;
	my $tabsd = {};
	$tabsd->{'myname'} = q(senderdomains);
	$tabsd->{'screen'} = q(SenderDomains);
	$tabsd->{'object'} = new Kanadzuchi::RDB::Table::SenderDomains();
	$tabsd->{'arrayr'} = $tabsd->{'object'}->select( $self->{'database'}, q() );

	# Count the number of records in Destinations table
	require Kanadzuchi::RDB::Table::Destinations;
	my $tabde = {};
	$tabde->{'myname'} = q(destinations);
	$tabde->{'screen'} = ucfirst($tabde->{'myname'});
	$tabde->{'object'} = new Kanadzuchi::RDB::Table::Destinations();
	$tabde->{'arrayr'} = $tabde->{'object'}->select( $self->{'database'}, q() );

	foreach my $_tab ( $tabsd, $tabde )
	{
		my $__cnt = scalar(@{ $_tab->{'arrayr'} });
		$tablesumm->{ $_tab->{'myname'} } = {
			'screenname'	=> $_tab->{'screen'},
			'totalentries'	=> $__cnt,
			'capacity'	=> $tableconf->{ $_tab->{'myname'} }->{'maxrecords'}
				? sprintf( "%0.4f", $__cnt / $tableconf->{ $_tab->{'myname'} }->{'maxrecords'} )
				: 0,
		}
	}

	$self->tt_params(
		'tableconf' => $tableconf,
		'tablesumm' => $tablesumm,
	);
	$self->tt_process($file);
}

1;
__END__
