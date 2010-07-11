# $Id: Index.pm,v 1.7 2010/07/11 06:48:03 ak Exp $
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

	$self->tt_params(
		'datestring' => $date->ymd('-').' '.$date->hms(':'),
		'shortsummary' => $shortsumm,
	);

	return $self->tt_process($file);
}

1;
__END__
