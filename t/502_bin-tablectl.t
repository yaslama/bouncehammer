# $Id: 502_bin-tablectl.t,v 1.9 2010/03/25 15:50:36 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 427 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',427) if($@);

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
			'command' => -x q(./dist/bin/tablectl) ? q(./dist/bin/tablectl) : q(./src/bin/tablectl.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(./.test/test.db),
			'tempdir' => q(./.test),
	);
	my $Y = undef();
	my $R = 37;
	my $O = q| -C|.$E->config();
	my $Suite = [
		{
			'name' => 'Format is (YAML|JSON)',
			'option' => $O.q( -Fy ),
		},
		{
			'name' => 'Format is ASCIITable',
			'option' => $O.q( -Fa ),
		},
	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	SKIP: {
		my $S = 427;	# Skip
		eval { require DBI; }; skip( 'Because no DBI for testing', $S ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $S ) if( $@ );
		eval { $E->environment(2); }; 
		skip( 'Because no sqlite3 command', $S ) if( ! -x $E->sqlite3() );

		PREPROCESS: {
			ok( $E->environment(), q{->environment()} );
			ok( $E->syntax(), q{->syntax()} );
			ok( $E->version(), q{->version()} );
			ok( $E->help(), q{->help()} );
			ok( $E->error('--list'), q{->error()} );
			ok( $E->mailboxparser(), q{(mailboxparser) ->mailboxparser()} );
			ok( $E->initdb(), q{->initdb()} );
			ok( -s $E->database(), q{Create database: }.$E->database() );
			File::Copy::copy( q{../examples/}.File::Basename::basename($E->output()),
						$E->tempdir().q{/}.File::Basename::basename($E->output()) );
		}

		ERROR_MESSAGES: {
			my $command = q();
			my $xresult = [];
		}

		LOAD_THE_LOG: {
			$Y = JSON::Syck::LoadFile($E->output());

			isa_ok( $Y , q|ARRAY|, $E->output.q{: load ok} );
			is( ( $#{$Y} + 1 ), $R , $E->output.q{ have }.$R.q{ records} );
		}

		EACH_TABLE: foreach my $tablename ( 'senderdomain', 'addresser', 'destination', 'provider', 'hostgroup', 'reason' ) 
		{
			my $tabchar = lc(substr($tablename,0,1));
			my $colname = 'name';
			my $tccache = [];
			my $idcache = {};
			my $command = q();
			my $xstatus = 0;
			my $xresult = q();
			my $yamlret = undef();
			my $insertx = 0;
			my $deletex = 0;

			$colname = 'domainname' if( $tabchar eq 's' || $tabchar eq 'd' );
			$colname = 'email' if( $tabchar eq 'a' );
			do { $colname = 'why'; $tabchar = 'w' } if( $tabchar eq 'r' );

			INSERT: foreach my $y ( @$Y )
			{
				next() if( grep( { $y->{$tablename} eq $_ } @$tccache ) );

				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --insert --name }.$y->{$tablename};
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));

				ok( $xstatus, $tablename.q{ INSERT: name = }.$y->{$tablename} );
				push( @$tccache, lc($y->{$tablename}) );
				$insertx++;
			}
		
			FIRSTDUMP: {
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --list > }.$E->tempdir().q{/tablectl-dump.}.$tabchar.q{.dat};
				$xstatus = scalar(IPC::Cmd::run( command => $command ));
				ok( $xstatus, $tablename.q{ Dumped to }.$E->tempdir() );
			}

			RECORDS1: {
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --list};
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				isa_ok( $yamlret, q|ARRAY| );
				is( $insertx, scalar(@$tccache), $tablename.q{ }.scalar(@$tccache).q{ records are inserted} );
			}

			SELECT1: foreach my $c ( @$tccache )
			{
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --list --name }.$c;
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				is( $yamlret->[0]->{$colname}, $c, $tablename.q{ SELECT: name = }.$c );
				$idcache->{ $yamlret->[0]->{'id'} } = $c;
			}

			UPDATE: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --update --id }.$i.q{ --description }.uc($idcache->{$i});
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ) );

				ok( $xstatus, $tablename.q{ UPDATE: description = }.uc($idcache->{$i}) );
			}

			SELECT2: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --list --id }.$i;
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				is( $yamlret->[0]->{$colname}, $idcache->{$i}, $tablename.q{ SELECT: name = }.$idcache->{$i} );
			}

			DUMPAGAIN: foreach my $s ( @$Suite )
			{
				$command = $E->perl().$E->command().$s->{'option'}.q{ --table }.$tabchar.q{ --list };
				$xresult = qx($command);
				ok( length($xresult), $tablename.q{ length = }.length($xresult));
			}

			next() unless( $tablename eq 'senderdomain' );
			DELETE: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --remove --id }.$i;
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ) );

				ok( $xstatus, $tablename.q{ DELETE: id = }.$i.q{, domainname = }.$idcache->{$i} );
				$deletex++;
			}

			RECORDS2: {
				$command = $E->perl().$E->command().$O.q{ --table }.$tabchar.q{ --list};
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );
				is( ( $#{$yamlret} + 1 ), ( $insertx - $deletex ), $tablename.q{ }.$deletex.q{ Recores in the database have been removed} );
			}

		} # End of EACH_TABLE


	} # End of SKIP
}
__END__

