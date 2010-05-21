# $Id: Update.pm,v 1.9 2010/05/19 18:25:10 ak Exp $
# -Id: Update.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Update.pm,v 1.6 2009/08/13 07:13:58 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                            
 ##  ##             ##          ##          
 ##  ##  #####      ##   #### ###### ####   
 ##  ##  ##  ##  #####      ##  ##  ##  ##  
 ##  ##  ##  ## ##  ##   #####  ##  ######  
 ##  ##  #####  ##  ##  ##  ##  ##  ##      
  ####   ##      #####   #####   ### ####   
         ##                                 
package Kanadzuchi::UI::Web::Update;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::Mail::Stored::BdDR;
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::BdDR::Cache;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub update_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |u|p|d|a|t|e|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Execute update(Ajax)
	# @Param	<None>
	# @Return
	my $self = shift();
	my $bddr = $self->{'database'};
	my $file = 'div-result.'.$self->{'language'}.'.html';
	my $iter = undef();	# (K::Iterator) Iterator object
	my $cond = {};		# (Ref->Hash) WHERE Condition

	$cond = {
		'id' => $self->param('pi_id') || $self->query->param('id') || 0,
		'token' => $self->param('token') || $self->query->param('token') || q(),
	};
	return('Invalid record ID') unless($cond->{'id'});
	$iter = Kanadzuchi::Mail::Stored::BdDR->searchandnew( $bddr->handle(), $cond );

	if( $iter->count() )
	{
		my $this = undef();	# (K::Mail::Stored::YAML) YAML object
		my $that = undef();	# (K::Mail::Stored::BdDR) BdDR object
		my $iitr = undef();	# (K::Iterator) Iterator for inner process
		my $data = [];		# (Ref->Array) Updated record
		my $cdat = new Kanadzuchi::BdDR::Cache();
		my $btab = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $bddr->handle() );

		while( $this = $iter->next() )
		{
			$this->hostgroup( $self->query->param('hostgroup') );
			$this->reason( $self->query->param('reason') );
			$this->updated( Time::Piece->new() );
			last();
		}

		if( $this->update( $btab, $cdat ) )
		{
			$data = $this->damn();
			$data->{'updated'}  = $this->updated->ymd().'('.$this->updated->wdayname().') '.$this->updated->hms();
			$data->{'bounced'}  = $this->bounced->ymd().'('.$this->bounced->wdayname().') '.$this->bounced->hms();
			$data->{'bounced'} .= ' '.$this->timezoneoffset() if( $this->timezoneoffset() );

			$self->tt_params( 'bouncemessages' => [ $data ], 'isupdated' => 1 );
			$self->tt_process( $file );
		}
		else
		{
			# Failed to update
			return('Failed');
		}
	}
	else
	{
		# Failed to update
		return('No such record in the database');
	}
}

1;
__END__
