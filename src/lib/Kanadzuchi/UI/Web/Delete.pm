# $Id: Delete.pm,v 1.3 2010/06/28 13:18:31 ak Exp $
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
sub delete_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |d|e|l|e|t|e|_|o|n|t|h|e|w|e|b|
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

	$cond = {
		'id' => $self->param('pi_id') || $self->query->param('id') || 0,
		'token' => $self->param('token') || $self->query->param('token') || q(),
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

		$this = $iter->first();
		return $self->e( 'nosuchrecord' ) unless( $this->id() );
		if( $this->remove( $btab, $cdat ) )
		{
			$data = $this->damn();
			$data->{'removed'}  = $this->updated->ymd().'('.$this->updated->wdayname().') '.$this->updated->hms();
			$data->{'bounced'}  = $this->bounced->ymd().'('.$this->bounced->wdayname().') '.$this->bounced->hms();
			$data->{'bounced'} .= ' '.$this->timezoneoffset() if( $this->timezoneoffset() );
			$self->tt_params( 'bouncemessages' => [ $data ], 'isremoved' => 1 );
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
