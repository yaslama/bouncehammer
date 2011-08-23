# $Id: Dispatch.pm,v 1.12.2.1 2011/08/23 21:28:56 ak Exp $
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
use base 'CGI::Application::Dispatch';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Settings = {
	'coreconfig'	=> '__KANADZUCHIETC__/bouncehammer.cf',
	'webconfig'	=> '__KANADZUCHIETC__/webui.cf',
	'neighbors'	=> '__KANADZUCHIETC__/neighbor-domains',
	'countries'	=> '__KANADZUCHIETC__/available-countries',
	'mtamodules'	=> '__KANADZUCHIROOT__/lib/Kanadzuchi/MTA',
	'template'	=> '__KANADZUCHIDATA__/template',
};

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||D |||i |||s |||p |||a |||t |||c |||h |||       |||T |||a |||b |||l |||e ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
my $WebUIDashboard = { 'app' => 'Web::Index', 'rm' => 'Index' };
my $WebUISearching = { 'app' => 'Web::Search', 'rm' => 'Search' };
my $WebUITableCtrl = { 'app' => 'Web::MasterTables', 'rm' => 'TableControl' };
my $WebUITableList = { 'app' => 'Web::MasterTables', 'rm' => 'TableList' };
my $DispatchTables = [
	'about' => {
		'app' => 'Web::About',
		'rm'  => 'About' },
	'aggregate/:pi_tablename' => {
		'app' => 'Web::Aggregate',
		'rm'  => 'Aggregate' },
	'dailyupdates/:pi_totalsby?/:pi_page?/:pi_rpp?/:pi_uioption?' => {
		'app' => 'Web::DailyUpdates',
		'rm'  => 'DailyUpdates' },
	'dashboard' => $WebUIDashboard,
	'delete/:pi_id'	=> { 
		'app' => 'Web::Delete',
		'rm'  => 'Delete' },
	'download/:pi_format?/:pi_orderby?/:pi_condition?' => $WebUISearching,
	'index' => $WebUIDashboard,
	'listof/:pi_list' => {
		'app' => 'Web::ListOf',
		'rm'  => 'ListOf' },
	'profile' => { 
		'app' => 'Web::Profile',
		'rm'  => 'Profile' },
	'search' => { 
		'app' => 'Web::Search',
		'rm'  => 'StartSearch' },
	'search/:pi_orderby?/:pi_page?/:pi_rpp?/:pi_condition?' => $WebUISearching,
	'search/recipient/:pi_recipient?/:pi_orderby?/:pi_page?/:pi_rpp?' => $WebUISearching,
	'summary' => {
		'app' => 'Web::Summary',
		'rm'  => 'Summary' },
	'tables/:pi_tablename/sort/:pi_orderby/:pi_page?/:pi_rpp?' => $WebUITableList,
	'tables/:pi_tablename/list/:pi_page?/:pi_rpp?' => $WebUITableList,
	'tables/:pi_tablename/create' => $WebUITableCtrl,
	'tables/:pi_tablename/update' => $WebUITableCtrl,
	'tables/:pi_tablename/delete' => $WebUITableCtrl,
	'test' => {
		'app' => 'Web::Test',
		'rm'  => 'Test' },
	'test/parse' => { 
		'app' => 'Web::Test',
		'rm'  => 'Parse' },
	'token' => {
		'app' => 'Web::Token',
		'rm'  => 'Token' },
	'update/:pi_id' => {
		'app' => 'Web::Update',
		'rm'  => 'Update' },
	# download/:pi_format?/:pi_condition?/... is backward compatible; 2.5.0 or former.
	'download/:pi_format?/:pi_condition?/:pi_orderby?' => $WebUISearching,
	# seaarch/condition/... is backward compatible; 2.5.0 or former.
	'search/condition/:pi_condition?/:pi_orderby?/:pi_page?/:pi_rpp?' => $WebUISearching,
];

my $DispatchArgsToNew = {
	'TMPL_PATH' => [],
	'PARAMS' => {
		'cf' => $Settings->{'coreconfig'},
		'wf' => $Settings->{'webconfig'},
		'tf' => $Settings->{'template'},
		'nd' => $Settings->{'neighbors'},
		'cc' => $Settings->{'countries'},
		'mm' => $Settings->{'mtamodules'},
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
