#__PERLEXECUTABLE__
# $Id: logger.PL,v 1.5 2010/03/06 04:35:35 ak Exp $
# -Id: logger.PL,v 1.13 2010/02/21 20:09:01 ak Exp -
# -Id: logger.PL,v 1.1 2009/08/29 14:36:53 ak Exp -
# -Id: logger.PL,v 1.12 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Command::
                                           
  ###                                      
   ##   ####   #####  #####  ####  #####   
   ##  ##  ## ##  ## ##  ## ##  ## ##  ##  
   ##  ##  ## ##  ## ##  ## ###### ##      
   ##  ##  ##  #####  ##### ##     ##      
  ####  ####      ##     ##  ####  ##      
              #####  #####                 
package Kanadzuchi::Command::Logger;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use Kanadzuchi;
use Kanadzuchi::UI::CLI;
use Error ':try';
use Digest::MD5;
use Time::Piece;
use Path::Class::File::Lockable;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci = undef();		# Kanadzuchi System object
my $Cmd = undef();		# Kanadzuchi::UI::CLI object
my $Templd = undef();		# Temp Log Dir, Path::Class::Dir object
my $Templf = undef();		# Temp Log File, Path::Class::File object

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'concatenate'	=> ( 1 << 2 ),
	'list'		=> ( 1 << 3 ),
	'truncate'	=> ( 1 << 4 ),
	'remove'	=> ( 1 << 5 ),
	'strict'	=> ( 1 << 6 ),
};

#  __  __    _    ___ _   _ 
# |  \/  |  / \  |_ _| \ | |
# | |\/| | / _ \  | ||  \| |
# | |  | |/ ___ \ | || |\  |
# |_|  |_/_/   \_\___|_| \_|
#
# Create Kanadzuchi object
$Zci = new Kanadzuchi();
$Cmd = new Kanadzuchi::UI::CLI(
		'option' => $CLIOPTION,
		'commandline' => join(q{ }, $0, @ARGV ));

# Parse options, initialize object
try {
	if( $Cmd->operation( parse_options() ) == 0 )
	{
		Kanadzuchi::Exception::Command->throw( '-text' => q(Try --help) );
	}

	my $_load = $Zci->load( $Cmd->cf() );
	if( Kanadzuchi->is_exception($_load) )
	{
		Kanadzuchi::Exception::System->throw( '-text' => $_load );
	}

	$Cmd->init( $Zci );
	$Cmd->d( 1, sprintf( "Config file = %s\n", $Cmd->cf() ));
}
otherwise {
	$Cmd->exception(shift());
	$Cmd->abort();
};


# Set signal handlers
foreach my $__sig qw( INT QUIT TERM KILL )
{
	$SIG{$__sig} = sub { $Cmd->catch_signal($__sig); };
}

if( $Cmd->operation & ( $Cmd->option->{'concatenate'} + $Cmd->option->{'list'} ) )
{
	#   ____ ___  _   _  ____    _  _____ _____ _   _    _  _____ _____ 
	#  / ___/ _ \| \ | |/ ___|  / \|_   _| ____| \ | |  / \|_   _| ____|
	# | |  | | | |  \| | |     / _ \ | | |  _| |  \| | / _ \ | | |  _|  
	# | |__| |_| | |\  | |___ / ___ \| | | |___| |\  |/ ___ \| | | |___ 
	#  \____\___/|_| \_|\____/_/   \_\_| |_____|_| \_/_/   \_\_| |_____|
	# 
	my $_tmploghashes = {};		# File digest as a hash key
	my $_recordhashes = {};		# Record digest as a hash key
	my $_arrangedlogs = [];		# Array reference of each temporary logs(Path::Class::File)
	my $_string_tlogs = sprintf("%s.\\d{4}-\\d{2}-\\d{2}.[0-9A-Fa-f]{8}.[0-9A-Fa-f]{6}.%s",
					$Zci->config->{'file'}->{'templog'}->{'prefix'}, 
					$Zci->config->{'file'}->{'templog'}->{'suffix'} );
	my $_regexp_tlogs = qr{$_string_tlogs\z}oi;

	$Templd = new Path::Class::Dir($Templf->parent->stringify()) if( defined($Templf) );
	$Templd = new Path::Class::Dir($Zci->config->{'directory'}->{'spool'}) unless(defined($Templd));


	my( $__md5digestv, $__tmppcflock,  $__tmplf4find );
	FIND_TEMPLOG_FILES: while( my $__f = $Templd->next() )
	{
		#  _____ ___ _   _ ____    _____ __  __ ____  _     ___   ____ 
		# |  ___|_ _| \ | |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
		# | |_   | ||  \| | | | |   | | | |\/| | |_) | |  | | | | |  _ 
		# |  _|  | || |\  | |_| |   | | | |  | |  __/| |__| |_| | |_| |
		# |_|   |___|_| \_|____/    |_| |_|  |_|_|   |_____\___/ \____|
		#
		$__md5digestv = undef();	# Digest::MD5 object
		$__tmppcflock = undef();	# Path::Class::File::Lockable
		$__tmplf4find = \$__f->stringify();

		if( defined($Templf) )
		{
			# Is not the log file which specified with -f option
			next() unless( $$__tmplf4find eq $Templf->stringify );
		}
		else
		{
			# Does not match with regular expression
			next() unless( $$__tmplf4find =~ $_regexp_tlogs );
		}
		next() if( $__f->is_dir() );		# The file is not a file
		next() if( ! -f $$__tmplf4find );	# The file is not a regular file
		next() if( ! -T $$__tmplf4find );	# The file is not a text file

		if( -z $__f->stringify() )
		{
			# Is empty file
			eval{ $__f->remove() if( $Cmd->operation & $Cmd->option->{'remove'} ); };
			next();
		}

		# Create MD5 Digest of the file
		$__md5digestv = Digest::MD5->new()->addfile($__f->openr())->hexdigest();
		$__tmppcflock = new Path::Class::File::Lockable($__f);

		if( defined($_tmploghashes->{$__md5digestv}) && -r $_tmploghashes->{$__md5digestv} )
		{
			# Temporary log file is now locked
			next() if( $__tmppcflock->locked() );

			# If the file has same digest, remove it and skip.
			eval{ truncate($$__tmplf4find,0) } if( $Cmd->operation & $Cmd->option->{truncate} );
			if( $Cmd->operation & $Cmd->option->{'remove'} )
			{
				eval{ $__f->remove(); };
				$Cmd->d(6,sprintf("Remove log file(has same digest) = %s\n", $$__tmplf4find )) unless($@);
			}
			next();
		}

		# Record the file name using MD5 Digest as a hash key
		$_tmploghashes->{$__md5digestv} = $$__tmplf4find;
		push( @{$_arrangedlogs}, $__tmppcflock );
		$Cmd->d(5, sprintf("Temporary log file(#%d) = %s (%s)\n", scalar(@{$_arrangedlogs}), $$__tmplf4find, $__md5digestv ));

		# Put temporary log file name in Verbosed List mode.
		if( $Cmd->operation & $Cmd->option->{'list'} && $Cmd->debuglevel > -1 )
		{
			printf( STDOUT "%s\n", $$__tmplf4find ) 
		}

	} # End of the loop(while())

	$Cmd->d(3,sprintf("The number of temporary logs = %d\n", scalar(@{$_arrangedlogs})));



	# There is no temporary log file.
	if( scalar(@{$_arrangedlogs}) == 0 )
	{
		$Cmd->d(1,q{There is no temporary log file}.qq{\n} );
		$Cmd->finish();
	}

	# File List Only: Print the number of temporary log files and exit(0).
	if( $Cmd->operation & $Cmd->option->{'list'} )
	{
		printf( STDOUT "%s\n", scalar(@{$_arrangedlogs}) );
		$Cmd->finish();
	}

	# Read temporary log files
	require Kanadzuchi::Mail::Stored::YAML;
	require Kanadzuchi::Log;

	my $_templogfiles = [];		# Array reference, holds Path::Class::File object of Temp log
	my $_bmesgsbydate = {};		# Hash reference, key is '2009-01-03', value is pointer to array

	# Prepare progress bar
	my $_tprogressbar = undef();	# Term::ProgressBar object for temporary logs
	if( $Cmd->debuglevel > -1 )
	{
		eval{ require Term::ProgressBar; };
		$_tprogressbar = new Term::ProgressBar( { 
					'fh' => \*STDERR,
					'ETA' => q(linear),
					'name' => q(Parse Temp Logs),
					'count' => scalar(@{$_arrangedlogs}),
				});
	}

	LOAD_TEMPLOG_FILES: foreach my $__f ( @{$_arrangedlogs} )
	{
		#  _     ___    _    ____    _____ __  __ ____  _     ___   ____ 
		# | |   / _ \  / \  |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
		# | |  | | | |/ _ \ | | | |   | | | |\/| | |_) | |  | | | | |  _ 
		# | |__| |_| / ___ \| |_| |   | | | |  | |  __/| |__| |_| | |_| |
		# |_____\___/_/   \_\____/    |_| |_|  |_|_|   |_____\___/ \____|
		# 
		my $__arref = [];

		try {
			$__arref = Kanadzuchi::Mail::Stored::YAML->loadandnew($__f,1);

			unless( @$__arref )
			{
				# Failed to load file as a YAML|JSON
				$_tprogressbar->update() if( defined($_tprogressbar) );

				if( defined($Templf) )
				{
					# Only 1 file is given as a temporary log file with -f option.
					Kanadzuchi::Exception::File->throw( 
						'-text' => q{Cannot load the file = }.$__f->stringify() );
				}
				next();
			}
		}
		otherwise {
			$Cmd->exception(shift());
			$Cmd->abort();
		};

		LOAD_RECORDS_IN_TEMPLOG:foreach my $__o ( @$__arref )
		{
			my $__md5digestv = sprintf("%s:%s", $__o->token(), $__o->bounced->epoch() );
			my $__datestring = $__o->bounced->ymd('-');

			# Skip if there is same token 
			next() if( exists($_recordhashes->{$__md5digestv}) );
			$_recordhashes->{$__md5digestv} = 1;

			unless( exists($_bmesgsbydate->{$__datestring}) )
			{
				$_bmesgsbydate->{$__datestring} = [];		# Insert array reference
			}
			push( @{$_bmesgsbydate->{$__datestring}}, $__o );

		} # End of the loop(while())

		push( @{$_templogfiles}, $__f );
		$_tprogressbar->update() if( defined($_tprogressbar) );

	} # End of the loop(for())


	# There is no valid record
	unless( @{$_templogfiles} )
	{
		$Cmd->d(1,q{There is no valid record}.qq{\n} );
		$Cmd->finish(); 
	}

	my $_rprogressbar = undef();	# Term::ProgressBar object for regular logs
	if( $Cmd->debuglevel > -1 )
	{
		eval{ require Term::ProgressBar; };
		$_rprogressbar = new Term::ProgressBar( {
					'fh' => \*STDERR, 
					'ETA' => q(linear),
					'name' => q(Parse Regular Logs),
					'count' => (my $__c = keys(%$_bmesgsbydate)),
				});
	}

	FIND_AND_LOAD_REGULARLOG_FILES:
	foreach my $__key ( sort(keys(%$_bmesgsbydate)) )
	{
		#  _____ ___ _   _ ____    ____  _____ _   _  ____ _        _    ____    _     ___   ____ 
		# |  ___|_ _| \ | |  _ \  |  _ \| ____| | | |/ ___| |      / \  |  _ \  | |   / _ \ / ___|
		# | |_   | ||  \| | | | | | |_) |  _| | | | | |  _| |     / _ \ | |_) | | |  | | | | |  _ 
		# |  _|  | || |\  | |_| | |  _ <| |___| |_| | |_| | |___ / ___ \|  _ <  | |__| |_| | |_| |
		# |_|   |___|_| \_|____/  |_| \_\_____|\___/ \____|_____/_/   \_\_| \_\ |_____\___/ \____|
		# 
		my $__arref = [];		# Array reference of K::M::S::YAML objects
		my $__rlogf = new Path::Class::File(
					sprintf("%s/%s.%s.%s", 
						$Zci->config->{'directory'}->{'log'}, 
						$Zci->config->{'file'}->{'storage'}->{'prefix'},
						$__key, $Zci->config->{'file'}->{'storage'}->{'suffix'} ) );

		next() if( ! -f $__rlogf->stringify() );	# Is not a regular file
		next() if( ! -w $__rlogf->stringify() );	# Cannot write
		next() if( ! -T $__rlogf->stringify() );	# Is not a text file

		$__arref = Kanadzuchi::Mail::Stored::YAML->loadandnew($__rlogf,1);
		next() unless( @$__arref );

		if( $Cmd->operation & $Cmd->option->{'strict'} )
		{
			# Strict mode: check duplicated records in the regular log file
			LOAD_RECORDS_IN_REGULARLOG:foreach my $__o ( @$__arref )
			{
				#  _     ___    _    ____    ____  _____ _   _  ____ _        _    ____    _     ___   ____ 
				# | |   / _ \  / \  |  _ \  |  _ \| ____| | | |/ ___| |      / \  |  _ \  | |   / _ \ / ___|
				# | |  | | | |/ _ \ | | | | | |_) |  _| | | | | |  _| |     / _ \ | |_) | | |  | | | | |  _ 
				# | |__| |_| / ___ \| |_| | |  _ <| |___| |_| | |_| | |___ / ___ \|  _ <  | |__| |_| | |_| |
				# |_____\___/_/   \_\____/  |_| \_\_____|\___/ \____|_____/_/   \_\_| \_\ |_____\___/ \____|
				#  
				my $__md5digestv = sprintf("%s:%s", $__o->token(), $__o->bounced->epoch() );

				# Skip if there is same token
				next () if( exists($_recordhashes->{$__md5digestv}) );

				$_recordhashes->{$__md5digestv} = 1;
				push( @{$_bmesgsbydate->{$__key}}, $__o );

			} # End of the loop(while())
		}
		else
		{
			push( @{$_bmesgsbydate->{$__key}}, @$__arref );
		}
		$_rprogressbar->update() if( defined($_rprogressbar) );

	} # End of the loop(foreach())



	# Create TheHammer::Log object(Temp log + Regular log)
	my $_regularld = undef();	# String, regular log directory
	my $_regularlf = undef();	# String, regular log file
	my $_objherlog = undef();	# TheHammer::Log object


	# Prepare progress bar
	my $_wprogressbar = undef();	# Term::ProgressBar object for writing
	if( $Cmd->debuglevel > -1 )
	{
		$_wprogressbar = new Term::ProgressBar( {
					'fh' => \*STDERR, 
					'ETA' => q(linear),
					'name' => q(Write Regular Logs),
					'count' => (my $__c = keys(%$_bmesgsbydate)),
				});
	}

	WRITE_TO_REGULARLOG_FILES:
	foreach my $__key ( sort(keys(%$_bmesgsbydate)) )
	{
		# __        ______  ___ _____ _____   ____  _____ _   _  ____ _        _    ____    _     ___   ____ 
		# \ \      / /  _ \|_ _|_   _| ____| |  _ \| ____| | | |/ ___| |      / \  |  _ \  | |   / _ \ / ___|
		#  \ \ /\ / /| |_) || |  | | |  _|   | |_) |  _| | | | | |  _| |     / _ \ | |_) | | |  | | | | |  _ 
		#   \ V  V / |  _ < | |  | | | |___  |  _ <| |___| |_| | |_| | |___ / ___ \|  _ <  | |__| |_| | |_| |
		#    \_/\_/  |_| \_\___| |_| |_____| |_| \_\_____|\___/ \____|_____/_/   \_\_| \_\ |_____\___/ \____|
		#
		my $__s = \$Zci->config->{'file'}->{'storage'};
		my $__r = undef();

		# Set regular log directory
		if( -w $Zci->config->{'directory'}->{'log'} )
		{
			$_regularld = $Zci->config->{'directory'}->{'log'};
		}
		else
		{
			# Use /tmp instead of Her->config->{directory}->{log}, 
			# because the directory is unwritable.
			$_regularld = q(/tmp);
		}

		# Generate regular log file name as a string
		$_regularlf = new Path::Class::File::Lockable(
				sprintf("%s/%s.%s.%s", $_regularld, $$__s->{prefix}, $__key, $$__s->{suffix}));
		$_regularlf = new Path::Class::File::Lockable( $_regularlf.$$ ) if( $_regularlf->locked() );


		# Create Kanadzuchi::Log object
		$_objherlog = new Kanadzuchi::Log(
				'directory' => new Path::Class::Dir($_regularld),
				'logfile' => $_regularlf,
				'entities' => $_bmesgsbydate->{$__key},
				'count' => scalar(@{$_bmesgsbydate->{$__key}}), );

		$Cmd->d(9,sprintf( "Writing regular log = %s(%d)\n", $_objherlog->logfile(), $_objherlog->count() ));

		$_objherlog->directory->cleanup();

		$_objherlog->logfile->lock();
		$_objherlog->logfile->cleanup();
		$_objherlog->logfile->touch();

		$_objherlog->device($_objherlog->logfile->openw());
		$_objherlog->logger();

		$_objherlog->device->close() if( ref($_objherlog->device()) eq q{IO::File} );
		$_objherlog->logfile->unlock();
		$_wprogressbar->update() if( defined($_wprogressbar) );

	} # End of the loop, foreach()

	$Cmd->d(2,sprintf("Regular logs are saved into = %s\n", $_objherlog->directory()));


	# Clean up, Remove or Truncate temporary log files
	if( $Cmd->operation & ( $Cmd->option->{'remove'} + $Cmd->option->{'truncate'} )  )
	{
		#  ____  _____ __  __  _____     _______   _____ __  __ ____  _     ___   ____ 
		# |  _ \| ____|  \/  |/ _ \ \   / / ____| |_   _|  \/  |  _ \| |   / _ \ / ___|
		# | |_) |  _| | |\/| | | | \ \ / /|  _|     | | | |\/| | |_) | |  | | | | |  _ 
		# |  _ <| |___| |  | | |_| |\ V / | |___    | | | |  | |  __/| |__| |_| | |_| |
		# |_| \_\_____|_|  |_|\___/  \_/  |_____|   |_| |_|  |_|_|   |_____\___/ \____|
		#
		foreach my $__t ( @{$_templogfiles} )
		{
			# Truncate the temp log
			if( $Cmd->operation & $Cmd->option->{'truncate'} )
			{
				eval{ truncate($__t->stringify(),0); } unless( $__t->locked() );
				$Cmd->d(3,"Failed to truncate temp log\n") if($@);
			}

			# Remove the temp log
			if( $Cmd->operation & $Cmd->option->{'remove'} )
			{
				eval{ $__t->remove(); } unless( $__t->locked() );
				$Cmd->d(3,"Failed to remove temp log\n") if($@);
			}

		} # End of the loop(for())
	}

}

$Cmd->finish();

#  _____ _   _ _   _  ____ _____ ___ ___  _   _ ____  
# |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
# | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
# |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
# |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 
# 
sub parse_options
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|a|r|s|e|_|o|p|t|i|o|n|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Parse given options, and set the operation mode.
	# @Param	None
	# @Return	n = Integer: operation value(24bit integer)

	require Getopt::Long;
	my $_operation = 0;

	# Variables for decide operation
	my (
		$_opt_conf,
		$_opt_dir,
		$_opt_list,
		$_opt_file,
		$_opt_concatenate,
		$_opt_remove,
		$_opt_strict,
		$_opt_test,
		$_opt_truncate,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'concatenate'	=> \$_opt_concatenate,
			'c'		=> \$_opt_concatenate,
			'dir=s'		=> \$_opt_dir,
			'd=s'		=> \$_opt_dir,
			'file=s'	=> \$_opt_file,
			'f=s'		=> \$_opt_file,
			'list'		=> \$_opt_list,
			'l'		=> \$_opt_list,
			'remove'	=> \$_opt_remove,
			'strict'	=> \$_opt_strict,
			'test'		=> \$_opt_test,
			'T'		=> \$_opt_test,
			'truncate'	=> \$_opt_truncate,
			'help'		=> sub { help(); exit(0); },
			'verbose'	=> \$_opt_verbose,
			'v+'		=> \$_opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },
		);


	# (verbose|debug) mode
	$Cmd->debuglevel( ( $_opt_verbose ? $_opt_verbose : 0 ) - 1 );

	# Specify Config File(YAML)
	if( defined($_opt_conf) )
	{
		# Use specified config file(YAML)
		$_operation |= $Cmd->option->{'conf'};
		$Cmd->cf( new Path::Class::File($_opt_conf) );
	}
	elsif( $_opt_test )
	{
		# Test mode,
		$_operation |= $Cmd->option->{'test'};
		$Cmd->cf( new Path::Class::File('/dev/null'));
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
		$Cmd->cf->cleanup();
	}

	if( defined($_opt_file) )
	{
		# Specify temporary log file
		if( -f $_opt_file && -r _ && -w _ && -T _ )
		{
			# Read From the file.
			$Templf = new Path::Class::File($_opt_file);
			$Templf->cleanup();
		}
	}
	elsif( defined($_opt_dir) )
	{
		# Specify temporary log directory
		if( -d $_opt_dir && -r $_opt_dir && -w $_opt_dir )
		{
			# Read From the file.
			$Templd = new Path::Class::Dir($_opt_dir);
			$Templd->cleanup();
		}
	}
	$_operation |= $Cmd->option->{'truncate'} if( $_opt_truncate );
	$_operation |= $Cmd->option->{'remove'} if( $_opt_remove );
	$_operation |= $Cmd->option->{'strict'} if( $_opt_strict );
	$_operation |= $Cmd->option->{'list'} if( $_opt_list );

	# Enable Concatenating
	if( $_opt_concatenate ){ $_operation |= $Cmd->option->{'concatenate'}; }

	# Check whether or not Required options are specified.
	return($_operation);
}

sub help
{
	# +-+-+-+-+
	# |h|e|l|p|
	# +-+-+-+-+
	#
	# @Description	Print help messages
	# @Param	NONE
	# @Return	1

	printf( STDERR "%s/%s %s\n", $Zci->myname(), $Cmd->calledfrom(), $Zci->version() );
	printf( STDERR "Usage: %s [OPTIONS] \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * WORKING OPTIONS\n" );
	printf( STDERR "    -c, --concatenate   : Concatenate temporary log files which are created by\n");
	printf( STDERR "                          bin/mailboxparser -l and write to regular logs.\n");
	printf( STDERR "    -l, --list          : Find and list existing temporary log files in the directory.\n");
	printf( STDERR "\n" );
	printf( STDERR " * LOGFILE OPTIONS\n" );
	printf( STDERR "    -d, --dir <dir>     : Location of the directory which holds temporary log files\n");
	printf( STDERR "    -f, --file <tmplog> : Location of a temporary log file to concatenating.\n");
	printf( STDERR "    --strict            : Strictly check regular logs .\n");
	printf( STDERR "    --truncate          : Truncate temporary log files after concatenating.\n");
	printf( STDERR "    --remove            : Remove temporary log files after concatenating.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s -c --remove -vvv\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -C./test-run.cf -cd /var/tmp --truncate\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}


__END__
