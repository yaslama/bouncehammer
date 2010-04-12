#__PERLEXECUTABLE__
# $Id: logger.PL,v 1.9 2010/04/12 05:45:56 ak Exp $
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
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Commandline object
my $Arg = { 'stdin' => 0, 'files' => [], 'dirs' => [], };

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
	my $logthreshold = 5242880;	# (Integer) 5MB, About 10,000 records
	my $sizeoftmplog = 0;		# (Integer) File size of all of temporary logs.
	my $tmplogsinhdd = [];		# (Ref->Array) Each temporary logs(Path::Class::File::Lockable)
	my $string_tlogs = sprintf("%s.\\d{4}-\\d{2}-\\d{2}.[0-9A-Fa-f]{8}.[0-9A-Fa-f]{6}.%s",
					$Zci->config->{'file'}->{'templog'}->{'prefix'}, 
					$Zci->config->{'file'}->{'templog'}->{'suffix'} );
	my $regexp_tlogs = qr{$string_tlogs\z}oi;

	if( scalar( @{$Arg->{'dirs'}} ) == 0 && scalar( @{$Arg->{'files'}} ) == 0 )
	{
		push( @{ $Arg->{'dirs'} }, 
			new Path::Class::Dir($Zci->config->{'directory'}->{'spool'}) );
	}

	SEEK_TEMPLOG_DIRS: foreach my $_d ( @{ $Arg->{'dirs'} } )
	{
		#  ____  _               _             _           
		# |  _ \(_)_ __ ___  ___| |_ ___  _ __(_) ___  ___ 
		# | | | | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
		# | |_| | | | |  __/ (__| || (_) | |  | |  __/\__ \
		# |____/|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
		#                                                  
		while( my $_f = $_d->next() )
		{
			next() if( $_f->is_dir || ! -f $_f || ! -T _ || ! -s _ );
			push( @{ $Arg->{'files'} }, Path::Class::File::Lockable->new($_f) );
		}

	} # End of the loop foreach(SEEK_TEMPLOG_DIRS)
	$Arg->{'dirs'} = [];


	my( $_tmploghash, $_md5digestv, $_tmploglock, $_eachtmplog );
	FIND_TEMPLOG_FILES: foreach my $_f ( @{ $Arg->{'files'} } )
	{
		#  _____ ___ _   _ ____    _____ __  __ ____  _     ___   ____ 
		# |  ___|_ _| \ | |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
		# | |_   | ||  \| | | | |   | | | |\/| | |_) | |  | | | | |  _ 
		# |  _|  | || |\  | |_| |   | | | |  | |  __/| |__| |_| | |_| |
		# |_|   |___|_| \_|____/    |_| |_|  |_|_|   |_____\___/ \____|
		#
		$_md5digestv = undef();	# (Digest::MD5) object
		$_tmploglock = undef();	# (Path::Class::File::Lockable)
		$_eachtmplog = $_f->stringify();

		# Does not match with regular expression
		next() unless( $_eachtmplog =~ $regexp_tlogs );
		next() if( $_f->is_dir() || ! -f $_eachtmplog || ! -T $_eachtmplog );

		if( -z $_eachtmplog )
		{
			# It is an empty file
			eval { $_f->remove() if( $Cmd->operation & $Cmd->option->{'remove'} ); };
			next();
		}

		# Create MD5 Digest of the file
		$_md5digestv = Digest::MD5->new()->addfile($_f->openr())->hexdigest();
		$_tmploglock = new Path::Class::File::Lockable($_f);

		if( defined($_tmploghash->{ $_md5digestv }) && -r $_tmploghash->{ $_md5digestv } )
		{
			# Temporary log file is now locked by mailboxparser?
			next() if( $_tmploglock->locked() );

			# If the file has same digest, remove it and skip to the next.
			eval { truncate( $_eachtmplog, 0 ) } if( $Cmd->operation & $Cmd->option->{truncate} );
			if( $Cmd->operation & $Cmd->option->{'remove'} )
			{
				eval { $_f->remove(); };
				$Cmd->d(6,sprintf("Remove the log file(has same digest) = %s\n", $_eachtmplog )) unless($@);
			}
			next();
		}

		# Record the file name using MD5 Digest as a hash key
		$_tmploghash->{ $_md5digestv } = $_eachtmplog;
		push( @$tmplogsinhdd, $_tmploglock );
		$sizeoftmplog += -s $_tmploglock;
		$Cmd->d(5, sprintf("Temporary log file(#%d) = %s (%s)\n", scalar(@$tmplogsinhdd), $_eachtmplog, $_md5digestv ));

		# Put temporary log file name in Verbosed List mode.
		if( $Cmd->operation & $Cmd->option->{'list'} && $Cmd->debuglevel > -1 )
		{
			print( STDOUT $_eachtmplog.qq(\n) ) 
		}

	} # End of the loop while(FIND_TEMPLOG_FILES)

	$Cmd->d( 3,sprintf("The number of temporary logs = %d, size = %d\n", scalar(@$tmplogsinhdd), $sizeoftmplog ) );


	# There is no temporary log file.
	if( scalar(@$tmplogsinhdd) == 0 )
	{
		$Cmd->d(1,q{There is no temporary log file}.qq{\n} );
		$Cmd->finish();
	}

	# File List Only: Print the number of temporary log files and exit(0).
	if( $Cmd->operation & $Cmd->option->{'list'} )
	{
		print( STDOUT scalar(@$tmplogsinhdd).qq(\n) );
		$Cmd->finish();
	}


	require Kanadzuchi::Metadata;
	require Time::Piece;
	require File::Copy;

	my $sizeofloaded = 0;		# (Integer) File size of loaded temporary logs.
	my $templogfiles = [];		# (Ref->Array) Path::Class::File object of Temp log
	my $dataoftheday = [];
	my $objectbydate = {};		# (Ref->Hash) key is '2009-01-03', value is pointer to array
	my $recordhashes = {};		# (Ref->Hash) Record digest
	my $tprogressbar = undef();	# (Term::ProgressBar)
	my( $_tempstored, $_tokenthing, $_datestring );

	# Prepare progress bar
	if( $Cmd->debuglevel > -1 )
	{
		eval { require Term::ProgressBar; };
		$tprogressbar = new Term::ProgressBar( { 
					'fh' => \*STDERR,
					'ETA' => q(linear),
					'name' => q(Parse Temp Logs),
					'count' => scalar(@$tmplogsinhdd),
				});
	}


	while( scalar(@$tmplogsinhdd) > 0 )
	{
		# Read temporary log files
		LOAD_TEMPLOG_FILES: while( my $_f = shift(@$tmplogsinhdd) )
		{
			#  _     ___    _    ____    _____ __  __ ____  _     ___   ____ 
			# | |   / _ \  / \  |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
			# | |  | | | |/ _ \ | | | |   | | | |\/| | |_) | |  | | | | |  _ 
			# | |__| |_| / ___ \| |_| |   | | | |  | |  __/| |__| |_| | |_| |
			# |_____\___/_/   \_\____/    |_| |_|  |_|_|   |_____\___/ \____|
			# 
			$_tempstored = Kanadzuchi::Metadata->to_object($_f);
			$sizeofloaded += -s $_f;

			unless( scalar(@$_tempstored) )
			{
				$tprogressbar->update() if( defined($tprogressbar) );
				next();
			}

			LOAD_RECORDS_IN_TEMPLOG: foreach my $_o ( @$_tempstored )
			{
				$_tokenthing = $_o->{'token'}.q(.).$_o->{'bounced'};
				$_datestring = Time::Piece->new($_o->{'bounced'})->ymd('-');

				# Skip if it have same token and same timestamp
				next() if( exists($recordhashes->{ $_tokenthing }) );
				$recordhashes->{$_tokenthing} = 1;

				unless( exists($objectbydate->{$_datestring}) )
				{
					# Insert array reference
					$objectbydate->{$_datestring} = [];
				}
				push( @{ $objectbydate->{$_datestring} }, $_o );

			} # End of the loop foreach(LOAD_RECORDS_IN_TEMPLOG)

			$sizeofloaded += -s $_f;
			push( @$templogfiles, $_f );
			$tprogressbar->update() if( defined($tprogressbar) );
			last(LOAD_TEMPLOG_FILES) if( $sizeofloaded > $logthreshold );

		} # End of the loop foreach(LOAD_TEMPLOG_FILES)

		# There is no valid record
		next() unless( @$templogfiles );

		my $rprogressbar = undef();	# Term::ProgressBar object for regular logs
		if( $Cmd->debuglevel > -1 )
		{
			eval { require Term::ProgressBar; };
			$rprogressbar = new Term::ProgressBar( {
						'fh' => \*STDERR, 
						'ETA' => q(linear),
						'name' => q(Merge Regular Logs),
						'count' => (my $__c = keys(%$objectbydate)),
					});
		}

		my( $_eachregrlog, $_eachregrtmp, $_handleoflog, $_handleoftmp, $_duplicatedc );
		my( $_eachlogline, $_eachlogjson, $_eachlogbuff, $_indexofdata, $_cacheofdata );
		WRITE_TO_REGULAR_LOG: foreach my $_key ( sort(keys(%$objectbydate)) )
		{
			# __        ______  ___ _____ _____   ____  _____ _   _  ____ _        _    ____    _     ___   ____ 
			# \ \      / /  _ \|_ _|_   _| ____| |  _ \| ____| | | |/ ___| |      / \  |  _ \  | |   / _ \ / ___|
			#  \ \ /\ / /| |_) || |  | | |  _|   | |_) |  _| | | | | |  _| |     / _ \ | |_) | | |  | | | | |  _ 
			#   \ V  V / |  _ < | |  | | | |___  |  _ <| |___| |_| | |_| | |___ / ___ \|  _ <  | |__| |_| | |_| |
			#    \_/\_/  |_| \_\___| |_| |_____| |_| \_\_____|\___/ \____|_____/_/   \_\_| \_\ |_____\___/ \____|
			#
			$dataoftheday = Kanadzuchi::Metadata->mergesort($objectbydate->{$_key});
			$_handleoflog = undef();
			$_handleoftmp = undef();
			$_duplicatedc = 0;
			$_indexofdata = 0;
			$_cacheofdata = q();
			$_eachlogbuff = q();
			$_eachregrlog = new Path::Class::File::Lockable( sprintf("%s/%s.%s.%s", 
							$Zci->config->{'directory'}->{'log'}, 
							$Zci->config->{'file'}->{'storage'}->{'prefix'},
							$_key, $Zci->config->{'file'}->{'storage'}->{'suffix'} ) );
			$_eachregrtmp = new Path::Class::File::Lockable($_eachregrlog->stringify().q(.TMP));

			$rprogressbar->update() if( $rprogressbar );
			next() if( -e $_eachregrlog && ( ! -w _ || ! -T _ || $_eachregrlog->locked() ) );
			next() if( -e $_eachregrtmp && $_eachregrtmp->locked() );

			$_eachregrlog->lock() || do { $Cmd->d(1,'Cannot create the lock file'.qq(\n)); next() };
			$_handleoflog = $_eachregrlog->openr() if( -s $_eachregrlog && -r _ );
			$_eachregrtmp->lock();
			$_handleoftmp = $_eachregrtmp->openw();

			if( $_handleoflog )
			{
				while( $_eachlogline = <$_handleoflog> )
				{
					$_eachlogjson = Kanadzuchi::Metadata->to_object($_eachlogline)->[0];
					next() unless( $_eachlogjson );

					if( $_eachlogjson->{'bounced'} == $dataoftheday->[$_indexofdata]->{'bounced'} 
						&& $_eachlogjson->{'token'} eq $dataoftheday->[$_indexofdata]->{'token'} ){

						$_duplicatedc++;
						next();
					}


					if( $dataoftheday->[$_indexofdata]->{'bounced'} < $_eachlogjson->{'bounced'} 
						|| ( length($_eachlogbuff) + length($_cacheofdata) > $logthreshold ) ){

						# Write buffer
						print( $_handleoftmp $_cacheofdata );
						print( $_handleoftmp $_eachlogbuff );
						$_eachlogbuff = q();
						$_cacheofdata = q();
					}
					else
					{
						$_eachlogbuff .= $_eachlogline;
						$_cacheofdata .= ${ Kanadzuchi::Metadata->to_string($dataoftheday->[$_indexofdata]) };
					}
				}
				continue
				{
					$_indexofdata++;
				}
			}
			else
			{
				$_cacheofdata = ${ Kanadzuchi::Metadata->to_string($dataoftheday) }
			}

			if( length($_eachlogbuff) + length($_cacheofdata) )
			{
				print( $_handleoftmp $_cacheofdata );
				print( $_handleoftmp $_eachlogbuff );
				$_eachlogbuff = q();
				$_cacheofdata = q();
			}

			$_handleoftmp->close() if( $_handleoftmp );
			$_handleoflog->close() if( $_handleoflog );

			unless( -s $_eachregrtmp )
			{
				$_eachregrlog->unlock();
				$_eachregrtmp->unlock();
				$_eachregrtmp->remove;
				next();
			}

			$_eachregrtmp->remove() if( File::Copy::copy( $_eachregrtmp->stringify(), $_eachregrlog->stringify() ));
			$_eachregrtmp->unlock();
			$_eachregrlog->unlock();

		} # End of the loop foreach(WRITE_TO_REGULAR_LOG)
		continue
		{
			$objectbydate->{$_key} = [];
		}


		# Clean up, Remove or Truncate temporary log files
		if( $Cmd->operation & ( $Cmd->option->{'remove'} + $Cmd->option->{'truncate'} )  )
		{
			#  ____  _____ __  __  _____     _______   _____ __  __ ____  _     ___   ____ 
			# |  _ \| ____|  \/  |/ _ \ \   / / ____| |_   _|  \/  |  _ \| |   / _ \ / ___|
			# | |_) |  _| | |\/| | | | \ \ / /|  _|     | | | |\/| | |_) | |  | | | | |  _ 
			# |  _ <| |___| |  | | |_| |\ V / | |___    | | | |  | |  __/| |__| |_| | |_| |
			# |_| \_\_____|_|  |_|\___/  \_/  |_____|   |_| |_|  |_|_|   |_____\___/ \____|
			#
			foreach my $_t ( @{$templogfiles} )
			{
				# Truncate the temp log
				if( $Cmd->operation & $Cmd->option->{'truncate'} )
				{
					eval{ truncate($_t->stringify(),0); } unless( $_t->locked() );
					$Cmd->d(3,"Failed to truncate temp log\n") if($@);
				}

				# Remove the temp log
				if( $Cmd->operation & $Cmd->option->{'remove'} )
				{
					eval{ $_t->remove(); } unless( $_t->locked() );
					$Cmd->d(3,"Failed to remove temp log\n") if($@);
				}

			} # End of the loop(for())
		}
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
		$_opt_list,
		$_opt_concatenate,
		$_opt_remove,
		$_opt_test,
		$_opt_truncate,
		$_opt_silent,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'concatenate'	=> \$_opt_concatenate,
			'c'		=> \$_opt_concatenate,
			'list'		=> \$_opt_list,
			'l'		=> \$_opt_list,
			'remove'	=> \$_opt_remove,
			'test'		=> \$_opt_test,
			'T'		=> \$_opt_test,
			'truncate'	=> \$_opt_truncate,
			'help'		=> sub { help(); exit(0); },
			'silent'	=> \$_opt_silent,
			'verbose'	=> \$_opt_verbose,
			'v+'		=> \$_opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },
		);


	# (verbose|debug|silent) mode
	$Cmd->debuglevel( ( $_opt_verbose ? $_opt_verbose : 0 ) - 1 );
	$Cmd->silent( $_opt_silent ? 1 : 0 );

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

	CHECK_TEMPLOG_FILES_AND_DIRS:
	{
		if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' )
		{
			$Arg->{'stdin'} = 1;
			last();
		}

		my @_argvs = @ARGV;
		my @_logfs = ();
		my @_logds = ();

		map { $_ =~ y{[ ]}{}d; } @_argvs;
		@_logfs = grep { -f $_ && -T _ && -r _ } @_argvs;
		@_logds = grep { -d $_ && -x _ && -r _ } @_argvs;

		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logfs;
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logds;

		@{ $Arg->{'files'} } = map { Path::Class::File::Lockable->new($_) } @_logfs;
		@{ $Arg->{'dirs'}  } = map { Path::Class::Dir->new($_)  } @_logds;

		map { $_->cleanup(); } @{ $Arg->{'files'} };
		map { $_->cleanup(); } @{ $Arg->{'dirs'} };
	}

	$_operation |= $Cmd->option->{'truncate'} if( $_opt_truncate );
	$_operation |= $Cmd->option->{'remove'} if( $_opt_remove );
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
	printf( STDERR "Usage: %s [OPTIONS] [FILE|DIRECTORY [FILE2|DIR2 [FILE3|DIR3...]]]\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * WORKING OPTIONS\n" );
	printf( STDERR "    -c, --concatenate   : Concatenate temporary log files which are created by\n");
	printf( STDERR "                          bin/mailboxparser -l and write to regular logs.\n");
	printf( STDERR "    -l, --list          : Find and list existing temporary log files in the directory.\n");
	printf( STDERR "\n" );
	printf( STDERR " * LOGFILE OPTIONS\n" );
	printf( STDERR "    --truncate          : Truncate temporary log files after concatenating.\n");
	printf( STDERR "    --remove            : Remove temporary log files after concatenating.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    --silent            : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
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
