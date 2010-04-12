# $Id: 501_bin-logger.t,v 1.6 2010/04/12 05:47:06 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 239 );

SKIP: {
	eval{ require IPC::Cmd; }; 
	skip('Because no IPC::Cmd for testing',239) if($@);

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
			'command' => -x q(./dist/bin/logger) ? q(./dist/bin/logger) : q(./src/bin/logger.PL),
			'config' => q(./src/etc/prove.cf),
			'input' => q(./examples/17-messages.eml),
			'output' => q(./.test/hammer.1970-01-01.ffffffff.000000.tmp),
			'tempdir' => q(./.test),
	);

	my $O = q| -C|.$E->config();
	my $LogFiles = Kanadzuchi::Test::CLI->logfiles();

	my $Suite = [
		{
			'name' => 'List of log files',
			'option' => $O.q( --list),
			'expect' => 1,
			'wantresult' => 1,
		},
		{
			'name' => 'Specify a file',
			'option' => $O.q( -c ).$E->output(),
		},
		{
			'name' => 'Specify a directory',
			'option' => $O.q( -c ).$E->tempdir(),
		},
		{
			'name' => 'Specify a directory and remove temp logs',
			'option' => $O.q( -c ).$E->tempdir().q( --remove ),
		},
		{
			'name' => 'Specify a directory and truncate temp logs',
			'option' => $O.q( -c ).$E->tempdir().q( --truncate ),
		},
	];

	#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
	# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
	# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
	# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
	#
	PREPROCESS: {
		$K->load($E->config());
		File::Copy::copy( q{../examples/}.File::Basename::basename($E->output()),
					$E->tempdir().q{/}.File::Basename::basename($E->output()) );
		File::Copy::copy( $E->output(), $E->output.q{.bak} ) if( -s $E->output() );
		File::Copy::copy( $E->output().q{.bak}, $E->output() ) if( -s $E->output().q{.bak} );

		ok( $E->environment(1), q{->environment(1)} );
		ok( $E->syntax(), q{->syntax()} );
		ok( $E->version(), q{->version()} );
		ok( $E->help(), q{->help()} );
		ok( $E->error('-c'), q{->error()} );
		ok( $E->mailboxparser(), q{(mailboxparser) ->mailboxparser()} );

		CLEANUP: foreach my $f ( @$LogFiles )
		{
			next() unless( -f $E->tempdir().q(/).$f->{'file'} );
			truncate( $E->tempdir().q(/).$f->{'file'}, 0 );
		}
	}

	ERROR_MESSAGES: {
		my $command = q();
		my $xresult = [];
	}

	EXECUTE: foreach my $s ( @$Suite )
	{
		my $command = $E->perl().$E->command().$s->{'option'};
		my $xresult = q();

		if( $s->{'wantresult'} )
		{
			$xresult = qx($command); chomp($xresult);
			ok( $xresult >= $s->{'expect'}, $s->{'name'} );
		}
		else
		{
			File::Copy::copy( $E->output().q{.bak}, $E->output() ) if( -s $E->output().q{.bak} );

			$xresult = scalar(IPC::Cmd::run( 'command' => $command ));
			ok( $xresult, $s->{'name'}.q{: }.$command );

			LOGFILE: foreach my $f ( @$LogFiles )
			{
				my $yaml = undef();
				my $file = $E->tempdir().q(/).$f->{'file'};

				SKIP: {
					skip( 'No log file', 3 ) unless( -e $file );

					$yaml = JSON::Syck::LoadFile( $file );
					isa_ok( $yaml, q|ARRAY|, $f->{'file'}.q{ is Array(JSON)} );
					ok( scalar(@$yaml) > 0, $f->{'file'}.q{ has }.$f->{'entity'}.q{ records} );
					is( $K->is_logfile($f->{'file'}), 2, $f->{'file'}.q{ is regular log file} );

					unlink( $file ) if( -e $file );
				}
			}
		}
	}

	POSTPROCESS: {
		File::Copy::copy( $E->output().q{.bak}, $E->output() ) if( -s $E->output().q{.bak} );
	}

}


__END__
