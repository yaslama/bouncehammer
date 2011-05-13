#__PERLEXECUTABLE__
# $Id: api.PL,v 1.6.2.1 2011/05/13 06:29:25 ak Exp $
# -Id: api.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: api.cgi,v 1.3 2009/10/06 00:36:28 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
package Kanadzuchi::API::HTTP::CGI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use lib '__PERLEXTERNALLIB__';
use strict;
use warnings;
use Kanadzuchi::API::HTTP::Dispatch;

my $SystemArgs = Kanadzuchi::API::HTTP::Dispatch->dispatch_args();
my $UseMyConfs = 0;	# 1 = Use $MySettings, 0 = Don't use it
my $MySettings = {
	'PARAMS' => {
		'cf' => '/path/to/my/custom/bouncehammer.cf',
		'wf' => '/path/to/my/custom/webui.cf',
	},
	'TMPL_PATH' => [],
};

foreach my $x ( 'cf', 'wf' )
{
	last() unless( $UseMyConfs );
	$UseMyConfs = 0 unless( defined($MySettings->{'PARAMS'}->{$x}) );
	$UseMyConfs = 0 unless( -r $MySettings->{'PARAMS'}->{$x} && -s _ );
}

Kanadzuchi::API::HTTP::Dispatch->dispatch(
	'prefix' => $SystemArgs->{'prefix'},
	'default' => $SystemArgs->{'default'},
	'table' => $SystemArgs->{'table'},
	'args_to_new' => $UseMyConfs ? $MySettings : $SystemArgs->{'args_to_new'},
);

1;
__END__
