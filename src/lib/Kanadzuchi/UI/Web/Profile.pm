# $Id: Profile.pm,v 1.10 2010/06/28 13:18:31 ak Exp $
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
use base 'Kanadzuchi::UI::Web';
use strict;
use warnings;

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
	my $file = 'profile.html';
	my $time = q();

	eval { $time = qx|uptime|; };

	$self->tt_params(
		'sysconfig' => $self->{'sysconfig'},
		'webconfig' => $self->{'webconfig'},
		'systemname' => $Kanadzuchi::SYSNAME,
		'sysconfpath' => $self->param('cf'),
		'webconfpath' => $self->param('wf'),
		'sysuptime' => $time,
		'scriptengine' => $ENV{'MOD_PERL'} || 'CGI',
		'serversoftware' => $ENV{'SERVER_SOFTWARE'} || 'Unknown',
		'serverhost' => $ENV{'SERVER_NAME'}.':'.$ENV{'SERVER_PORT'},
	);
	return $self->tt_process($file);
}

1;
__END__
