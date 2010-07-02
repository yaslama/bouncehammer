# $Id: 503_bin-databasectl.t,v 1.11 2010/07/02 00:06:49 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 504 );

SKIP: {
	my $Skip = 504;	# How many skips
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
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require JSON::Syck;
	require File::Copy;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $Kana = new Kanadzuchi();
	my $BdDR = new Kanadzuchi::BdDR();
	my $Btab = undef();
	my $Page = new Kanadzuchi::BdDR::Page();
	my $Test = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/databasectl) ? q(./dist/bin/databasectl) : q(./src/bin/databasectl.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => q(/tmp/bouncehammer-test.db),
			'tempdir' => q(./.test),
	);
	my $Yaml = undef();
	my $Recs = 37;
	my $Opts = q| -C|.$Test->config();

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
		$Page->resultsperpage(100);
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
	}

	EXEC_COMMAND: {
		my $command = q();
		my $xstatus = 0;
		my $xresult = [];
		my $dresult = undef();
		my $thisent = {};
		my $yamlobj = undef();
		my $idnumis = 0;
		my $tokenis = q();

		NON_EXISTENT_LOG_DATE: {

			DATE_OPTIONS: foreach my $d ( '--today', '--yesterday', '--before 2'  )
			{
				$command = $Test->perl().$Test->command().$Opts.' --update '.$d;
				$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
				like( $xresult->[4]->[0], qr|There is no log file|, q{No log file of the option }.$d );
			}
		}

		UPDATE_FROM_CONSOLE: {
			$command = $Test->perl().$Test->command().$Opts.q{ --update }.$Test->output();
			$xstatus = scalar(IPC::Cmd::run( 'command' => $command ));
			ok( $xstatus, q{UPDATE: }.$command );
		}

		SELECT_AND_VERIFY: {
			foreach my $y ( @$Yaml )
			{
				$xstatus = $Btab->count( { 'token' => $y->{'token'} }, $Page );
				if( $y->{'senderdomain'} ne 'example.org' )
				{
					ok( $xstatus, '->count() = 1 by the token '.$y->{'token'} );

					$dresult = $Btab->search( { 'token' => $y->{'token'} }, $Page );
					ok( scalar(@$dresult), '->search() = '.scalar(@$dresult).' records' );

					$thisent = shift(@$dresult);
					foreach my $_key ( qw|addresser recipient senderdomain destination token
								hostgroup reason provider| ){

						is( $thisent->{$_key}, $y->{$_key}, '->'.$_key.' = '.$y->{$_key} );
					}
				}
				else
				{
					is( $xstatus, 0, '->count() = 0 by senderdomain = example.org' );
				}
			}
		}

		REMOVE_FOR_NEXT_TEST: {
			$xstatus = $Btab->object->delete( 't_bouncelogs', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );

			$xstatus = $Btab->object->delete( 't_destinations', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );

			$xstatus = $Btab->object->delete( 't_providers', {} );
			ok( $xstatus, '->delete() = '.$xstatus.' records' );
		}

		UPDATE_FROM_CONSOLE_WITH_BATCHMODE1: {
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --update }.$Test->output();
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'record'}, $Recs, '(1) status->record = '.$Recs );
			is( $thisent->{'insert'}, $Recs - 1, '(1) status->insert = '.($Recs-1) );
			is( $thisent->{'update'}, 0, '(1) status->update = 0' );

			$thisent = $yamlobj->{'status'}->{'skipped'};
			is( $thisent->{'no-senderdomain'}, 1, '(1) skipped->no-senderdomain = 1' );
			is( $thisent->{'too-old-or-same'}, 0, '(1) skipped->too-old-or-same = 0' );
			is( $thisent->{'is-whitelisted'}, 0, '(1) skipped->is-whitelisted = 0' );
			is( $thisent->{'exceeds-limit'}, 0, '(1) skipped->exceeds-limit = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'};
			is( $thisent->{'bouncelogs'}, 0, '(1) cache->bouncelogs = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'}->{'mastertables'};
			is( $thisent->{'addressers'}, 2, '(1) cache->matertables->addressers = 2' );
			is( $thisent->{'senderdomains'}, 20, '(1) cache->matertables->senderdomains = 20' );
			is( $thisent->{'destinations'}, 13, '(1) cache->matertables->destinations = 13' );
			is( $thisent->{'providers'}, 24, '(1) cache->matertables->providers = 24' );
		}

		UPDATE_FROM_CONSOLE_WITH_BATCHMODE2: {
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --update }.$Test->output();
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'record'}, $Recs, '(2) status->record = '.$Recs );
			is( $thisent->{'insert'}, 0, '(2) status->insert = 0' );
			is( $thisent->{'update'}, 0, '(2) status->update = 0' );

			$thisent = $yamlobj->{'status'}->{'skipped'};
			is( $thisent->{'no-senderdomain'}, 1, '(2) skipped->no-senderdomain = 1' );
			is( $thisent->{'too-old-or-same'}, 36, '(2) skipped->too-old-or-same = 36' );
			is( $thisent->{'is-whitelisted'}, 0, '(2) skipped->is-whitelisted = 0' );
			is( $thisent->{'exceeds-limit'}, 0, '(2) skipped->exceeds-limit = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'};
			is( $thisent->{'bouncelogs'}, 36, '(2) cache->bouncelogs = 36' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'}->{'mastertables'};
			is( $thisent->{'addressers'}, 0, '(2) cache->matertables->addressers = 0' );
			is( $thisent->{'senderdomains'}, 0, '(2) cache->matertables->senderdomains = 0' );
			is( $thisent->{'destinations'}, 0, '(2) cache->matertables->destinations = 0' );
			is( $thisent->{'providers'}, 0, '(2) cache->matertables->providers = 0' );
		}

		UPDATE_FROM_CONSOLE_WITH_BATCHMODE3: {
			$xstatus = $Btab->object->update( 't_bouncelogs', 
					{ 'bounced' => Time::Piece->new(1) }, 
					{ 'reason' => Kanadzuchi::Mail->rname2id('userunknown') } );
			ok( $xstatus, '->update() = '.$xstatus );

			$command = $Test->perl().$Test->command().$Opts.q{ --batch --update }.$Test->output();
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'record'}, $Recs, '(3) status->record = '.$Recs );
			is( $thisent->{'insert'}, 0, '(3) status->insert = 0' );
			is( $thisent->{'update'}, 19, '(3) status->update = 19' );

			$thisent = $yamlobj->{'status'}->{'skipped'};
			is( $thisent->{'no-senderdomain'}, 1, '(3) skipped->no-senderdomain = 1' );
			is( $thisent->{'too-old-or-same'}, 17, '(3) skipped->too-old-or-same = 17' );
			is( $thisent->{'is-whitelisted'}, 0, '(3) skipped->is-whitelisted = 0' );
			is( $thisent->{'exceeds-limit'}, 0, '(3) skipped->exceeds-limit = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'};
			is( $thisent->{'bouncelogs'}, 55, '(3) cache->bouncelogs = 55' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'}->{'mastertables'};
			is( $thisent->{'addressers'}, 0, '(3) cache->matertables->addressers = 0' );
			is( $thisent->{'senderdomains'}, 0, '(3) cache->matertables->senderdomains = 0' );
			is( $thisent->{'destinations'}, 0, '(3) cache->matertables->destinations = 0' );
			is( $thisent->{'providers'}, 0, '(3) cache->matertables->providers = 0' );
		}

		UPDATE_FROM_CONSOLE_WITH_BATCHMODE4: {
			$xstatus = $Btab->object->update( 't_bouncelogs', 
					{ 'reason' => 'whitelisted', 'bounced' => Time::Piece->new(2), }, 
					{ 'reason' => Kanadzuchi::Mail->rname2id('mailboxfull') } );
			ok( $xstatus, '->update() = '.$xstatus );

			$command = $Test->perl().$Test->command().$Opts.q{ --batch --update }.$Test->output();
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'record'}, $Recs, '(4) status->record = '.$Recs );
			is( $thisent->{'insert'}, 0, '(4) status->insert = 0' );
			is( $thisent->{'update'}, 0, '(4) status->update = 0' );

			$thisent = $yamlobj->{'status'}->{'skipped'};
			is( $thisent->{'no-senderdomain'}, 1, '(4) skipped->no-senderdomain = 1' );
			is( $thisent->{'too-old-or-same'}, 33, '(4) skipped->too-old-or-same = 33' );
			is( $thisent->{'is-whitelisted'}, 3, '(4) skipped->is-whitelisted = 3' );
			is( $thisent->{'exceeds-limit'}, 0, '(4) skipped->exceeds-limit = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'};
			is( $thisent->{'bouncelogs'}, 36, '(4) cache->bouncelogs = 36' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'}->{'mastertables'};
			is( $thisent->{'addressers'}, 0, '(4) cache->matertables->addressers = 0' );
			is( $thisent->{'senderdomains'}, 0, '(4) cache->matertables->senderdomains = 0' );
			is( $thisent->{'destinations'}, 0, '(4) cache->matertables->destinations = 0' );
			is( $thisent->{'providers'}, 0, '(4) cache->matertables->providers = 0' );
		}

		UPDATE_FROM_CONSOLE_WITH_BATCHMODE5: {
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --force --update }.$Test->output();
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'record'}, $Recs, '(5) status->record = '.$Recs );
			is( $thisent->{'insert'}, 0, '(5) status->insert = 0' );
			is( $thisent->{'update'}, 3, '(5) status->update = 3' );

			$thisent = $yamlobj->{'status'}->{'skipped'};
			is( $thisent->{'no-senderdomain'}, 1, '(5) skipped->no-senderdomain = 1' );
			is( $thisent->{'too-old-or-same'}, 33, '(5) skipped->too-old-or-same = 33' );
			is( $thisent->{'is-whitelisted'}, 0, '(5) skipped->is-whitelisted = 0' );
			is( $thisent->{'exceeds-limit'}, 0, '(5) skipped->exceeds-limit = 0' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'};
			is( $thisent->{'bouncelogs'}, 39, '(5) cache->bouncelogs = 39' );

			$thisent = $yamlobj->{'status'}->{'cache'}->{'positive'}->{'mastertables'};
			is( $thisent->{'addressers'}, 0, '(5) cache->matertables->addressers = 0' );
			is( $thisent->{'senderdomains'}, 0, '(5) cache->matertables->senderdomains = 0' );
			is( $thisent->{'destinations'}, 0, '(5) cache->matertables->destinations = 0' );
			is( $thisent->{'providers'}, 0, '(5) cache->matertables->providers = 0' );
		}

		DISABLE_AND_DELETE_FROM_CONSOLE_WITH_BATCHMODE1: {
			$tokenis = '0f9085b0dce9bf7d107eb36cd5c65195';
			$dresult = $Btab->search( { 'token' => $tokenis }, $Page );
			$idnumis = $dresult->[0]->{'id'};

			# Disable
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --disable --id }.$idnumis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'disable'}, 1, '(1) status->disable = 1' );

			$dresult = $Btab->search( { 'id' => $idnumis, 'disabled' => 1 }, $Page );
			ok( scalar(@$dresult), '->disable->search() = '.scalar(@$dresult).' record' );

			# Remove
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --remove --id }.$idnumis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'remove'}, 1, '(1) status->remove = 1' );

			$dresult = $Btab->search( { 'id' => $idnumis }, $Page );
			is( scalar(@$dresult), 0, '->remove->search() = 0' );
		}

		DISABLE_AND_DELETE_FROM_CONSOLE_WITH_BATCHMODE2: {
			# Disable
			$tokenis = 'be1464c00a0ba88dffc3637697780213';
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --disable --token }.$tokenis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'disable'}, 1, '(2) status->disable = 1' );

			$dresult = $Btab->search( { 'token' => $tokenis, 'disabled' => 1 }, $Page );
			ok( scalar(@$dresult), '->disable->search() = '.scalar(@$dresult).' record' );

			# Remove
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --remove --token }.$tokenis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'remove'}, 1, '(2) status->remove = 1' );

			$dresult = $Btab->search( { 'token' => $tokenis }, $Page );
			is( scalar(@$dresult), 0, '->remove->search() = 0' );
		}

		DISABLE_AND_DELETE_FROM_CONSOLE_WITH_BATCHMODE3: {
			$tokenis = '3f173ec3d365066d43ba1b126fe689fc';
			$dresult = $Btab->search( { 'token' => $tokenis }, $Page );
			$idnumis = $dresult->[0]->{'id'};

			# Disable
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --disable --token }.$tokenis.q{ --id }.$idnumis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'disable'}, 1, '(3) status->disable = 1' );

			$dresult = $Btab->search( { 'id' => $idnumis, 'token' => $tokenis, 'disabled' => 1 }, $Page );
			ok( scalar(@$dresult), '->disable->search() = '.scalar(@$dresult).' record' );

			# Remove
			$command = $Test->perl().$Test->command().$Opts.q{ --batch --remove --token }.$tokenis.q{ --id }.$idnumis;
			$xresult = qx($command);
			$yamlobj = JSON::Syck::Load($xresult);

			isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

			foreach my $_sk ( 'user', 'command', 'load' )
			{
				ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
			}

			ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
			ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
			ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

			$thisent = $yamlobj->{'status'};
			is( $thisent->{'remove'}, 1, '(3) status->remove = 1' );

			$dresult = $Btab->search( { 'id' => $idnumis, 'token' => $tokenis }, $Page );
			is( scalar(@$dresult), 0, '->remove->search() = 0' );
		}

	} # End of EXEC_COMMAND

	FLUSH_DATABASE: {
		truncate($Test->database(),0) if( -f $Test->database() );
	}

}
__END__
