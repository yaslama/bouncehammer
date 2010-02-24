# $Id: Profile.pm,v 1.4 2010/02/21 20:46:44 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI:Web::
                                              
 #####                  ###  ##  ###          
 ##  ## #####   ####   ##         ##   ####   
 ##  ## ##  ## ##  ## ##### ###   ##  ##  ##  
 #####  ##     ##  ##  ##    ##   ##  ######  
 ##     ##     ##  ##  ##    ##   ##  ##      
 ##     ##      ####   ##   #### ####  ####   
package Kanadzuchi::UI::Web::Profile;

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
sub profile_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|r|o|f|i|l|e|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Draw profile in HTML
	my $self = shift();
	my $file = q(profile.).$self->{'language'}.q(.html);

	$self->tt_params(
		'license' => $self->{'settings'}->{'license'},
		'cfversion' => $self->{'settings'}->{'version'},
		'sysuptime' => qx(uptime),
		'syslanguage' => $self->{'webconfig'}->{'language'},
	);
	$self->tt_process($file);
}

1;
__END__
