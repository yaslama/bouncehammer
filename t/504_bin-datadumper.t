# $Id: 504_bin-datadumper.t,v 1.15 2010/06/25 19:22:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 426 );


SKIP: {
	my $Skip = 426;	# How many skips
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',$Skip) if($@);

	eval { require DBI; }; skip( 'Because no DBI for testing', $Skip ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $Skip ) if( $@ );

	require Kanadzuchi::Test::CLI;
	require Kanadzuchi::Test::DBI;
	require Kanadzuchi;
	require Kanadzuchi::BdDR;
	require Kanadzuchi::BdDR::Cache;
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require Kanadzuchi::Mail::Stored::YAML;
	require JSON::Syck;

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
	my $Test = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/datadumper) ? q(./dist/bin/datadumper) : q(./src/bin/datadumper.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(/tmp/bouncehammer-test.db),
			'tempdir' => q(./.test),
	);
	my $File = './examples/hammer.1970-01-01.ffffffff.000000.tmp';
	my $Yaml = undef();
	my $Yobj = [];
	my $Recs = 37;
	my $Opts = q| -C|.$Test->config();

	my $Tset = [
		{
			'name' => 'Dump All data',
			'option' => ' --alldata',
			'count' => 36,
		},
		{
			'name' => 'Dump by Addresser(sender address)',
			'option' => ' --addresser user1@example.jp',
			'count' => 1,
		},
		{
			'name' => 'Dump by Recipient address',
			'option' => ' --recipient domain-does-not-exist@example.gov',
			'count' => 1,
		},
		{
			'name' => 'Dump by Senderdomain name',
			'option' => ' --senderdomain example.gr.jp',
			'count' => 4,
		},
		{
			'name' => 'Dump by Destination domain name',
			'option' => ' --destination gmail.com',
			'count' => 2,
		},
		{
			'name' => 'Dump by HostGroup',
			'option' => ' --hostgroup cellphone',
			'count' => 13,
		},
		{
			'name' => 'Dump by Provider',
			'option' => ' --provider various',
			'count' => 5,
		},
		{
			'name' => 'Dump by Reason',
			'option' => ' --reason filtered',
			'count' => 5,
		},
		{
			'name' => 'Dump by Message Token',
			'option' => ' --token 0f9085b0dce9bf7d107eb36cd5c65195',
			'count' => 1,
		},
		{
			'name' => 'Dump Recent(25 years)',
			'option' => ' --howrecent 25y',
			'count' => 36,
		},
	];
	my $Comm = { 'y' => 74, 'c' => 68 };

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

	TABLEOBJECTS: {
		$Btab = Kanadzuchi::BdDR::BounceLogs::Table->new('handle'=>$BdDR->handle());
		$Mtab = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($BdDR->handle());
	}

	LOAD_THE_LOG: {
		$Yaml = JSON::Syck::LoadFile($Test->output());

		isa_ok( $Yaml, q|ARRAY|, $Test->output.q{: load ok} );
		is( scalar(@$Yaml), $Recs , $Test->output.q{ have }.$Recs.q{ records} );
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
				is( $Yobj->count(), 37, '->count() = 37' );
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
			}
		}
	}

	DATADUMPER: {
		ERROR_MESSAGES: {
			my $command = q();
			my $xresult = [];

			UNKNOWN_HOSTGROUP: {
				$command = $Test->perl().$Test->command().$Opts.q{ -gx};
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr{Unknown host group:}, q{Unknown host group} );
			}

			UNKNOWN_REASON: {
				$command = $Test->perl().$Test->command().$Opts.q{ -wx};
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr{Unknown reason:}, q{Unknown reason} );
			}
		}

		DUMP: {
			foreach my $f ( 'yaml', 'json', 'csv' )
			{
				my $command = q();
				my $xresult = q();
				my $xstatus = 0;
				my $yamlobj = undef();
				my $comment = 1;

				foreach my $_t ( @$Tset )
				{
					NORMAL_SELECT: {
						$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' --format '.$f;
						$xresult = qx($command);
						ok( length($xresult), $_t->{'name'}.' length() = '.length($xresult) );

						next() if( $f eq 'csv' );
						$yamlobj = JSON::Syck::Load( $xresult );
						is( scalar(@$yamlobj), $_t->{'count'}, $_t->{'name'}.' '.$_t->{'option'} );
					}

					ORDERBY: {
						$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' --orderby bounced --format '.$f;
						$xresult = qx($command);
						ok( length($xresult), $_t->{'name'}.' length() = '.length($xresult) );

						next() if( $f eq 'csv' );
						$yamlobj = JSON::Syck::Load( $xresult );
						is( scalar(@$yamlobj), $_t->{'count'}, $_t->{'name'}.' '.$_t->{'option'}.' --orderby bounced' );
					}

					ORDERBY_DESC: {
						$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' --orderbydesc bounced --format '.$f;
						$xresult = qx($command);
						ok( length($xresult), $_t->{'name'}.' length() = '.length($xresult) );

						next() if( $f eq 'csv' );
						$yamlobj = JSON::Syck::Load( $xresult );
						is( scalar(@$yamlobj), $_t->{'count'}, $_t->{'name'}.' '.$_t->{'option'}.' --orderbydesc bounced' );
					}

					WITH_COMMENT: {
						$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' --comment --format '.$f;
						$xresult = qx($command);

						next() unless( length($xresult) );
						ok( ( length($xresult) - $Comm->{'y'} ), $_t->{'name'}.' with comment' );
					}

					COUNT_ONLY: {
						$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' --count --format '.$f;
						$xresult = qx($command);
						chomp($xresult);

						is( $xresult, $_t->{'count'}, $_t->{'name'}.' '.$_t->{'option'}.' --count' );
					}

					OTHER_INVALID_FORMAT_CHARACTER: {
						foreach my $i ( 'x', 's', 'p' )
						{
							$command = $Test->perl().$Test->command().$Opts.$_t->{'option'}.' -F'.$i;
							$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
							ok( $xstatus, $_t->{'name'}.' '.$_t->{'option'}.' -F'.$i );
						}
					}
				}
			}
		}
	} # End of SKIP
}

__END__
