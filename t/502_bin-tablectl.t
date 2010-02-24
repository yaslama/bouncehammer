# $Id: 502_bin-tablectl.t,v 1.4 2010/02/22 05:59:17 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 107 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',107) if($@);

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
			'command' => q(./src/bin/tablectl),
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
			'length' => 1641,
		},
		{
			'name' => 'Format is CSV',
			'option' => $O.q( -Fc ),
			'length' => 615,
		},
		{
			'name' => 'Format is ASCIITable',
			'option' => $O.q( -Fa ),
			'length' => 1488,
		},
	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	SKIP: {
		my $S = 107;	# Skip
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

		SENDERDOMAINS: {
			my $sdcache = [];
			my $idcache = {};
			my $command = q();
			my $xstatus = 0;
			my $xresult = q();
			my $yamlret = undef();

			INSERT: foreach my $y ( @$Y )
			{
				next() if( grep( { $y->{'senderdomain'} eq $_ } @$sdcache ) );

				$command = $E->perl().$E->command().$O.q{ --table s --insert --name }.$y->{'senderdomain'};
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));

				ok( $xstatus, q{INSERT: domainname = }.$y->{'senderdomain'} );
				push( @$sdcache, $y->{'senderdomain'} );
			}
		
			FIRSTDUMP: {
				$command = $E->perl().$E->command().$O.q{ --table s --list > }.$E->tempdir().q{/tablectl-dump.dat};
				$xstatus = scalar(IPC::Cmd::run( command => $command ));
				ok( $xstatus, q{Dumped to }.$E->tempdir() );
			}

			RECORDS1: {
				$command = $E->perl().$E->command().$O.q{ --table s --list};
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				isa_ok( $yamlret, q|ARRAY| );
				is( $#{$yamlret}, $#{$sdcache}, $#{$sdcache}.q{ records are inserted} );
			}

			SELECT1: foreach my $c ( @$sdcache )
			{
				$command = $E->perl().$E->command().$O.q{ --table s --list --name }.$c;
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				is( $yamlret->[0]->{'domainname'}, $c, q{SELECT: domainname = }.$c );
				$idcache->{ $yamlret->[0]->{'id'} } = $c;
			}

			UPDATE: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table s --update --id }.$i.q{ --description }.uc($idcache->{$i});
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ) );

				ok( $xstatus, q{UPDATE: description = }.uc($idcache->{$i}) );
			}

			SELECT2: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table s --list --id }.$i;
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );

				is( $yamlret->[0]->{'domainname'}, $idcache->{$i}, q{SELECT: domainname = }.$idcache->{$i} );
			}

			DUMPAGAIN: foreach my $s ( @$Suite )
			{
				$command = $E->perl().$E->command().$s->{'option'}.q{ --table s --list };
				$xresult = qx($command);
				is( length($xresult), $s->{'length'}, $s->{'name'}.q{/length = }.$s->{'length'} );
			}

			DELETE: foreach my $i ( keys(%$idcache) )
			{
				$command = $E->perl().$E->command().$O.q{ --table s --remove --id }.$i;
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ) );

				ok( $xstatus, q{DELETE: id = }.$i.q{, domainname = }.$idcache->{$i} );
			}

			RECORDS2: {
				$command = $E->perl().$E->command().$O.q{ --table s --list};
				$xresult = qx( $command );
				$yamlret = JSON::Syck::Load( $xresult );
				is( ( $#{$yamlret} + 1 ), 0, q{Recores in the database have been removed} );
			}
		}
	} # End of SKIP
}
__END__

