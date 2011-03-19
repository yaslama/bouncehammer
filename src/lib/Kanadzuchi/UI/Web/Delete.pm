# $Id: Delete.pm,v 1.5.2.1 2011/03/19 09:41:42 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                       
 ####         ###          ##          
 ## ##   ####  ##   #### ###### ####   
 ##  ## ##  ## ##  ##  ##  ##  ##  ##  
 ##  ## ###### ##  ######  ##  ######  
 ## ##  ##     ##  ##      ##  ##      
 ####    #### ####  ####    ### ####   
package Kanadzuchi::UI::Web::Delete;

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
sub deletetherecord
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |d|e|l|e|t|e|t|h|e|r|e|c|o|r|d|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Execute DELETE(Ajax)
	# @Param	<None>
	# @Return
	my $self = shift();
	my $bddr = $self->{'database'};
	my $file = 'div-result.html';
	my $iter = undef();	# (K::Iterator) Iterator object
	my $cond = {};		# (Ref->Hash) WHERE Condition
	my $cgiq = $self->query();

	$cond = {
		'id' => $self->param('pi_id') || $cgiq->param('fe_id') || 0,
		'token' => $self->param('token') || $cgiq->param('fe_token') || q(),
	};

	return $self->e( 'invalidrecordid','ID: #'.$cond->{'id'} ) unless($cond->{'id'});
	$iter = Kanadzuchi::Mail::Stored::BdDR->searchandnew( $bddr->handle(), $cond );

	if( $iter->count() )
	{
		my $this = undef();	# (K::Mail::Stored::YAML) YAML object
		my $iitr = undef();	# (K::Iterator) Iterator for inner process
		my $data = [];		# (Ref->Array) Updated record
		my $cdat = new Kanadzuchi::BdDR::Cache();
		my $btab = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $bddr->handle() );
		my $zchi = $self->{'kanadzuchi'};

		$this = $iter->first();
		unless( $this->id() )
		{
			$zchi->historieque( 'err', 'mode=remove, stat=no such record');
			return $self->e( 'nosuchrecord' );
		}

		if( $this->remove( $btab, $cdat ) )
		{
			# syslog
			$zchi->historique( 'info',
				sprintf("record=1, removed=1, id=%s, token=%s, mode=remove, stat=ok", 
					( $cond->{'id'} ? $cond->{'id'} : '?' ),
					( $cond->{'token'} ? $cond->{'token'} : 'none' ) ));

			$data = $this->damn();
			$data->{'removed'}  = $this->updated->ymd().'('.$this->updated->wdayname().') '.$this->updated->hms();
			$data->{'bounced'}  = $this->bounced->ymd().'('.$this->bounced->wdayname().') '.$this->bounced->hms();
			$data->{'bounced'} .= ' '.$this->timezoneoffset() if( $this->timezoneoffset() );
			$self->tt_params( 'pv_bouncemessages' => [ $data ], 'pv_isremoved' => 1 );
			$self->tt_process( $file );

		}
		else
		{
			# Failed to remove
			return $self->e( 'failedtodelete', 'ID: #'.$cond->{'id'} );
		}
	}
	else
	{
		# Failed to update
		return $self->e( 'nosuchrecord' );
	}
}

1;
__END__
