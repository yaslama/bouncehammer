# $Id: Update.pm,v 1.15.2.1 2011/03/19 09:41:42 ak Exp $
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
sub updatetherecord
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |u|p|d|a|t|e|t|h|e|r|e|c|o|r|d|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Update the record on the DB.BounceLogs
	# @Param	<None>
	# @Return
	my $self = shift();
	my $bddr = $self->{'database'};
	my $file = 'div-result.html';
	my $iter = undef();	# (K::Iterator) Iterator object
	my $cond = {};		# (Ref->Hash) WHERE Condition
	my $isro = $self->{'webconfig'}->{'database'}->{'table'}->{'bouncelogs'}->{'readonly'};
	my $cgiq = $self->query();

	$cond = {
		'id' => $self->param('pi_id') || $cgiq->param('fe_id') || 0,
		'token' => $self->param('token') || $cgiq->param('fe_token') || q(),
	};
	return $self->e('invalidrecordid', 'ID: #'.$cond->{'id'} ) unless $cond->{'id'};
	$iter = Kanadzuchi::Mail::Stored::BdDR->searchandnew( $bddr->handle(), $cond );

	if( $iter->count() )
	{
		my $this = undef();	# (K::Mail::Stored::YAML) YAML object
		my $iitr = undef();	# (K::Iterator) Iterator for inner process
		my $data = [];		# (Ref->Array) Updated record
		my $dont = 0;		# (Integer) Flag, Do Not UPDATE
		my $stat = 0;		# (Integer) UPDATE Status
		my $cdat = new Kanadzuchi::BdDR::Cache();
		my $btab = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $bddr->handle() );
		my $zchi = $self->{'kanadzuchi'};

		$this = $iter->first();
		unless( $this->id() )
		{
			$zchi->historieque('err', 'mode=update, stat=no such record');
			return $self->e('nosuchrecord', 'ID: #'.$cond->{'id'});
		}

		$dont |= $cgiq->param('fe_hostgroup') eq '_' ? 1 : 0;
		$dont |= $cgiq->param('fe_reason') eq '_' ? 2 : 0;

		$this->hostgroup( $cgiq->param('fe_hostgroup') ) unless $dont & 1;
		$this->reason( $cgiq->param('fe_reason') ) unless $dont & 2;

		if( $dont != 3 )
		{
			$this->updated( Time::Piece->new() );
			$stat = $this->update( $btab, $cdat );

			# syslog
			$zchi->historique('info',
				sprintf("logs=WebUI, records=1, inserted=0, updated=%d, skipped=0, failed=%d, mode=update, stat=ok",
					( $stat ? 1 : 0 ), ( $stat ? 0 : 1 ) ));

			return('Failed') unless( $stat );
		}

		$data = $this->damn();
		$data->{'updated'}  = $this->updated->ymd().'('.$this->updated->wdayname().') '.$this->updated->hms();
		$data->{'bounced'}  = $this->bounced->ymd().'('.$this->bounced->wdayname().') '.$this->bounced->hms();
		$data->{'bounced'} .= ' '.$this->timezoneoffset() if( $this->timezoneoffset() );
		$self->tt_params( 
			'pv_bouncemessages' => [ $data ],
			'pv_isupdated' => 1,
			'pv_isreadonly' => $isro,
		);
		return $self->tt_process( $file );
	}
	else
	{
		return $self->e('nosuchrecord', 'ID: #'.$cond->{'id'});
	}
}

1;
__END__
