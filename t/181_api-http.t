# $Id: 181_api-http.t,v 1.5 2010/06/25 19:35:32 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 1 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::API::HTTP|,
	'methods' => [ 'cgiapp_init', 'setup', 'cgiapp_prerun', 'cgiapp_postrun',
			'teardown', 'loadconfig', 'api_empty', 'api_select', 'exception' ],
	'instance' => undef(),
);

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

	skip( 'CGI::Application::* is not installed', 1 ) if( $@ );

	require Kanadzuchi::API::HTTP;
	PREPROCESS: {
		can_ok( $T->class(), @{$T->methods()} );
	}
}


__END__
