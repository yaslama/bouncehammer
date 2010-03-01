# $Id: 503_bin-databasectl.t,v 1.5 2010/03/01 21:32:07 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 33 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',33) if($@);

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
			'command' => -x q(./dist/bin/databasectl) ? q(./dist/bin/databasectl) : q(./src/bin/databasectl.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(./.test/test.db),
			'tempdir' => q(./.test),
	);
	my $O = q| -C|.$E->config();

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	SKIP: {
		my $S = 33;	# Skip
		eval { require DBI; }; skip( 'Because no DBI for testing', $S ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $S ) if( $@ );
		eval { $E->environment(2); }; 
		skip( 'Because no sqlite3 command', $S ) if( ! -x $E->sqlite3() );

		PREPROCESS: {
			ok( $E->environment(), q{->environment()} );
			ok( $E->syntax(), q{->syntax()} );
			ok( $E->version(), q{->version()} );
			ok( $E->help(), q{->help()} );
			ok( $E->error(), q{->error()} );
			ok( $E->mailboxparser(), q{(mailboxparser) ->mailboxparser()} );
			ok( $E->initdb(), q{->initdb()} );
			ok( -s $E->database(), q{Create database: }.$E->database() );

			File::Copy::copy( q{./examples/}.File::Basename::basename($E->output()),
						$E->tempdir().q{/}.File::Basename::basename($E->output()) );
		}

		ERROR_MESSAGES: {
			my $command = q();
			my $xresult = [];

			DATE_OPTIONS: foreach my $d ( '--today', '--yesterday', '--before 2'  )
			{
				$command = $E->perl().$E->command().$O.q{ --update }.$d;
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr|There is no log file|, q{No log file of the option }.$d );
			}
		}

		UPDATE_FROM_CONSOLE: {
			my $command = $E->perl().$E->command().$O.q{ --update }.$E->output();
			my $xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
			ok( $xstatus, q{UPDATE: }.$command );
			ok( $E->initdb(), q{->initdb() Again} );
		}

		UPDATE_WITH_BATCH_MODE: {
			# { insert: 15, update: 0, error: 0, skip: 22, asitis: { nosender: 22, older: 0, whitelist: 0, exceedlimit: 0 } }
			my $command = $E->perl().$E->command().$O.q{ --batch --update }.$E->output();
			my $xresult = qx($command);
			my $yamlret = JSON::Syck::Load($xresult);

			isa_ok( $yamlret, q|HASH| );
			is( $yamlret->{'insert'}, 15, q{update/insert: 15} );
			is( $yamlret->{'update'}, 0, q{update/update: 0} );
			is( $yamlret->{'error'}, 0, q{update/error: 0} );
			is( $yamlret->{'skip'}, 22, q{update/skip/all: 0} );
			is( $yamlret->{'asitis'}->{'nosender'}, 22, q{update/skip/nosender: 0} );
			is( $yamlret->{'asitis'}->{'older'}, 0, q{update/skip/older: 0} );
			is( $yamlret->{'asitis'}->{'whitelist'}, 0, q{update/skip/whitelist: 0} );
			is( $yamlret->{'asitis'}->{'exceedlimit'}, 0, q{update/skip/exceedlimit: 0} );
			ok( $E->initdb(), q{->initdb() Again} );
		}

		UPDATE_FROM_STDIN: {
			# { insert: 15, update: 0, error: 0, skip: 22, asitis: { nosender: 22, older: 0, whitelist: 0, exceedlimit: 0 } }
			# { "insert": 0, "update": 0, "error": 0, "skip": 37, "asitis": { "nosender": 0, "older": 37, "whitelist": 0, "exceedlimit": 0 } }
			my $command = q{/bin/cat }.$E->output().q{ | }.$E->perl().$E->command().$O.q{ --batch --update };
			my $xresult = qx($command);
			my $yamlret = JSON::Syck::Load($xresult);

			isa_ok( $yamlret, q|HASH| );
			is( $yamlret->{'insert'}, 15, q{update/insert: 15} );
			is( $yamlret->{'update'}, 0, q{update/update: 0} );
			is( $yamlret->{'error'}, 0, q{update/error: 0} );
			is( $yamlret->{'skip'}, 22, q{update/skip/all: 0} );
			is( $yamlret->{'asitis'}->{'nosender'}, 22, q{update/skip/nosender: 0} );
			is( $yamlret->{'asitis'}->{'older'}, 0, q{update/skip/older: 0} );
			is( $yamlret->{'asitis'}->{'whitelist'}, 0, q{update/skip/whitelist: 0} );
			is( $yamlret->{'asitis'}->{'exceedlimit'}, 0, q{update/skip/exceedlimit: 0} );
			ok( $E->initdb(), q{->initdb() Again} );
		}
	} # End of SKIP
}

__END__
