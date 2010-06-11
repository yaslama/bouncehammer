# $Id: Kanadzuchi.pm,v 1.23 2010/06/09 05:24:30 ak Exp $
# -Id: TheHammer.pm,v 1.4 2009/09/01 23:19:41 ak Exp -
# -Id: Herculaneum.pm,v 1.13 2009/08/27 05:09:23 ak Exp -
# -Id: Version.pm,v 1.35 2009/08/27 05:09:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.

 ##  ##                           ##                      ##      ##    
 ## ##    ####  #####   ####      ##  ###### ##  ##  #### ##            
 ####        ## ##  ##     ##  #####     ##  ##  ## ##    #####  ###    
 ####     ##### ##  ##  ##### ##  ##    ##   ##  ## ##    ##  ##  ##    
 ## ##   ##  ## ##  ## ##  ## ##  ##   ##    ##  ## ##    ##  ##  ##    
 ##  ##   ##### ##  ##  #####  #####  ######  #####  #### ##  ## ####   
package Kanadzuchi;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use 5.008001;
use warnings;
use base 'Class::Accessor::Fast::XS';
use Kanadzuchi::Exceptions;
use Time::Piece;
use Error ':try';
use Errno;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Read only accessors
__PACKAGE__->mk_ro_accessors(
	'myname',	# (String) System name
	'version',	# (String) Version number, ex(3.1.4)
	'user',		# (Integer) User ID, root = 0
);

# Rewritable accessors
__PACKAGE__->mk_accessors(
	'config',	# (Ref->Hash) Contents of config file
);

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
our $VERSION = q{2.3.4};
our $SYSNAME = q{BounceHammer};
our $SYSCONF = q{__KANADZUCHIROOT__/etc/bouncehammer.cf};

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
	# @Return	(Kanadzuchi) Object
	my $class = shift();
	my $argvs = { 
		'myname' => $class || __PACKAGE__,
		'version' => $VERSION,
		'user' => $>, 
		'config' => {}, };

	return( $class->SUPER::new( $argvs ) );
}

sub is_exception
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|e|x|c|e|p|t|i|o|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	The class is Kanadzuchi::Exception::* or not
	# @Param <ref>	(Ref->*) Reference to something
	# @Return	(Integer) 1 = is Kanadzuchi::Exception::* class
	#		(Integer) 0 = Is not
	my $class = shift();
	my $excep = shift() || return(0);
	return(1) if( ref($excep) =~ m{\AKanadzuchi::Exception::} );
	return(0);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub load
{
	# +-+-+-+-+
	# |l|o|a|d|
	# +-+-+-+-+
	#
	# @Description	Load configuration
	# @Param	(String) Path to the config file
	# @Return	(Integer) 1 = Successfully loaded
	#		(Integer) 0 = Not loaded
	my $self = shift();
	my $conf = shift() || $SYSCONF;
	my $exception;		# (String)

	return(0) if( $self->{'config'}->{'system'} );	# Already loaded

	$conf = $conf->stringify() if( ref($conf) eq q|Path::Class::File| );

	if( $conf ne q{/dev/null} )
	{
		# Read the config file
		use Kanadzuchi::Metadata;

		try {
			#  _____ _ _        _____         _   
			# |  ___(_) | ___  |_   _|__  ___| |_ 
			# | |_  | | |/ _ \   | |/ _ \/ __| __|
			# |  _| | | |  __/   | |  __/\__ \ |_ 
			# |_|   |_|_|\___|   |_|\___||___/\__|
			#                                     
			my $et;		# (String) Error text

			if( ! -e $conf )
			{
				$et = $conf.q{: Config file does not exist, errno = }.Errno::ENOENT;
				Kanadzuchi::Exception::IO->throw( '-text' => $et );
			}

			if( $conf =~ m{[\x00-\x1f\x7f]} )
			{
				$et = $conf.q{: Invalid config file name, errno = }.Errno::EINVAL;
				Kanadzuchi::Exception::File->throw( '-text' => $et );
			}

			if( ! -T $conf )
			{
				$et = $conf.q{: is not a text file, errno = }.Errno::EFTYPE;
				Kanadzuchi::Exception::File->throw( '-text' => $et );
			}

			if( ! -r $conf )
			{
				$et = $conf.q{: Cannot read, errno = }.Errno::EACCES;
				Kanadzuchi::Exception::Permission->throw( -text => $et );
			}

			#  _                    _    ____             __ _       
			# | |    ___   __ _  __| |  / ___|___  _ __  / _(_) __ _ 
			# | |   / _ \ / _` |/ _` | | |   / _ \| '_ \| |_| |/ _` |
			# | |__| (_) | (_| | (_| | | |__| (_) | | | |  _| | (_| |
			# |_____\___/ \__,_|\__,_|  \____\___/|_| |_|_| |_|\__, |
			#                                                  |___/ 
			# Load the config file
			$self->{'config'} = shift( @{Kanadzuchi::Metadata->to_object($conf)} );

			#  _____                          _     _____         _   
			# |  ___|__  _ __ _ __ ___   __ _| |_  |_   _|__  ___| |_ 
			# | |_ / _ \| '__| '_ ` _ \ / _` | __|   | |/ _ \/ __| __|
			# |  _| (_) | |  | | | | | | (_| | |_    | |  __/\__ \ |_ 
			# |_|  \___/|_|  |_| |_| |_|\__,_|\__|   |_|\___||___/\__|
			#                                                         
			if( ref($self->{'config'}) ne q|HASH| )
			{
				$et = $conf.q{: is not YAML/JSON file, errno = }.Errno::EFTYPE;
				Kanadzuchi::Exception::File->throw( '-text' => $et );
			}

			if( ! defined($self->{'config'}->{'system'}) && ! defined($self->{'config'}->{'version'}) )
			{
				$et = $conf.q{: It does not seem to config file of this system, errno = }.Errno::EFTYPE;
				Kanadzuchi::Exception::Config->throw( '-text' => $et );
			}
		}
		otherwise {
			$exception = shift();
		};
	}
	else
	{
		# Test mode
		require Kanadzuchi::Config::TestRun;
		$self->{'config'} = $Kanadzuchi::Config::TestRun::Configuration;
	}

	return($exception) if( $exception );
	return(1);
}

sub is_logfile
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|l|o|g|f|i|l|e|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	The file is a valid BounceHammer log file name
	# @Param <str>	(String) File name or (Path::Class::File) object
	# @Return	(Integer) 1 = Is valid temporary file name
	#		(Integer) 2 = Is valid regular file name
	#		(Integer) 0 = Is not
	my $self = shift();
	my $file = shift() || return(0);
	my $logf = ref($file) =~ m{\APath::Class::File} ? $file->stringify() : $file;
	my( $conf, $tstr, $trex, $rstr, $rrex );

	# Check file name
	$conf = $self->{'config'}->{'file'} || return(0);
	$tstr = sprintf("%s.\\d{4}-\\d{2}-\\d{2}.[0-9A-Fa-f]{8}.[0-9A-Fa-f]{6}.%s",
				$conf->{'templog'}->{'prefix'}, 
				$conf->{'templog'}->{'suffix'} );
	$rstr = sprintf("%s.\\d{4}-\\d{2}-\\d{2}.%s",
				$conf->{'storage'}->{'prefix'}, 
				$conf->{'storage'}->{'suffix'} );
	$trex = qr{/?$tstr\z}oi;	# Regualr expression for temporary log file
	$rrex = qr{/?$rstr\z}oi;	# Regular expression for saved log file

	return(2) if( $logf =~ $rrex );
	return(1) if( $logf =~ $trex );
	return(0);
}

sub get_logfile
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|_|l|o|g|f|i|l|e|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Returns Kanadzuchi's log file name
	# @Param <str>	(String) File type(regular,temp,fallback)
	# @Param <opt>	(Ref->Hash) File name options
	# @Return	(String) Log file name
	my $self = shift();
	my $type = shift() || q(temp);
	my $lopt = shift() || { 'date' => q(), 'output' => q() };

	my $char = substr(lc($type),0,1) || q(t);
	my $conf = $self->{'config'};
	my $time = bless(localtime(),'Time::Piece');
	my $logf = $conf->{'file'}->{'storage'};
	my $file = q();

	$lopt->{'date'} = $time->ymd('-') unless( defined($lopt->{'date'}) );
	$lopt->{'date'} = $time->ymd('-') unless( $lopt->{'date'} =~ m{\A\d{4}[-]\d{2}[-]\d{2}\z} );

	if( $char eq 'r' )
	{
		# Regular log file name
		$lopt->{'output'} = $conf->{'directory'}->{'log'} if( ! defined($lopt->{'output'}) || -d $lopt->{'output'} );
		$lopt->{'output'} =~ s{/\z}{}g;
		$file = sprintf("%s/%s.%s.%s",
				$lopt->{'output'}, $logf->{'prefix'}, $lopt->{'date'}, $logf->{'suffix'} );
	}
	else
	{
		my( $_rand, $_time );
		$lopt->{'output'} = $conf->{'directory'}->{'spool'} unless( -d $lopt->{'output'} );
		$lopt->{'output'} =~ s{/\z}{}g;
		$logf = $conf->{'file'}->{'templog'};

		if( $char eq 't' )
		{
			# Temporary Log file name
			while(1)
			{
				$_rand = $$ + int(rand() * 10);
				$_time = $time->epoch();
				$file = sprintf("%s/%s.%s.%08x.%06x.%s", 
						$lopt->{'output'}, $logf->{'prefix'}, $lopt->{'date'},
						$_time, $_rand, $logf->{'suffix'} );
				last() unless( -e $file );
			}
		}
		elsif( $char eq 'f' )
		{
			# Log file name for the fallback
			while(1)
			{
				$_rand = ( 2 ** 24 - 1 ) ^ $$ - int(rand() * 10);
				$_time = ~$time->epoch();
				$file = sprintf("%s/%s.%s.%08x.%06x.%s", 
						$lopt->{'output'}, $logf->{'prefix'}, $lopt->{'date'},
						$_time, $_rand, $logf->{'suffix'} );
				last() unless( -e $file );
			}
		}
		elsif( $char eq 'm' )
		{
			# Log file name for mergence
			while(1)
			{
				$_rand = ( 2 ** 24 - 1 ) ^ $$ / 2;
				$_time = $time->epoch() / 10;
				$file = sprintf("%s/%s.%s.%08x.%06x.%s", 
						$lopt->{'output'}, $logf->{'prefix'}, $lopt->{'date'},
						$_time, $_rand, $logf->{'suffix'} );
				last() unless( -e $file );
			}
		}
	}

	return($file);
}

1;
__END__
