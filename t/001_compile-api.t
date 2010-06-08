use strict;
use warnings;
use lib qw(./t/lib ./dist/lib ./src/lib);
use Test::More;

my $Modules = [
	q(Kanadzuchi::API),
	q(Kanadzuchi::API::HTTP),
	q(Kanadzuchi::API::Dispatch),
];

plan( tests => scalar @$Modules );
SKIP: {
	eval {
		require CGI::Application;
		require CGI::Application::Dispatch;
		require CGI::Application::Plugin::TT;
		require CGI::Application::Plugin::Session;
		require CGI::Application::Plugin::HTMLPrototype;
	};

	skip( 'CGI::Application::* is not installed', scalar @$Modules ) if( $@ );
	foreach my $module ( @$Modules ){ use_ok($module); }
}

__END__
