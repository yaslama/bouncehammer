# $Id: Profile.pm,v 1.5 2010/03/01 23:42:12 ak Exp $
# -Id: Profile.pm,v 1.2 2009/08/31 06:58:25 ak Exp -
# -Id: Profile.pm,v 1.3 2009/08/17 06:54:30 ak Exp -
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
