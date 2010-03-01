#__PERLEXECUTABLE__
# $Id: bouncehammer.PL,v 1.2 2010/03/01 23:41:35 ak Exp $
# -Id: bouncehammer.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: bouncehammer.cgi,v 1.2 2009/10/05 08:56:49 ak Exp -
# -Id: bouncehammer.PL,v 1.1 2009/08/27 05:10:08 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
package Kanadzuchi::UI::Web::CGI;

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
	'index'		=> { 'app' => 'Web::Index',	'rm' => 'Index' },
	'token'		=> { 'app' => 'Web::Token',	'rm' => 'Token' },
	'test'		=> { 'app' => 'Web::Test',	'rm' => 'Test' },
	'test/parse'	=> { 'app' => 'Web::Test',	'rm' => 'Parse' },
	'config'	=> { 'app' => 'Web::Config',	'rm' => 'Config' },
	'profile'	=> { 'app' => 'Web::Profile',	'rm' => 'Profile' },
	'summary'	=> { 'app' => 'Web::Summary',	'rm' => 'Summary' },
	'update/:pi_id'	=> { 'app' => 'Web::Update',	'rm' => 'Update' },

	'search/recipient/:pi_recipient?/:pi_orderby?/:pi_page?/:pi_rpp?' => { 
						'app' => 'Web::Search', 
						'rm'  => 'Search' },
	'search/condition/:pi_condition?/:pi_orderby?/:pi_page?/:pi_rpp?' => {
						'app' => 'Web::Search',
						'rm'  => 'Search' },
	'download/:pi_format?/:pi_condition?/:pi_orderby?' => {
						'app' => 'Web::Search',
						'rm'  => 'Search' },
	'tables/:pi_tablename/sort/:pi_orderby' => {
				'app' => 'Web::MasterTables',
				'rm'  => 'TableList' },
	'tables/:pi_tablename/list' => {
				'app' => 'Web::MasterTables',
				'rm'  => 'TableList' },
	'tables/:pi_tablename/create' => {
				'app' => 'Web::MasterTables',
				'rm'  => 'TableControl' },
	'tables/:pi_tablename/update' => { 
				'app' => 'Web::MasterTables',
				'rm'  => 'TableControl' },
	'tables/:pi_tablename/delete' => { 
				'app' => 'Web::MasterTables',
				'rm'  => 'TableControl' },
];

my $dispatchargs_to_new = {
	TMPL_PATH => [],
	PARAMS => {
		'cf' => $Settings->{'coreconfig'},
		'wf' => $Settings->{'webconfig'},
		'tf' => $Settings->{'template'},
		'px' => $Settings->{'mailboxparser'},
		'cx' => $Settings->{'databasectl'},
	},
};

CGI::Application::Dispatch->dispatch(
		prefix	=> 'Kanadzuchi::UI',
		default	=> 'index',
		table	=> $dispatchtables,
		args_to_new => $dispatchargs_to_new,
	);

__END__
