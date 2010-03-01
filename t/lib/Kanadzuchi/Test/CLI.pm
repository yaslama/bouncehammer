# $Id: CLI.pm,v 1.10 2010/03/01 21:32:09 ak Exp $
# Kanadzuchi::Test::
                      
  ####  ##     ####   
 ##  ## ##      ##    
 ##     ##      ##    
 ##     ##      ##    
 ##  ## ##      ##    
  ####  ###### ####   
                      
package Kanadzuchi::Test::CLI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use 5.008001;
use strict;
use warnings;
use base 'Class::Accessor::Fast::XS';
use IPC::Cmd;
use JSON::Syck;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Rewritable accessors
__PACKAGE__->mk_accessors(
	'perl',		# (String) Path to perl executable
	'sqlite3',	# (String) Path to sqlite3 executable
	'command',	# (String) Path to Command
	'config',	# (String) Path to Config file
	'input',	# (String) Path to input file
	'output',	# (String) Path to output file
	'database',	# (String) Path to database file(SQLite)
	'tempdir',	# (String) Path to output directory
);

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param	<None>
	# @Return	(Kanadzuchi::Test::CLI) Object
	my $class = shift();
	my $argvs = { @_ };

	$argvs->{'tempdir'} = q(./.test) unless(defined($argvs->{'tempdir'}));
	$argvs->{'perl'} = IPC::Cmd::can_run('perl') || q(/usr/bin/perl);
	$argvs->{'sqlite3'} = IPC::Cmd::can_run('sqlite3') || q(/usr/bin/sqlite3);
	chomp($argvs->{'perl'});
	chomp($argvs->{'sqlite3'});

	IPC::Cmd::run( command => qq(mkdir -p $argvs->{'tempdir'}) ) unless( -d $argvs->{'tempdir'} );
	return( $class->SUPER::new($argvs) );
}

sub logfiles
{
	# +-+-+-+-+-+-+-+-+
	# |l|o|g|f|i|l|e|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Return log file list as a array reference
	# @Param	<None>
	# @Return	(Ref->Array) Log file list
	my $class =  shift();
	my $files = [
		{ file => 'hammer.2008-08-20.log', entity => 1, },
		{ file => 'hammer.2008-08-28.log', entity => 1, },
		{ file => 'hammer.2008-09-07.log', entity => 1, },
		{ file => 'hammer.2008-09-17.log', entity => 1, },
		{ file => 'hammer.2008-09-18.log', entity => 1, },
		{ file => 'hammer.2008-09-20.log', entity => 2, },
		{ file => 'hammer.2008-09-21.log', entity => 1, },
		{ file => 'hammer.2008-12-08.log', entity => 1, },
		{ file => 'hammer.2009-01-10.log', entity => 1, },
		{ file => 'hammer.2009-02-05.log', entity => 1, },
		{ file => 'hammer.2009-02-09.log', entity => 1, },
		{ file => 'hammer.2009-02-10.log', entity => 1, },
		{ file => 'hammer.2009-03-05.log', entity => 1, },
		{ file => 'hammer.2009-03-11.log', entity => 1, },
		{ file => 'hammer.2009-04-16.log', entity => 1, },
		{ file => 'hammer.2009-04-18.log', entity => 1, },
		{ file => 'hammer.2009-04-27.log', entity => 7, },
		{ file => 'hammer.2009-04-28.log', entity => 12, },
		{ file => 'hammer.2009-07-17.log', entity => 1, },
	];

	return($files);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub environment
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |e|n|v|i|r|o|n|m|e|n|t|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Check environment for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $test = shift() || 0;
	my $eerr = 0;

	EXECUTABLE: foreach my $x ( 'perl', 'sqlite3', 'tempdir' )
	{
		next() if( -x $self->{$x} );
		next() if( $test > 0 );
		printf( STDERR "NG: %s is not executable\n", $self->{$x} );
		$eerr++;
	}

	READABLE: foreach my $r ( 'tempdir', 'config', 'input', 'command' )
	{
		next() if( -r $self->{$r} );
		printf( STDERR "NG: %s is not readable\n", $self->{$r} );
		$eerr++;
	}

	WRITABLE: foreach my $w ( 'tempdir' )
	{
		next() if( -w $self->{$w} );
		printf( STDERR "NG: %s is not writable\n", $self->{$w} );
		$eerr++;
	}

	if( $test != 2 )
	{
		$self->{'perl'} .= q{ -I./lib -I./dist/lib -I./src/lib };
		$self->{'command'} .= q{ };
	}

	return(0) if( $eerr );
	return(1);
}

sub syntax
{
	# +-+-+-+-+-+-+
	# |s|y|n|t|a|x|
	# +-+-+-+-+-+-+
	#
	# @Description	Check syntax for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $command = qq|$self->{'perl'} -cw $self->{'command'} > /dev/null 2>&1|;
	return( scalar(IPC::Cmd::run( 'command' => $command )) );
}

sub version
{
	# +-+-+-+-+-+-+-+
	# |v|e|r|s|i|o|n|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Check version number for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $command = qq|$self->{'perl'} $self->{'command'} --version|;
	my @xresult = IPC::Cmd::run( 'command' => $command );

	use Kanadzuchi;
	return(1) if( $xresult[$#xresult]->[0] =~ m{\A$Kanadzuchi::VERSION} );
	return(0);
}

sub help
{
	# +-+-+-+-+
	# |h|e|l|p|
	# +-+-+-+-+
	#
	# @Description	Check help message for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $command = qq|$self->{'perl'} $self->{'command'} --help|;
	return( scalar(IPC::Cmd::run( 'command' => $command )) );
}

sub error
{
	# +-+-+-+-+-+
	# |e|r|r|o|r|
	# +-+-+-+-+-+
	#
	# @Description	Check error message for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $exto = shift() || q();
	my $command = q();
	my $xresult = [];
	my $nerrors = 1;

	CONFIG_FILE: {
		$command = qq|$self->{'perl'} $self->{'command'} $exto -C /non-existent|;
		$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
		$nerrors++ if( $xresult->[4]->[0] =~ m{Config file does not exist at} );

		$command = qq|$self->{'perl'} $self->{'command'} $exto -C /etc/resolv.conf|;
		$xresult = [ IPC::Cmd::run( 'command' => $command ) ];
		$nerrors++ if( $xresult->[4]->[0] =~ m{Is not YAML file at } );
	}
	return($nerrors);
}

sub mailboxparser
{
	my $self = shift() || return(0);
	my $comm = q();
	my $stat = 0;

	return(1) if( -s $self->{'output'} );
	return(0) unless( -s $self->{'input'} );

	$comm .= $self->{'perl'}.q( );
	$comm .= -x q(./dist/bin/mailboxparser) ? q(./dist/bin/mailboxparser) : q(./src/bin/mailboxparser.PL);
	$comm .= q( -C ).$self->{'config'}.q{ }.$self->{'input'};
	$comm .= q( > ).$self->{'output'};
	$stat += scalar(IPC::Cmd::run( 'command' => $comm )) || 0;

	return($stat);
}

sub initdb
{
	# +-+-+-+-+-+-+
	# |i|n|i|t|d|b|
	# +-+-+-+-+-+-+
	#
	# @Description	Initialize the database for testing
	# @Param	<None>
	# @Return	1 or 0
	my $self = shift() || return(0);
	my $init = 0;
	my $sql3 = $self->{'sqlite3'};
	my $dbfn = $self->{'database'};

	$init += scalar(IPC::Cmd::run( command => '/bin/cp /dev/null '.$dbfn )) || 0;
	$init += scalar(IPC::Cmd::run( command => 'cat ./src/sql/SQLite.sql | '.$sql3.q{ }.$dbfn )) || 0;
	$init += scalar(IPC::Cmd::run( command => 'cat ./src/sql/mastertable-*.sql | '.$sql3.q{ }.$dbfn )) || 0;
	$init += scalar(IPC::Cmd::run( command => 'cat ./src/sql/records-example.sql | '.$sql3.q{ }.$dbfn )) || 0;

	return(1) if( $init == 4 );
	return(0);
}

sub senderdomain
{
	my $self = shift() || return(0);
	my $json = JSON::Syck::LoadFile($self->{'output'});
	my $heap = [];
	my $comm = q();
	my $stat = 0;

	foreach my $j ( @$json )
	{
		next() if( grep( { $j->{'senderdomain'} eq $_ } @$heap ) );

		$comm  = q();
		$comm .= $self->{'perl'}.q| |;
		$comm .= -x q(./dist/bin/tablectl) ? q(./dist/bin/tablectl) : q(./src/bin/tablectl.PL);
		$comm .= q| -C |.$self->{'config'};
		$comm .= q| -ts --insert --name |.$j->{'senderdomain'};
		$stat += scalar(IPC::Cmd::run( 'command' => $comm )) || 0;

		push( @$heap, $j->{'senderdomain'} );
	}

	return($stat);
}

sub bouncelog
{
	my $self = shift() || return(0);
	my $comm = q();
	my $stat = 0;

	$comm .= $self->{'perl'}.q{ };
	$comm .= -x q(./dist/bin/databasectl) ? q(./dist/bin/databasectl) : q(./src/bin/databasectl.PL);
	$comm .= q{ -C }.$self->{'config'};
	$comm .= q{ --update }.$self->{'output'};
	$stat += scalar(IPC::Cmd::run( 'command' => $comm )) || 0;

	return($stat);
}

1;
__END__
