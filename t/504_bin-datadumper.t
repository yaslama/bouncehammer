# $Id: 504_bin-datadumper.t,v 1.10 2010/03/25 15:50:37 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 210 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip( 'Because no IPC::Cmd for testing', 210 ) if( $@ );

	use Kanadzuchi::Test::CLI;
	use Kanadzuchi;
	use JSON::Syck;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $K = new Kanadzuchi();
	my $E = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/datadumper) ? q(./dist/bin/datadumper) : q(./src/bin/datadumper.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(./.test/test.db),
			'tempdir' => q(./.test),
	);
	my $R = 37;
	my $O = q| -C|.$E->config();
	my $Suite = [
		{
			'name' => 'Dump All data',
			'option' => ' --alldata',
			'count' => 39,
		},
		{
			'name' => 'Dump by Addresser(sender address)',
			'option' => ' --addresser sender01@example.jp',
			'count' => 1,
		},
		{
			'name' => 'Dump by recipient address',
			'option' => ' --recipient user01@example.org',
			'count' => 1,
		},
		{
			'name' => 'Dump by sender domain',
			'option' => ' --senderdomain example.gr.jp',
			'count' => 4,
		},
		{
			'name' => 'Dump by destination domain',
			'option' => ' --destination gmail.com',
			'count' => 2,
		},
		{
			'name' => 'Dump by host group',
			'option' => ' --hostgroup cellphone',
			'count' => 13,
		},
		{
			'name' => 'Dump by reason',
			'option' => ' --reason filtered',
			'count' => 5,
		},
		{
			'name' => 'Dump by message token',
			'option' => ' --token c7215ac1d049fa2dfbbb57114fdf9c92',
			'count' => 1,
		},
		{
			'name' => 'Dump recent(25y)',
			'option' => ' --howrecent 25y',
			'count' => 39,
		},
	];
	my $Comment = { 'y' => 74, 'c' => 68 };

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	SKIP: {
		my $S = 210;	# Skip
		eval { require DBI; }; skip( 'Because no DBI for testing', $S ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $S ) if( $@ );
		eval { $E->environment(2); }; 
		skip( 'Because no sqlite3 command', $S ) if( ! -x $E->sqlite3() );

		PREPROCESS: {
			my $command = q();
			my $xstatus = 0;
			my $xresult = [];
			my $yamlret = undef();
			my $sdcache = [];

			ok( $E->environment(), q{->environment()} );
			ok( $E->syntax(), q{->syntax()} );
			ok( $E->version(), q{->version()} );
			ok( $E->help(), q{->help()} );
			ok( $E->error(), q{->error()} );
			ok( $E->initdb(), q{->initdb()} );
			ok( -s $E->database(), q{Create database: }.$E->database() );

			ok( $E->mailboxparser(), q{(mailboxparser) ->mailboxparser()} );
			ok( $E->senderdomain(), q{(tablectl) INSERT senderdomains} );
			ok( $E->bouncelog(), q{(databasectl) INSERT records} );
		}

		ERROR_MESSAGES: {
			my $command = q();
			my $xresult = [];

			UNKNOWN_HOSTGROUP: {
				$command = $E->perl().$E->command().$O.q{ -gx};
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];

				like( $xresult->[4]->[0], qr{Unknown host group:}, q{Unknown host group} );
			}

			UNKNOWN_REASON: {
				$command = $E->perl().$E->command().$O.q{ -wx};
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];

				like( $xresult->[4]->[0], qr{Unknown reason:}, q{Unknown reason} );
			}
		}

		DUMP: {
			foreach my $f ( 'yaml', 'json' )
			{
				my $command = q();
				my $xresult = q();
				my $xstatus = 0;
				my $yamlret = undef();
				my $comment = 1;

				foreach my $s ( @$Suite )
				{
					NORMAL_SELECT: {
						$command = $E->perl().$E->command().$O.$s->{'option'}.q{ --format }.$f;
						$xresult = qx($command);
						$yamlret = JSON::Syck::Load( $xresult );
						ok( length($xresult), $s->{'name'}.q{ length() = }.length($xresult) );
						is( ( $#{$yamlret} + 1 ), $s->{'count'}, $s->{'name'}.q{/ }.$s->{'option'} );
					}

					ORDERBY: {
						$command = $E->perl().$E->command().$O.$s->{'option'}.q{ --orderby bounced --fotmat}.$f;
						$yamlret = JSON::Syck::Load( $xresult );
						ok( length($xresult), $s->{'name'}.q{ length() = }.length($xresult) );
						is( ( $#{$yamlret} + 1 ), $s->{'count'}, 
							$s->{'name'}.q{/ }.$s->{'option'}.q{ --orderby bounced} );
					}

					ORDERBY_DESC: {
						$command = $E->perl().$E->command().$O.$s->{'option'}.q{ --orderbydesc bounced --format }.$f;
						$yamlret = JSON::Syck::Load( $xresult );
						ok( length($xresult), $s->{'name'}.q{ length() = }.length($xresult) );
						is( ( $#{$yamlret} + 1 ), $s->{'count'}, 
							$s->{'name'}.q{/ }.$s->{'option'}.q{ --orderbydesc bounced} );
					}

					WITH_COMMENT: {
						$command = $E->perl().$E->command().$O.$s->{'option'}.q{ --comment --format }.$f;
						$xresult = qx($command);
						last() unless( length($xresult) );
						ok( ( length($xresult) - $Comment->{'y'} ), $s->{'name'}.q{ with comment} );
					}

					COUNT_ONLY: {
						$command = $E->perl().$E->command().$O.$s->{'option'}.q{ --count --format }.$f;
						$yamlret = JSON::Syck::Load( $xresult );
						is( ( $#{$yamlret} + 1 ), $s->{'count'}, 
							$s->{'name'}.q{/ }.$s->{'option'}.q{ --count} );
					}

					OTHER_INVALID_FORMAT_CHARACTER: {
						foreach my $i ( 'c', 's', 'p' )
						{
							$command = $E->perl().$E->command().$O.$s->{'option'}.q{ -F}.$i;
							$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
							ok( $xstatus, $s->{'name'}.q{/ }.$s->{'option'}.q{ -F}.$i );
						}
					}

				}
			}
		}
	} # End of SKIP
}

__END__
