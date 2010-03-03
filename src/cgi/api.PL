#__PERLEXECUTABLE__
# $Id: api.PL,v 1.3 2010/03/03 05:53:52 ak Exp $
# -Id: api.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: api.cgi,v 1.3 2009/10/06 00:36:28 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
package Kanadzuchi::API::CGI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use CGI::Application::Dispatch;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Settings = {
	coreconfig	=> '__KANADZUCHIETC__/bouncehammer.cf',
	webconfig	=> '__KANADZUCHIETC__/webui.cf',
	mailboxparser	=> '__KANADZUCHIBIN__/mailboxparser',
	databasectl	=> '__KANADZUCHIBIN__/databasectl',
	template	=> '__KANADZUCHIDATA__/template',
};

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||D |||i |||s |||p |||a |||t |||c |||h |||       |||T |||a |||b |||l |||e ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
my $dispatchtables = [
	'empty'		=> { 'app' => 'API::HTTP', 'rm' => 'Empty' },
	'query/:token?' => { 'app' => 'API::HTTP', 'rm' => 'Query' },
];

my $dispatchargs_to_new = {
	TMPL_PATH => [],
	PARAMS => {
		'cf' => $Settings->{'coreconfig'},
		'wf' => $Settings->{'webconfig'},
		'px' => $Settings->{'mailboxparser'},
		'cx' => $Settings->{'databasectl'},
	},
};

CGI::Application::Dispatch->dispatch(
		prefix	=> 'Kanadzuchi',
		default	=> 'empty',
		table	=> $dispatchtables,
		args_to_new => $dispatchargs_to_new,
	);

__END__
