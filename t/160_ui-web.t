# $Id: 160_ui-web.t,v 1.8 2010/07/12 08:08:43 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 24 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::UI::Web|,
	'methods' => [ 'cgiapp_init', 'setup', 'cgiapp_prerun', 'cgiapp_postrun', 'teardown',
			'tt_pre_process', 'tt_post_process', 'loadconfig', 'cryptcbc',
			'encryptit', 'decryptit', 'exception' ],
	'instance' => undef(),
);

my $W = {
	'About' => new Kanadzuchi::Test(
			'class' => $T->class().q|::About|,
			'methods' => [ @{$T->methods()}, 'about' ], ),
	'Aggregate' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Aggregate|,
			'methods' => [ @{$T->methods()}, 'aggregation' ], ),
	'Delete' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Delete|,
			'methods' => [ @{$T->methods()}, 'deletetherecord' ], ),
	'Index' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Index|,
			'methods' => [ @{$T->methods()}, 'putindexpage' ], ),
	'ListOf' => new Kanadzuchi::Test(
			'class' => $T->class().q|::ListOf|,
			'methods' => [ @{$T->methods()}, 'listofcontents' ], ),
	'MasterTables' => new Kanadzuchi::Test(
			'class' => $T->class().q|::MasterTables|,
			'methods' => [ @{$T->methods()}, 'tablelist', 'tablecontrol' ], ),
	'Profile' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Profile|,
			'methods' => [ @{$T->methods()}, 'systemprofile' ], ),
	'Search' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Search|,
			'methods' => [ @{$T->methods()}, 'onlinesearch', 'putsearchform' ], ),
	'Summary' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Summary|,
			'methods' => [ @{$T->methods()}, 'datasummary' ], ),
	'Token' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Token|,
			'methods' => [ @{$T->methods()}, 'maketoken' ], ),
	'Test' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Test|,
			'methods' => [ @{$T->methods()}, 'puttestform', 'onlineparser' ], ),
	'Update' => new Kanadzuchi::Test(
			'class' => $T->class().q|::Update|,
			'methods' => [ @{$T->methods()}, 'updatetherecord' ], ),
};

$ENV = {
	'AUTH_TYPE'		=> 'Basic',
	'DOCUMENT_ROOT'		=> '/home/user/public_html',
	'GATEWAY_INTERFACE'	=> 'CGI/1.1',
	'HTTP_ACCEPT'		=> 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
	'HTTP_ACCEPT_ENCODING'	=> 'gzip, deflate',
	'HTTP_ACCEPT_LANGUAGE'	=> 'en',
	'HTTP_CONNECTION'	=> 'keep-alive',
	'HTTP_HOST'		=> '127.0.0.1',
	'HTTP_USER_AGENT'	=> 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_4_11; en) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1',
	'PATH'			=> '/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
	'QUERY_STRING'		=> q(),
	'REMOTE_ADDR'		=> '127.0.0.1',
	'REMOTE_PORT'		=> 12345,
	'REMOTE_USER'		=> 'user',
	'REQUEST_METHOD'	=> 'POST',
	'REQUEST_URI'		=> q(),
	'SCRIPT_FILENAME'	=> q(),
	'SCRIPT_NAME'		=> '/bouncehammer.cgi',
	'SERVER_ADDR'		=> '127.0.0.1',
	'SERVER_ADMIN'		=> 'webmaster',
	'SERVER_NAME'		=> '127.0.0.1',
	'SERVER_PORT'		=> 80,
	'SERVER_PROTOCOL'	=> 'HTTP/1.1',
	'SERVER_SIGNATURE'	=> q(),
	'SERVER_SOFTWARE'	=> 'Apache/2.2.8 (Unix) DAV/2 PHP/4.4.8',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#

SKIP: {
	eval {
		require CGI::Application;
		require CGI::Application::Dispatch;
		require CGI::Application::Plugin::TT;
		require CGI::Application::Plugin::Session;
		require CGI::Application::Plugin::HTMLPrototype;
	};

	skip( 'CGI::Application::* is not installed', 16 ) if( $@ );

	require Kanadzuchi::UI::Web;

	foreach my $w ( values(%$W) )
	{
		use_ok( $w->class() );
		can_ok( $w->class(), @{$w->methods()} );
	}

}

__END__

