# $Id: 500_bin-mailboxparser.t,v 1.10 2010/02/24 06:03:42 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 63 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',64) if($@);

	use Kanadzuchi::Test::CLI;
	use Kanadzuchi;
	use JSON::Syck;
	use File::Basename;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $E = new Kanadzuchi::Test::CLI(
			'command' => q(./src/bin/mailboxparser),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'tempdir' => q(./.test),
	);
	my $O = q| -C|.$E->config().q| |.$E->input();

	my $Suite = [
		{
			'name' => 'Standard',
			'option' => $O,
			'count' => 37,
		},
		{
			'name' => 'Directory',
			'option' => q| -C|.$E->config().q| |.File::Basename::dirname($E->input()),
			'count' => 40,
		},
		{
			'name' => 'File and Directory',
			'option' => $O.q| ./examples |,
			'count' => 40,
		},
		{
			'name' => 'Greed',
			'option' => $O.q( --greed),
			'count' => 37,
		},
		{
			'name' => 'Safe',
			'option' => $O.q( --safe),
			'count' => 37,
		},
		{
			'name' => 'Skip all',
			'option' => $O.q( --skip),
			'count' => 34,
		},
		{
			'name' => 'Skip no-relaying',
			'option' => $O.q( --skip-norelaying),
			'count' => 36,
		},
		{
			'name' => 'Skip mailer-error',
			'option' => $O.q( --skip-mailererror),
			'count' => 36,
		},
		{
			'name' => 'Skip host-unknown',
			'option' => $O.q( --skip-hostunknown),
			'count' => 36,
		},
		{
			'name' => 'Format is CSV, -Fc',
			'option' => $O.q( -Fc ),
			'count' => 0,
		},
		{
			'name' => 'Format is ASCIITable, -Fa',
			'option' => $O.q( -Fa ),
			'count' => 0,
		},
		{
			'name' => 'Format is Sendmail(access_db), -Fs',
			'option' => $O.q( -Fs ),
			'count' => 0,
		},
		{
			'name' => 'Format is Postfix(access_db), -Fp',
			'option' => $O.q( -Fp ),
			'count' => 0,
		},

	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	PREPROCESS: {
		ok( $E->environment(1), q{->environment(1)} );
		ok( $E->syntax(), q{->syntax()} );
		ok( $E->version(), q{->version()} );
		ok( $E->help(), q{->help()} );
		# avoid: ok( $E->error(), q{->error()} );
	}

	ERROR_MESSAGES: {
		my $command = q();
		my $xresult = [];
	}

	PARSE: {
		foreach my $s ( @$Suite )
		{
			my $command = $E->perl().$E->command().$s->{'option'};
			my $xresult = qx( $command );
			my $yamlret = undef();

			ok( $xresult, qq(Parse/$s->{'name'}: $s->{'option'}) );
			ok( length($xresult), qq(Length/$s->{'name'} = ).length($xresult) );

			next() unless( $s->{'count'} );
			$yamlret = JSON::Syck::Load($xresult);
			isa_ok( $yamlret, q|ARRAY| );
			is( scalar(@$yamlret), $s->{'count'}, qq(Count/$s->{'name'} = $s->{'count'}) );
		}
	}

	STDIN: {
		my $command = q{/bin/cat }.$E->input().q{ | }.$E->perl().$E->command().q{ -C}.$E->config();
		my $xresult = qx( $command );
		my $yamlret = undef();

		ok( $xresult, q(Parse From STDIN) );
		ok( length($xresult), q(Parse From STDIN, length = ).length($xresult) );

		$yamlret = JSON::Syck::Load($xresult);
		isa_ok( $yamlret, q|ARRAY| );
	}

	REDIRECT: {
		unlink( $E->output() ) if( -w $E->output() );
		ok( scalar(IPC::Cmd::run( 'command' => 'touch '.$E->output() )) );

		my $command = $E->perl().$E->command().$O.q{ >> }.$E->output();
		my $xstatus = scalar(IPC::Cmd::run( 'command' => $command ));

		ok( $xstatus, q{Redirect >> }.$command );
		ok( -f $E->output(), q{Successfuly redirected: }.$E->output() );
	}

	LOGFILE: {
		my $command = $E->perl().$E->command().$O.q{ --log};
		my $xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
		ok( $xstatus, $E->command().$O.q{ --log} );
	}

	FILE_OPERATION: {

		my $inputfn = File::Basename::basename($E->input());
		my $copiedf = $E->tempdir().q(/).$inputfn;
		my $command = $E->perl().$E->command().q( -C).$E->config().q( ).$copiedf;
		my $xstatus = 0;

		foreach my $o ( '--truncate', '--remove' )
		{
			my $cmd = $command.qq| $o > /dev/null|;

			ok( scalar(IPC::Cmd::run('command' => q|/bin/cp |.$E->input().q| |.$E->tempdir())), q|Copying...| );
			ok( -f $copiedf, q(Copied) );

			TRUNCATE_OR_REMOVE: {
				$xstatus = scalar(IPC::Cmd::run('command' => $cmd));
				ok( $xstatus, $cmd );
				is( -s $copiedf, 0, $copiedf.q( size = 0) ) if( $o eq '--truncate' );
				is( ! -f $copiedf, 1, $copiedf.q( is removed) ) if( $o eq '--remove' );
				unlink($copiedf) if( -w $copiedf );
			}
		}
	}
}

__END__

