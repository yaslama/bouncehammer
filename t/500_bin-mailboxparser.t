# $Id: 500_bin-mailboxparser.t,v 1.22 2010/06/22 07:17:16 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 93 );

SKIP: {
	my $howmanyskips = 93;
	eval{ require IPC::Cmd; }; 
	skip( 'Because no IPC::Cmd for testing', $howmanyskips ) if($@);

	require Kanadzuchi::Test::CLI;
	require Kanadzuchi;
	require JSON::Syck;
	require File::Basename;

	#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
	# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
	# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
	#
	my $E = new Kanadzuchi::Test::CLI(
			'command' => -x q(./dist/bin/mailboxparser) ? q(./dist/bin/mailboxparser) : q(./src/bin/mailboxparser.PL),
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
			'count' => 32,
		},
		{
			'name' => 'Skip temporary error',
			'option' => $O.q( --skip-temperror),
			'count' => 35,
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
			'name' => 'Format is ASCIITable, -Fa',
			'option' => $O.q( -Fa ),
			'count' => 0,
		},
		{
			'name' => 'Format is CSV, -Fc',
			'option' => $O.q( -Fc ),
			'count' => 0,
		},
		{
			'name' => 'Format is JSON, -Fj',
			'option' => $O.q( -Fj ),
			'count' => 37,
		},
		{
			'name' => 'Two-way, -2',
			'option' => $O.q( -2 ),
			'count' => 37,
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
		ok( $E->error(), q{->error()} );
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

	BATCHMODE: {
		my $command = $E->perl().$E->command().$O.q{ --log --batch };
		my $xresult = qx( $command );
		my $yamlobj = JSON::Syck::Load($xresult);
		my $thisent = {};

		isa_ok( $yamlobj, q|HASH|, '--batch returns YAML(HASH)' );

		foreach my $_sk ( 'user', 'command', 'load' )
		{
			ok( $yamlobj->{$_sk}, $_sk.' = '.$yamlobj->{$_sk} );
		}

		ok( $yamlobj->{'time'}->{'started'}, 'time->started = '.$yamlobj->{'time'}->{'started'} );
		ok( $yamlobj->{'time'}->{'ended'}, 'time->ended = '.$yamlobj->{'time'}->{'ended'} );
		ok( $yamlobj->{'time'}->{'elapsed'} > -1, 'time->elapsed = '.$yamlobj->{'time'}->{'elapsed'} );

		$thisent = $yamlobj->{'status'};
		ok( $thisent->{'all-of-mailbox-files'}, '->all-of-mailbox-files = '.$thisent->{'all-of-mailbox-files'} );
		ok( $thisent->{'size-of-mailboxes'}, '->size-of-mailboxes = '.$thisent->{'size-of-mailboxes'} );
		ok( $thisent->{'temporary-log-file'}, '->temporary-log-file= '.$thisent->{'temporary-log-file'} );
		ok( -f $thisent->{'temporary-log-file'} );

		$thisent = $yamlobj->{'status'}->{'messages'};
		ok( $thisent->{'all-of-emails'}, '->all-of-emails = '.$thisent->{'all-of-emails'} );
		ok( $thisent->{'bounce-messages'}, '->bounce-messages = '.$thisent->{'bounce-messages'} );
		ok( $thisent->{'parsed-messages'}, '->parsed-messages = '.$thisent->{'parsed-messages'} );

		$thisent = $yamlobj->{'status'}->{'messages'}->{'ratio'};
		ok( $thisent->{'content-rate-for-bounce'}, '->content-rate-for-bounce = '.$thisent->{'content-rate-for-bounce'} );
		ok( $thisent->{'analytical-accuracy'}, '->analytical-accuracy = '.$thisent->{'analytical-accuracy'} );
	}

	FILE_OPERATION: {

		my $inputfn = File::Basename::basename($E->input());
		my $copiedf = $E->tempdir().q(/).$inputfn;
		my $command = $E->perl().$E->command().q( -C).$E->config().q( ).$copiedf;
		my $xstatus = 0;
		my $cmdexec = q();

		foreach my $o ( '--truncate', '--remove', '--backup' )
		{
			ok( scalar(IPC::Cmd::run('command' => q|/bin/cp |.$E->input().q| |.$E->tempdir())), q|Copying...| );
			ok( -f $copiedf, q(Copied) );

			if( $o eq '--backup' )
			{
				$cmdexec = $command.qq| $o /tmp > /dev/null|;
				$xstatus = scalar(IPC::Cmd::run('command' => $cmdexec));
				ok( $xstatus, $cmdexec );
				is( ! -f $copiedf, 1, $copiedf.q( is moved) );
				is( -f '/tmp/'.$inputfn, 1, q(Backup: /tmp/).$inputfn );
				unlink($copiedf) if( -w $copiedf );
				unlink('/tmp/'.$inputfn) if( -w '/tmp/'.$inputfn);
			}
			else
			{
				$cmdexec = $command.qq| $o > /dev/null|;
				$xstatus = scalar(IPC::Cmd::run('command' => $cmdexec));
				ok( $xstatus, $cmdexec );
				is( -s $copiedf, 0, $copiedf.q( size = 0) ) if( $o eq '--truncate' );
				is( ! -f $copiedf, 1, $copiedf.q( is removed) ) if( $o eq '--remove' );
				unlink($copiedf) if( -w $copiedf );
			}
		}
	}
}

__END__

