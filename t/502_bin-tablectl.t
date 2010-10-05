# $Id: 502_bin-tablectl.t,v 1.17 2010/10/05 11:30:57 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 1651 );


SKIP: {
	my $Skip = 1643;	# How many skips
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',$Skip) if($@);

	eval { require DBI; }; skip( 'Because no DBI for testing', $Skip ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $Skip ) if( $@ );

	require Kanadzuchi::Test::CLI;
	require Kanadzuchi::Test::DBI;
	require Kanadzuchi;
	require Kanadzuchi::Mail;
	require Kanadzuchi::BdDR;
	require Kanadzuchi::BdDR::Page;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require File::Copy;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $Kana = new Kanadzuchi();
	my $BdDR = new Kanadzuchi::BdDR();
	my $Mtab = undef();
	my $Page = new Kanadzuchi::BdDR::Page();
	my $Test = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/tablectl) ? q(./dist/bin/tablectl) : q(./src/bin/tablectl.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(/tmp/bouncehammer-test.db),
			'tempdir' => q(./.test),
	);
	my $Yaml = undef();
	my $Recs = 37;
	my $Opts = q| -C|.$Test->config();
	my $Tset = [
		{
			'name' => 'Format is (YAML|JSON)',
			'option' => $Opts.q( -Fy ),
		},
		{
			'name' => 'Format is ASCIITable',
			'option' => $Opts.q( -Fa ),
		},
	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	CONNECT: {

		$BdDR = Kanadzuchi::BdDR->new();
		$BdDR->setup( { 'dbname' => $Test->database(), 'dbtype' => 'SQLite' } );
		$BdDR->printerror(1);
		$BdDR->connect();

		isa_ok( $BdDR, q|Kanadzuchi::BdDR| );
		isa_ok( $BdDR->handle(), q|DBI::db| );
	}

	BUILD_DATABASE: {
		truncate($Test->database(),0) if( -f $Test->database() );
		ok( Kanadzuchi::Test::DBI->buildtable($BdDR->handle()), '->DBI->buildtable()' );
	}

	MASTERTABLES: {
		$Mtab = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($BdDR->handle());
		$Page->resultsperpage(100);
	}

	PREPROCESS: {
		ok( $Test->environment(), q{->environment()} );
		ok( $Test->syntax(), q{->syntax()} );
		ok( $Test->version(), q{->version()} );
		ok( $Test->help(), q{->help()} );
		ok( $Test->error('--list'), q{->error()} );

		# Remove pre-inserted senderdomains 
		my $mtdata = $Mtab->{'senderdomains'}->search( {}, $Page );
		my $remove = 0;
		ok( scalar @$mtdata, 'senderdomains->search = '.scalar(@$mtdata) );

		foreach my $r ( @$mtdata )
		{
			$remove = $Mtab->{'senderdomains'}->remove( { 'id' => $r->{'id'} } );
			is( $remove, $r->{'id'}, 'PreProcess: ->remove('.$remove.')' );
		}
	}

	LOAD_THE_LOG: {
		$Yaml = JSON::Syck::LoadFile($Test->output());

		isa_ok( $Yaml, q|ARRAY|, $Test->output.q{: load ok} );
		is( scalar(@$Yaml), $Recs , $Test->output.q{ have }.$Recs.q{ records} );
	}

	EACH_TABLE: foreach my $tablename ( keys(%$Mtab) )
	{
		my $keyname = lc($tablename); $keyname =~ s{s\z}{};
		my $tabchar = lc(substr($tablename,0,1)); $tabchar = 'w' if( $tabchar eq 'r' );
		my $command = q();
		my $xstatus = 0;
		my $xresult = q();
		my $thisidn = 0;
		my $tccache = {};
		my $yamlret = undef();

		WRITE: {
			last(WRITE) if( lc $tablename eq 'reasons' || lc $tablename eq 'hostgroups' );

			INSERT: foreach my $y ( @$Yaml )
			{
				next() if( grep( { lc($y->{$keyname}) eq $_ } @{ $tccache->{$tablename} } ) );

				$command = $Test->perl().$Test->command().$Opts.q{ --table }.$tabchar.q{ --insert --name '}.$y->{$keyname}.q(');
				$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));

				ok( $xstatus, $tablename.q{ INSERT: name = }.$y->{$keyname} );
				push( @{ $tccache->{$tablename} }, lc($y->{$keyname}) );

				# SELECT AGAIN
				$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.q{ --list --name '}.$y->{$keyname}.q(');
				$xresult = qx($command);
				$yamlret = JSON::Syck::Load($xresult);

				isa_ok( $yamlret, q|ARRAY| );
				ok( $yamlret->[0]->{'id'}, 'INSERTED ID = '.$yamlret->[0]->{'id'} );
				is( $yamlret->[0]->{$Mtab->{$tablename}->field()}, $y->{$keyname}, 'INSERTED NAME = '.$y->{$keyname} );
				$thisidn = $yamlret->[0]->{'id'};


				UPDATE1: {
					# Rewirte Description
					$command = $Test->perl().$Test->command().$Opts.q{ --table }.$tabchar.q{ --update --description 'TEST' --id }.$thisidn;
					$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
					ok( $xstatus, $tablename.' UPDATE: description = TEST' );

					# SELECT AGAIN
					$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.' --list --id '.$thisidn;
					$xresult = qx($command);
					$yamlret = JSON::Syck::Load($xresult);

					isa_ok( $yamlret, q|ARRAY| );
					ok( $yamlret->[0]->{'id'}, 'UPDATED ID = '.$yamlret->[0]->{'id'} );
					is( $yamlret->[0]->{'description'}, 'TEST', 'UPDATED DESCRIPTION = TEST');
				}

				UPDATE2:
				{
					# To disabled
					$command = $Test->perl().$Test->command().$Opts.q{ --table }.$tabchar.q{ --update --disabled 1 --id }.$thisidn;
					$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
					ok( $xstatus, $tablename.' UPDATE: disabled = 1' );

					# SELECT AGAIN
					$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.' --list --id '.$thisidn;
					$xresult = qx($command);
					$yamlret = JSON::Syck::Load($xresult);

					isa_ok( $yamlret, q|ARRAY| );
					ok( $yamlret->[0]->{'id'}, 'UPDATED ID = '.$yamlret->[0]->{'id'} );
					is( $yamlret->[0]->{'disabled'}, 1, 'UPDATED DISABLED = 1');
				}

				UPDATE3:
				{
					# To enabled
					$command = $Test->perl().$Test->command().$Opts.q{ --table }.$tabchar.q{ --update --disabled 0 --id }.$thisidn;
					$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
					ok( $xstatus, $tablename.' UPDATE: disabled = 0' );

					# SELECT AGAIN
					$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.' --list --id '.$thisidn;
					$xresult = qx($command);
					$yamlret = JSON::Syck::Load($xresult);

					isa_ok( $yamlret, q|ARRAY| );
					ok( $yamlret->[0]->{'id'}, 'UPDATED ID = '.$yamlret->[0]->{'id'} );
					is( $yamlret->[0]->{'disabled'}, 0, 'UPDATED DISABLED = 0');
				}

				DELETE:
				{
					# DELETE FROM ...
					$command = $Test->perl().$Test->command().$Opts.q{ --table }.$tabchar.q{ --remove --id }.$thisidn;
					$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
					ok( $xstatus, $tablename.' DELETE: id = '.$thisidn );

					# SELECT AGAIN
					$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.' --list --id '.$thisidn;
					$xresult = qx($command);
					is( length($xresult), 0, 'DELETED' );
				}

			} # End of INSERT

		} # End of WRITE

		READ: {
			last(READ) if( lc $tablename ne 'reasons' && lc $tablename ne 'hostgroups' );

			$command = $Test->perl().$Test->command().$Opts.' --table '.$tabchar.q{ --list };
			$xresult = qx($command);
			$yamlret = JSON::Syck::Load($xresult);

			isa_ok( $yamlret, q|ARRAY| );

			while( my $y = shift(@$yamlret) )
			{
				my $name = $y->{ $Mtab->{$tablename}->field() };
				if( lc $tablename eq 'reasons' )
				{
					next() if( $name =~ m{\A_reserved} );
					ok( $y->{'id'}, $tablename.' SELECTED ID = '.$y->{'id'} );
					is( $y->{'id'}, Kanadzuchi::Mail->rname2id($name), 'K::Mail->rname2id('.$name.')' );
				}
				else
				{
					next() if( $name =~ m{\A_unused} );
					ok( $y->{'id'}, $tablename.' SELECTED ID = '.$y->{'id'} );
					is( $y->{'id'}, Kanadzuchi::Mail->gname2id($name), 'K::Mail->gname2id('.$name.')' );
				}
			}
		}
	}
	
	FLUSH_DATABASE: {
		truncate($Test->database(),0) if( -f $Test->database() );
	}
}
__END__
