#__PERLEXECUTABLE__
# $Id: bouncehammer.PL,v 1.4 2010/03/26 07:17:51 ak Exp $
# -Id: bouncehammer.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: bouncehammer.cgi,v 1.2 2009/10/05 08:56:49 ak Exp -
# -Id: bouncehammer.PL,v 1.1 2009/08/27 05:10:08 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.

package Kanadzuchi::UI::Web::CGI;
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use Kanadzuchi::UI::Web::Dispatch;

my $SystemArgs = Kanadzuchi::UI::Web::Dispatch->dispatch_args();
my $UseMyConfs = 0;	# 1=Use $MySettings, 0=Don't use it
my $MySettings = {
	'PARAMS' => {
		'cf' => '/path/to/my/custom/bouncehammer.cf',
		'wf' => '/path/to/my/custom/webui.cf',
	},
	'TMPL_PATH' => $SystemArgs->{'args_to_new'}->{'TMPL_PATH'} || [],
};

foreach my $x ( 'cf', 'wf' )
{
	last() unless( $UseMyConfs );
	$UseMyConfs = 0 unless( defined($MySettings->{'PARAMS'}->{$x}) );
	$UseMyConfs = 0 unless( -r $MySettings->{'PARAMS'}->{$x} && -s _ );
}

Kanadzuchi::UI::Web::Dispatch->dispatch(
	'prefix' => $SystemArgs->{'prefix'},
	'default' => $SystemArgs->{'default'},
	'table' => $SystemArgs->{'table'},
	'args_to_new' => $UseMyConfs ? $MySettings : $SystemArgs->{'args_to_new'},
);

__END__
