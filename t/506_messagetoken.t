# $Id: 506_messagetoken.t,v 1.2 2010/02/22 03:56:07 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 43 );

SKIP: {
	use Kanadzuchi::Test::CLI;
	use Kanadzuchi;
	use JSON::Syck;
	use File::Copy;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $K = new Kanadzuchi();
	my $E = new Kanadzuchi::Test::CLI(
			'command' => q(./src/bin/messagetoken),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'tempdir' => q(./.test),
	);

	my $O = $E->command().q| -C|.$E->config();

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	PREPROCESS: {
		$K->load($E->config());
		ok( $E->environment(1), q{->environment(1)} );
		ok( $E->syntax(), q{->syntax()} );
		ok( $E->version(), q{->version()} );
		ok( $E->help(), q{->help()} );
		ok( $E->error(), q{->error()} );

		File::Copy::copy( './examples/hammer.1970-01-01.ffffffff.000000.tmp', $E->output() );
	}

	MESSAGETOKEN: {
		my $jsonarr = JSON::Syck::LoadFile($E->output());
		my $command = q();
		my $xresult = q();

		isa_ok( $jsonarr, q|ARRAY| );

		foreach my $j ( @$jsonarr )
		{
			my $a = $j->{'addresser'};
			my $r = $j->{'recipient'};
			my $m = $j->{'token'};

			$command = $E->perl().$O.q{ -a }.$a.q{ -r }.$r;
			$xresult = qx( $command );
			chomp($xresult);

			is( $xresult, $m, q{ -a }.$a.q{ -r }.$r.q{ :MessageToken = }.$m );
		}
	}

}

__END__
