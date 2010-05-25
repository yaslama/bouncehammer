# $Id: CLI.pm,v 1.16 2010/05/25 04:48:53 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::
                      
  ####  ##     ####   
 ##  ## ##      ##    
 ##     ##      ##    
 ##     ##      ##    
 ##  ## ##      ##    
  ####  ###### ####   
package Kanadzuchi::UI::CLI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Kanadzuchi;
use Kanadzuchi::Exceptions;
use Error ':try';
use Errno;
use Path::Class;
use File::Spec;
use File::Basename;
use Time::Piece;
use Carp ();

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Read only accessors
__PACKAGE__->mk_ro_accessors( 
	'option',	# (Hashref) Available options
	'calledfrom',	# (String) Script name
	'commandline',	# (String) Command line
	'processid',	# (Integer) Process ID
	'startedat',	# (Time::Piece) Start time
);

# Rewritable accessors
__PACKAGE__->mk_accessors(
	'operation',	# (Integer) Operation code
	'debuglevel',	# (Integer) Debug level
	'silent',	# (Integer) Silent mode
	'tmpdir',	# (Path::Class::Dir) tmp directory
	'pf',		# (Path::Class::File) pid file
	'cf',		# (Path::Class::File) config file
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
	# @Return	(Kanadzuchi::UI::CLI) Object
	my $class = shift();
	my $argvs = { @_ }; 

	DEFAULT_VALUES: {
		$argvs->{'startedat'} = new Time::Piece();
		$argvs->{'processid'} = $$ unless( defined($argvs->{'processid'}) );
		$argvs->{'operation'} = 0 unless( defined($argvs->{'operation'}) );
		$argvs->{'debuglevel'} = 0 unless( defined($argvs->{'debuglevel'}) );
		$argvs->{'calledfrom'} = File::Basename::basename([caller()]->[1]);
		$argvs->{'option'} = {} unless( defined($argvs->{'option'}) );
		$argvs->{'silent'} = 0 unless( defined($argvs->{'silent'}) );

		last() unless( defined($argvs->{'cf'}) );
		last() if( ref($argvs->{'cf'}) eq q|Path::Class::File| );

		if( $argvs->{'cf'} !~ m{[\x00-\x1f\x7f]}  && -e $argvs->{'cf'} )
		{
			$argvs->{'cf'} = new Path::Class::File( $argvs->{'cf'} );
			$argvs->{'cf'}->cleanup();
		}
	}

	return( $class->SUPER::new($argvs) );
}

sub is_machine
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|m|a|c|h|i|n|e|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	The user is a machine or not
	# @Param	<None>
	# @Return	(Integer) 1 = Executed by machine
	#		(Integer) 0 = Executed by not machine
	my $class = shift();
	return(0) if( $ENV{'SHELL'} && $ENV{'USER'} & $ENV{'LOGNAME'} & $ENV{'HOME'} );
	return(1);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub init
{
	# +-+-+-+-+
	# |i|n|i|t|
	# +-+-+-+-+
	#
	# @Description	Initialize Kanadzuchi object
	# @Param	<None>
	# @Return	(Integer) 1 = Successfully initialized
	#		exit(1) = Failed to initialize.
	my $self = shift();
	my $dzci = shift();

	# Remove Tainted variables, Set the character 'C' in language vars.
	delete( @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'} ); 
	$ENV{'LANG'} = q(C);
	$ENV{'LC_ALL'} = q(C);

	# Check process
	try {
		my( $_error, $_piddn, $_pidFH, $_tempd, $_kconf );

		#   ___  _     _           _     _____         _   
		#  / _ \| |__ (_) ___  ___| |_  |_   _|__  ___| |_ 
		# | | | | '_ \| |/ _ \/ __| __|   | |/ _ \/ __| __|
		# | |_| | |_) | |  __/ (__| |_    | |  __/\__ \ |_ 
		#  \___/|_.__// |\___|\___|\__|   |_|\___||___/\__|
		#           |__/                                   
		if( ! defined($dzci) || ref($dzci) ne q|Kanadzuchi| )
		{
			$_error = q{No system object, errno = }.Errno::EINVAL;
			Kanadzuchi::Exception::System->throw( '-text' => $_error );
		}

		$_kconf = $dzci->config();
		if( ! defined($_kconf->{'system'}) && ! defined($_kconf->{'version'}) )
		{
			$_error = q{Config file is not loaded, errno = }.Errno::EINVAL;
			Kanadzuchi::Exception::System->throw( '-text' => $_error );
		}

		#  _____                          _ _      
		# |_   _|__ _ __ ___  _ __     __| (_)_ __ 
		#   | |/ _ \ '_ ` _ \| '_ \   / _` | | '__|
		#   | |  __/ | | | | | |_) | | (_| | | |   
		#   |_|\___|_| |_| |_| .__/   \__,_|_|_|   
		#                    |_|                   
		# Create the temporary directory
		$_tempd  = $_kconf->{'directory'}->{'tmp'};
		$_tempd  = File::Spec->tmpdir() if( $_tempd eq q() || $_tempd eq '/' || $_tempd =~ m{\A[.]/?\z} );
		$_tempd  = File::Spec->tmpdir() if( ! -d $_tempd || ! -r _ || ! -w _ || ! -x _ );
		$_tempd .= q(/).$_kconf->{'system'}.q(.).$self->{'processid'};

		eval {
			$self->{'tmpdir'} = new Path::Class::Dir($_tempd);
			$self->{'tmpdir'}->cleanup();
			$self->{'tmpdir'}->mkpath() unless( -e $self->{'tmpdir'} );
		};
		Kanadzuchi::Exception::Permission->throw( '-text' => $@ ) if($@);

		#        _     _ 
		#  _ __ (_) __| |
		# | '_ \| |/ _` |
		# | |_) | | (_| |
		# | .__/|_|\__,_|
		# |_|            
		$_piddn = -w $_kconf->{'directory'}->{'pid'} ? $_kconf->{'directory'}->{'pid'} : $self->{'tmpdir'};
		$self->{'pf'} = new Path::Class::File( sprintf("%s/%s.%d.pid", $_piddn, $self->{'calledfrom'}, $$ ));

		if( -e $self->{'pf'} )
		{
			$_error = $self->{'pf'}.q{: pid file exists, errno = }.Errno::EEXIST;
			Kanadzuchi::Exception::System->throw( '-text' => $_error );
		}

		eval {
			$self->{'pf'}->touch();
			$_pidFH = $self->{'pf'}->openw();
		};
		Kanadzuchi::Exception::Permission->throw( '-text' => $@ ) if($@);

		printf( $_pidFH "%d\n", $$ );
		printf( $_pidFH "%s\n", $self->{'commandline'} );
		$_pidFH->close();
	}
	otherwise {
		$self->exception(shift());
		$self->abort();
	};

	$self->d(1,sprintf( "%s/%s %s\n", $dzci->myname(), $self->{'calledfrom'}, $dzci->version() ));
	$self->d(1,sprintf( "Command started at %s\n", $self->{'startedat'}->cdate() ));
	$self->d(1,sprintf( "Process ID = %d\n", $self->{'processid'} ));
	$self->d(2,sprintf( "Pid file = %s\n", $self->{'pf'} ));
	$self->d(2,sprintf( "Operation = %d [%024b]\n", $self->{'operation'}, $self->{'operation'} ));
	$self->d(2,sprintf( "Temporary directory = %s\n", $self->{'tmpdir'} ) );
	$self->d(1,sprintf( "Debug level = %d\n", $self->{'debuglevel'} ));

	return(1);
}

sub batchstatus
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |b|a|t|c|h|s|t|a|t|u|s|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Print batch job status to STDOUT
	# @Param <ref>	(Ref->Scalar) Additional status information
	# @Return	1
	my $self = shift();
	my $stat = shift();
	my $time = Time::Piece->new();
	my $load = qx(uptime); chomp($load);

	# Block style YAML(is not JSON) format
	printf( STDOUT qq|--- # %s %s command status\n|, $self->{'startedat'}->ymd('-'), $self->{'calledfrom'} );
	printf( STDOUT qq|command: "%s"\n|, $self->{'calledfrom'} );
	printf( STDOUT qq|arguments: "%s"\n|, $self->{'commandline'} );
	printf( STDOUT qq|user: "%s"\n|, $ENV{'USER'} || $ENV{'LOGNAME'} || q() );
	printf( STDOUT qq|load: "%s"\n|, $load );
	printf( STDOUT qq|time:\n| );
	printf( STDOUT qq|  started: "%s"\n|, $self->{'startedat'}->cdate() );
	printf( STDOUT qq|  ended:   "%s"\n|, $time->cdate() );
	printf( STDOUT qq|  elapsed: %d\n|, $time->epoch() - $self->{'startedat'}->epoch() );

	return(1) unless( length($$stat) );
	printf( STDOUT qq|status:\n| );
	printf( STDOUT $$stat );
	return(1)
}

sub d
{
	# +-+
	# |d|
	# +-+
	#
	# @Description	Print debug message to Standard-Error device
	# @Param <Lv>	(Integer) debug level
	# @Param <Msg>	(String) debug message
	# @Return	(String) Empty or debug message
	my $self = shift();
	my $dlev = shift() || 0;
	my $argv = shift() || return(q{});
	my $mesg = q();

	return(q{}) if( $self->{'silent'} || $self->{'debuglevel'} < $dlev );

	$mesg = sprintf( qq{ *debug%d: %s}, $dlev, $argv );
	defined(wantarray()) ? return($mesg) : printf( STDERR $mesg );
	return(q{});
}

sub e
{
	# +-+
	# |e|
	# +-+
	#
	# @Description	Print error message to Standard-Error device, and call abort()
	# @Param <Msg>	(String) error message
	# @Return	<None>
	# @See		abort(), DESTROY()
	my $self = shift();
	my $mesg = shift() || return(q{});
	Carp::carp( qq{ ***error: $mesg} ) unless( $self->{'silent'} );
	$self->abort();
}

sub catch_signal
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |c|a|t|c|h|_|s|i|g|n|a|l|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Catch a signal, and exits
	# @Param <sig>	(String) Signal
	# @Return	<None>
	my $self = shift();
	my $sign = shift() || return(0);
	my $mesg = q|***Catch the signal(|.$sign.q|)|;

	if( $sign eq q(ALRM) ){ $mesg = q(Timed out, No data from STDIN); }
	Carp::carp($mesg) if( $self->{'debuglevel'} > 0 && ! $self->{'silent'} );
	$self->abort();
}

sub finish
{
	# +-+-+-+-+-+-+
	# |f|i|n|i|s|h|
	# +-+-+-+-+-+-+
	#
	# @Description	Successfully exits
	# @Param <sig>	<None>
	# @Return	exit(0);
	my $self = shift();
	$self->DESTROY();
	exit(0);
}

sub abort
{
	# +-+-+-+-+-+
	# |a|b|o|r|t|
	# +-+-+-+-+-+
	#
	# @Description	Abort processing, exits with status code 1.
	# @Param	<None>
	# @Return	<None>
	# @See		e(), DESTROY()
	my $self = shift();
	printf( STDERR qq{ ***abort\n} ) if( $self->{'debuglevel'} > 0 && ! $self->{'silent'} );
	$self->DESTROY();

	if( __PACKAGE__->is_machine() )
	{
		# Ignore error if the user is a machine
		exit(0) if( $self->{'silent'} );

		# exit(75) When it called from an MTA
		#  * sendmail = sendmail-8.14.3/{cf/README,doc/op/op.me}
		#  * postfix = http://www.postfix.org/local.8.html
		#  * qmail = http://www.lifewithqmail.org/lwq.html#environment-variables
		exit(75);
	}
	else
	{
		exit(1);
	}
}

sub DESTROY
{
	# +-+-+-+-+-+-+-+
	# |d|e|s|t|r|o|y|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Destroy files and directories that created by Kanadzuchi object
	# @Param	<None>
	# @Return	(Integer) 1 = Always
	# @See		UI::CLI::e(), abort()
	my $self = shift();
	if( defined($self->{'pf'}) && -w $self->{'pf'} )
	{
		$self->{'pf'}->remove();
	}

	if( defined($self->{'tmpdir'}) && $self->{'tmpdir'}->is_dir() && -w $self->{'tmpdir'} )
	{
		$self->{'tmpdir'}->rmtree() if( $self->{'tmpdir'}->is_dir() );
	}
	return(1);
}

sub exception
{
	# +-+-+-+-+-+-+-+-+-+
	# |e|x|c|e|p|t|i|o|n|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Print exceptional message
	# @Param <obj>	(Kanadzuchi::Exception) object
	my $self = shift();
	my $eobj = shift();
	my $head = q{E};

	eval{ $head ||= $eobj->head(); };
	unless( $self->{'silent'} )
	{
		printf( STDERR qq{ ***error: [%s] %s [%s:%d]\n}, 
			$head, $eobj->{'-text'}, $eobj->{'-file'}, $eobj->{'-line'} );
	}
}

1;
