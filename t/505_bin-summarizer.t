# $Id: 505_bin-summarizer.t,v 1.18 2010/08/28 17:22:45 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 200 );

SKIP: {
	my $howmanyskips = 200;
	eval{ require IPC::Cmd; }; 
	skip( 'Because no IPC::Cmd for testing', $howmanyskips ) if($@);

	eval { require DBI; }; skip( 'Because no DBI for testing', $howmanyskips ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $howmanyskips ) if( $@ );

	require Kanadzuchi::Test::CLI;
	require Kanadzuchi::Test::DBI;
	require Kanadzuchi;
	require Kanadzuchi::BdDR;
	require Kanadzuchi::BdDR::Cache;
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require Kanadzuchi::BdDR::DailyUpdates;
	require Kanadzuchi::Mail::Stored::YAML;
	require File::Copy;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $Kana = new Kanadzuchi();
	my $BdDR = new Kanadzuchi::BdDR();
	my $Btab = undef();
	my $Mtab = {};
	my $Cdat = new Kanadzuchi::BdDR::Cache();
	my $Dobj = undef();
	my $Test = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/summarizer) ? q(./dist/bin/summarizer) : q(./src/bin/summarizer.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(/tmp/bouncehammer-test.db),
			'tempdir' => q(./.test),
	);
	my $Opts = q| -C|.$Test->config().q| |;
	my $File = './examples/hammer.1970-01-01.ffffffff.000000.tmp';
	my $Yaml = undef();
	my $Yobj = [];
	my $Recs = 37;

	my $Tset = [
		{
			'name' => 'Aggregate records in the file',
			'option' => $Opts.' '.$Test->output(),
		},
		{
			'name' => 'Aggregate records in the file/descriptive statistics',
			'option' => $Opts.' -s '.$Test->output(),
		},
		{
			'name' => 'Aggregate records in the db',
			'option' => $Opts.' -D ',
		},
		{
			'name' => 'Aggregate records in the db/descriptive statistics',
			'option' => $Opts.' -Ds ',
		},
		{
			'name' => 'Aggregate records in the db/--date',
			'option' => $Opts.' -D --date 2009/07/17',
		},
		{
			'name' => 'Aggregate records in the db/--period',
			'option' => $Opts.' -D --period 2000/01/01:2009/12/31',
		},
	];

	my $Uset = [
		{
			'name' => 'Daily Updates in the db',
			'option' => $Opts.' -U ',
		},
		{
			'name' => 'Daily Updates in the db/descriptive statistics',
			'option' => $Opts.' -Us ',
		},
		{
			'name' => 'Daily Updates in the db/--date',
			'option' => $Opts.' -Us --date 1980/07/17',
		},
		{
			'name' => 'Daily Updates in the db/--period',
			'option' => $Opts.' -Us --period 1975/04/01:1999/12/31',
		},
		{
			'name' => 'Daily Updates in the db/totals by date',
			'option' => $Opts.' -U --totalsby date',
		},
		{
			'name' => 'Daily Updates in the db/totals by week',
			'option' => $Opts.' -U --totalsby week',
		},
		{
			'name' => 'Daily Updates in the db/totals by month',
			'option' => $Opts.' -U --totalsby month',
		},
		{
			'name' => 'Daily Updates in the db/totals by year',
			'option' => $Opts.' -U --totalsby year',
		},
	];

	my $uData = [ 
		{ 'thedate' => '1970-01-01', 'inserted' => 1, 'updated' => 2, 'skipped' => 3 },
		{ 'thedate' => '1975-04-09', 'inserted' => 4, 'updated' => 5, 'skipped' => 6 },
		{ 'thedate' => '1980-07-17', 'inserted' => 7, 'updated' => 8, 'skipped' => 9 },
	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	File::Copy::copy( $File, $Test->output() ) unless -e $Test->output();
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

	TABLEOBJECTS: {
		$Btab = Kanadzuchi::BdDR::BounceLogs::Table->new('handle'=>$BdDR->handle());
		$Mtab = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($BdDR->handle());
		$Dobj = Kanadzuchi::BdDR::DailyUpdates::Data->new( 'handle' => $BdDR->handle() );
	}
	
	LOAD_THE_LOG: {
		$Yaml = JSON::Syck::LoadFile($Test->output());

		isa_ok( $Yaml, q|ARRAY|, $Test->output.q{: load ok} );
		is( scalar(@$Yaml), $Recs, $Test->output.q{ have }.$Recs.q{ records} );
	}

	PREPROCESS: {

		ok( $Test->environment(), q{->environment()} );
		ok( $Test->syntax(), q{->syntax()} );
		ok( $Test->version(), q{->version()} );
		ok( $Test->help(), q{->help()} );
		ok( $Test->error(), q{->error()} );

		REMOVE_RECORDS: {
			my $xstatus = 0;
			$xstatus = $Btab->object->delete( 't_bouncelogs', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );

			$xstatus = $Btab->object->delete( 't_destinations', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );

			$xstatus = $Btab->object->delete( 't_providers', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );
		}

		REGISTER_RECORDS: {
			DATA_OBJECT: {
				$Yobj = Kanadzuchi::Mail::Stored::YAML->loadandnew($File);
				isa_ok( $Yobj, q|Kanadzuchi::Iterator| );
				is( $Yobj->count(), $Recs, '->count() = '.$Recs );
			}

			INSERT: {
				while( my $_e = $Yobj->next() )
				{
					my $newid = $_e->insert( $Btab, $Mtab, $Cdat );
					my $array = [];
					if( $_e->senderdomain eq 'example.org' )
					{
						# The senderdomain 'example.org' does not exist in src/sql/*.sql
						is( $newid, 0, '->insert(), ID = 0(No senderdomain), FROM = '.$_e->addresser->address() );
					}
					else
					{
						ok( $newid, '->insert(), ID = '.$newid.', FROM = '.$_e->addresser->address() );

						$array = $Btab->search( { 'id' => $newid } );
						isa_ok( $array, q|ARRAY| );
						ok( scalar(@$array), '->search(id) returns '.scalar(@$array) );
					}
				}

				$Dobj->recordit($uData);
			}
		}
	}

	EXEC: {
		my $command = q();
		my $xresult = [];
		my $yamlobj = undef();

		ERROR_MESSAGES: {

			NO_AGGREGATION_OPTION: {
				$command = $Test->perl().$Test->command().$Opts;
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr{Aggregation option}, q{Aggregation option} );
			}

			INVALID_COLUMN_NAME: {
				$command = $Test->perl().$Test->command().$Opts.q{ -ax};
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr{Invalid column name}, q{Invalid column name} );
			}
		}

		AGGREGATE_ALL_COLUMNS:  foreach my $_t ( @$Tset )
		{
			$command = $Test->perl().$Test->command().' -A '.$_t->{'option'};
			$xresult = qx($command);
			ok( length($xresult), $_t->{'name'}.' length() = '.length($xresult) );
		}

		AGGREGATE_EACH_COLUMNS: foreach my $_c ( qw{s d h p w} )
		{
			foreach my $_f ( 'asciitable', 'yaml' )
			{
				foreach my $_t ( @$Tset )
				{
					$command = $Test->perl().$Test->command().' -a'.$_c.' -F'.$_f.' '.$_t->{'option'};
					$xresult = qx($command);

					if( $_f eq 'asciitable' )
					{
						ok( length($xresult), $_t->{'name'}.', col = '.$_c.' length() = '.length($xresult) );
					}
					else
					{
						$yamlobj = JSON::Syck::Load($xresult);
						isa_ok( $yamlobj, q|HASH| );
					}
				}
			}
		}

		DAILYUPDATES:  foreach my $_u ( @$Uset )
		{
			$command = $Test->perl().$Test->command().$_u->{'option'};
			$xresult = qx($command);
			ok( length($xresult), $_u->{'name'}.' length() = '.length($xresult) );
		}

	}

}

__END__
