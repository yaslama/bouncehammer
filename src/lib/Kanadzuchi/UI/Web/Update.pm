# $Id: Update.pm,v 1.7 2010/03/01 23:42:12 ak Exp $
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
	require Kanadzuchi::Mail::Stored::RDB;
	my $self = shift();
	my $this = undef();	# K::M::S::RDB object
	my $tmpl = undef();	# Template contents
	my $aref = [];		# Array reference
	my $cond = {};		# Hash reference for search and new()
	my $file = q(div-result.).$self->{'language'}.q(.html);

	$this = new Kanadzuchi::Mail::Stored::RDB(
			'id' => $self->param('pi_id') || $self->query->param('id') || 0,
			'token' => $self->query->param('token'),
			'hostgroup' => $self->query->param('hostgroup'),
			'reason' => $self->query->param('reason'),
			'updated' => time(),);
	return(0) unless($this->id);

	if( $this->modify(\$self->{'database'}) )
	{
		$cond = {
			'id' => $this->id(), 
			'token' => $this->token(),
			'hostgroup' => $this->hostgroup(),
			'reason' => $this->reason(), 
		};

		$aref = Kanadzuchi::Mail::Stored::RDB->searchandnew( $self->{'database'}, $cond, \{} );
		$self->tt_params( 'bouncemessages' => $aref, 'isupdated' => 1 );
		$self->tt_process( $file );
	}
	else
	{
		# Failed to update
		return('Failed');
	}
}

1;
__END__
