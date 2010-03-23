# $Id: Dispatch.pm,v 1.1 2010/03/23 06:39:50 ak Exp $
# -Id: Index.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Index.pm,v 1.3 2009/08/13 07:13:57 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                     
 ####     ##                       ##        ##      
 ## ##         ##### #####  #### ###### #### ##      
 ##  ##  ###  ##     ##  ##    ##  ##  ##    #####   
 ##  ##   ##   ####  ##  ## #####  ##  ##    ##  ##  
 ## ##    ##      ## ##### ##  ##  ##  ##    ##  ##  
 ####    #### #####  ##     #####   ### #### ##  ##  
                     ##                              
package Kanadzuchi::UI::Web::Dispatch;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'CGI::Application::Dispatch';

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
my $DispatchTables = [
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

my $DispatchArgsToNew = {
	TMPL_PATH => [],
	PARAMS => {
		'cf' => $Settings->{'coreconfig'},
		'wf' => $Settings->{'webconfig'},
		'tf' => $Settings->{'template'},
		'px' => $Settings->{'mailboxparser'},
		'cx' => $Settings->{'databasectl'},
	},
};

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub dispatch_args
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |d|i|s|p|a|t|c|h|_|a|r|g|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# 
	# @Description	CGI::Application::Dispatch::dispatch_args()
	#
	return {
		'prefix' => 'Kanadzuchi::UI',
		'default' => 'index',
		'table'	=> $DispatchTables,
		'args_to_new' => $DispatchArgsToNew,
	};
}

1;
__END__
