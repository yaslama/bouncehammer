#__PERLEXECUTABLE__
# $Id: logger.PL,v 1.10 2010/04/14 00:43:37 ak Exp $
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
my $Bak;		# (String) Backup directory for the temp log.
my $Arg = { 'stdin' => 0, 'files' => [], 'dirs' => [], };

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'concatenate'	=> ( 1 << 2 ),
	'merge'		=> ( 1 << 3 ),
	'list'		=> ( 1 << 4 ),
	'truncate'	=> ( 1 << 5 ),
	'remove'	=> ( 1 << 6 ),
	'backup'	=> ( 1 << 7 ),
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

if( $Cmd->operation & ( $Cmd->option->{'concatenate'} + $Cmd->option->{'merge'} + $Cmd->option->{'list'} ) )
{
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
		opendir( my $directoryh, $_d );
		while( my $_f = readdir($directoryh) )
		{
			next() if( ! -f $_d.'/'.$_f || ! -T _ || ! -s _ );
			push( @{ $Arg->{'files'} }, Path::Class::File::Lockable->new($_d.'/'.$_f) );
		}
		closedir($directoryh);

	} # End of the loop foreach(SEEK_TEMPLOG_DIRS)
	$Arg->{'dirs'} = [];


	FIND_TEMPLOG_FILES: foreach my $_f ( @{ $Arg->{'files'} } )
	{
		#  _____ ___ _   _ ____    _____ __  __ ____  _     ___   ____ 
		# |  ___|_ _| \ | |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
		# | |_   | ||  \| | | | |   | | | |\/| | |_) | |  | | | | |  _ 
		# |  _|  | || |\  | |_| |   | | | |  | |  __/| |__| |_| | |_| |
		# |_|   |___|_| \_|____/    |_| |_|  |_|_|   |_____\___/ \____|
		#
		my $_tmploghash = undef();
		my $_md5digestv = undef();	# (Digest::MD5) object
		my $_tmploglock = undef();	# (Path::Class::File::Lockable)
		my $_eachtmplog = $_f->stringify();

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

	$Arg->{'files'} = [];
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
	my $countofchunk = int($sizeoftmplog/$logthreshold) + 1;


	while( scalar(@$tmplogsinhdd) > 0 )
	{
		#my $recordbydate = {};		# (Ref->Hash) The number of records/each day
		my $objectbydate = {};		# (Ref->Hash) key is '2009-01-03', value is pointer to array
		my $recordhashes = {};		# (Ref->Hash) Record digest
		my $templogfiles = [];		# (Ref->Array) Path::Class::File object of Temp log
		my $dataoftheday = undef();	# (Ref->Array) data of the day
		my $pprogressbar = undef();	# (Term::ProgressBar)
		my $recsofloaded = 0;		# (Integer) The number of loaded records

		# Read temporary log files
		LOAD_TEMPLOG_FILES: while( my $_f = shift(@$tmplogsinhdd) )
		{
			#  _     ___    _    ____    _____ __  __ ____  _     ___   ____ 
			# | |   / _ \  / \  |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
			# | |  | | | |/ _ \ | | | |   | | | |\/| | |_) | |  | | | | |  _ 
			# | |__| |_| / ___ \| |_| |   | | | |  | |  __/| |__| |_| | |_| |
			# |_____\___/_/   \_\____/    |_| |_|  |_|_|   |_____\___/ \____|
			# 
			my $_tempstored = Kanadzuchi::Metadata->to_object($_f);
			$sizeofloaded += -s $_f;

			next() unless( scalar(@$_tempstored) );

			LOAD_RECORDS_IN_TEMPLOG: foreach my $_o ( @$_tempstored )
			{
				my $_tokenthing = $_o->{'token'}.q(.).$_o->{'bounced'};
				my $_datestring = Time::Piece->new($_o->{'bounced'})->ymd('-');

				# Skip if it have same token and same timestamp
				next() if( exists($recordhashes->{ $_tokenthing }) );
				$recordhashes->{$_tokenthing} = 1;

				unless( exists($objectbydate->{$_datestring}) )
				{
					# Insert array reference
					$objectbydate->{$_datestring} = [];
					#$recordbydate->{$_datestring} = 0;
				}
				push( @{ $objectbydate->{$_datestring} }, $_o );
				$recsofloaded++;
				#$recordbydate->{$_datestring}++;

			} # End of the loop foreach(LOAD_RECORDS_IN_TEMPLOG)

			$sizeofloaded += -s $_f;
			push( @$templogfiles, $_f );
			last(LOAD_TEMPLOG_FILES) if( $sizeofloaded > $logthreshold );

		} # End of the loop foreach(LOAD_TEMPLOG_FILES)

		# There is no valid record
		next() unless( @$templogfiles );

		# progress bar
		if( $Cmd->debuglevel > -1 )
		{
			eval { require Term::ProgressBar; };
			$pprogressbar = new Term::ProgressBar( { 
							'fh' => \*STDERR,
							'ETA' => q(linear),
							'name' => q{Concatenate Logs(}.$countofchunk.q{)},
							'count' => $recsofloaded,
				});
		}


		WRITE_TO_REGULAR_LOG: foreach my $_key ( sort(keys(%$objectbydate)) )
		{
			# __        ______  ___ _____ _____   ____  _____ _   _  ____ _        _    ____    _     ___   ____ 
			# \ \      / /  _ \|_ _|_   _| ____| |  _ \| ____| | | |/ ___| |      / \  |  _ \  | |   / _ \ / ___|
			#  \ \ /\ / /| |_) || |  | | |  _|   | |_) |  _| | | | | |  _| |     / _ \ | |_) | | |  | | | | |  _ 
			#   \ V  V / |  _ < | |  | | | |___  |  _ <| |___| |_| | |_| | |___ / ___ \|  _ <  | |__| |_| | |_| |
			#    \_/\_/  |_| \_\___| |_| |_____| |_| \_\_____|\___/ \____|_____/_/   \_\_| \_\ |_____\___/ \____|
			#
			my $_handleoflog = undef();	# (IO::File) Saved regular log's file handle of the day
			my $_eachregrlog = new Path::Class::File::Lockable( 
							sprintf("%s/%s.%s.%s", 
								$Zci->config->{'directory'}->{'log'}, 
								$Zci->config->{'file'}->{'storage'}->{'prefix'},
								$_key, $Zci->config->{'file'}->{'storage'}->{'suffix'} ) );

			next() if( -e $_eachregrlog && ( ! -w _ || ! -T _ || $_eachregrlog->locked() ) );

			if( $Cmd->operation & $Cmd->option->{'merge'} )
			{
				#  __  __ _____ ____   ____ _____ 
				# |  \/  | ____|  _ \ / ___| ____|
				# | |\/| |  _| | |_) | |  _|  _|  
				# | |  | | |___|  _ <| |_| | |___ 
				# |_|  |_|_____|_| \_\\____|_____|
				#                                 
				my $_cacheofdata = q();		# (String) Buffer of 'data of the day'
				my $_duplicatedc = 0;		# (Integer) The number of duplicated records
				my $_eachlogbuff = q();		# (String) Buffer of each line contents
				my $_handleoftmp = undef();	# (IO::File) Working reglar logs's file handle of the day
				my $_eachregrtmp = undef();	# (Path::Class::File) Working regular log's object

				# Merge progress bar
				#if( $Cmd->debuglevel > -1 )
				#{
				#	eval { require Term::ProgressBar; };
				#	$pprogressbar = new Term::ProgressBar( { 
				#				'fh' => \*STDERR,
				#				'ETA' => q(linear),
				#				'name' => q{Merge Logs (}.(scalar(@$tmplogsinhdd)+1).q{) }.$_key,
				#				'count' => scalar( @{ $objectbydate->{$_key} } ),
				#			});
				#}

				$dataoftheday = Kanadzuchi::Metadata->mergesort($objectbydate->{$_key});

				# Lock the regular log and set file handle
				$_eachregrlog->lock() || do { $Cmd->d(1,'Cannot create the lock file'.qq(\n)); next() };
				$_handleoflog = $_eachregrlog->openr() if( -s $_eachregrlog && -r _ );

				# Set the temporary regular log's object and file handle
				$_eachregrtmp = new Path::Class::File( 
							$_eachregrlog->stringify().q(.).$$.time().( rand(12) * 1000 ).q(.tmp-merged) );
				$_handleoftmp = new IO::File( qq{>> }.$_eachregrtmp->stringify() );
				$_eachregrtmp->touch();


				if( $_handleoflog )
				{
					READ_REGULAR_LOG: while( my $_eachlogline = <$_handleoflog> )
					{
						my $_bounceddate = -1;
						my $_tokenstring = q();
						my $_theheaddata = {};

						if( $_eachlogline =~ m{["]bounced["]:\s?(\d+).+["]token["]:\s?["](\w+)["]} )
						{
							# Regular expression is faster than JSON::Syck, Kanadzuchi::Metadata
							#  $x = shift( @{ Kanadzuchi::Metadata->to_object(\$y) });
							#  $x = shift( @{ JSON::Syck::Load($y) } );
							$_bounceddate = $1;
							$_tokenstring = $2;
						}
						else
						{
							# Broken data in the regular log?
							next();
						}

						if( scalar(@$dataoftheday) == 0 )
						{
							# Temporary log data is empty
							$_eachlogbuff .= $_eachlogline;
							if( length($_eachlogbuff) + length($_cacheofdata) > $logthreshold )
							{
								# Write buffer
								print( $_handleoftmp $_cacheofdata );
								print( $_handleoftmp $_eachlogbuff );
								$_eachlogbuff = q();
								$_cacheofdata = q();
							}
							next();
						}
						$_theheaddata = $dataoftheday->[0];

						if( $_bounceddate == $_theheaddata->{'bounced'} && $_tokenstring eq $_theheaddata->{'token'} )
						{
							# There are same records in the tmporary log and the regular log.
							$_eachlogbuff .= $_eachlogline;
							$_duplicatedc++;

							shift(@$dataoftheday);
							$pprogressbar->update() if( defined($pprogressbar) );
							next();
						}

						$_eachlogbuff .= $_eachlogline;
						$_cacheofdata .= ${ Kanadzuchi::Metadata->to_string([$_theheaddata]) };

						if( $_theheaddata->{'bounced'} < $_bounceddate
							|| ( length($_eachlogbuff) + length($_cacheofdata) > $logthreshold ) ){

							# The record in the temporary log is older than the record in the 
							# regurlar log OR Buffer size exceeds limit.
							print( $_handleoftmp $_cacheofdata );
							print( $_handleoftmp $_eachlogbuff );
							$_eachlogbuff = q();
							$_cacheofdata = q();

							shift(@$dataoftheday);
							$pprogressbar->update() if( defined($pprogressbar) );
						}

					} # End of while(READ_REGULAR_LOG)

				}

				$_cacheofdata .= ${ Kanadzuchi::Metadata->to_string($dataoftheday) };

				if( length($_eachlogbuff) + length($_cacheofdata) )
				{
					print( $_handleoftmp $_cacheofdata );
					print( $_handleoftmp $_eachlogbuff );
					$_eachlogbuff = q();
					$_cacheofdata = q();
				}

				$_handleoftmp->close() if( $_handleoftmp );
				$_handleoflog->close() if( $_handleoflog );
				$pprogressbar->update($recsofloaded) if( defined($pprogressbar) && ! $_handleoflog );

				unless( -s $_eachregrtmp )
				{
					$_eachregrlog->unlock();
					$_eachregrtmp->remove;
					next();
				}

				$_eachregrtmp->remove() if( File::Copy::copy( $_eachregrtmp->stringify(), $_eachregrlog->stringify() ));
				$_eachregrlog->unlock();

			}
			elsif( $Cmd->operation & $Cmd->option->{'concatenate'} )
			{
				#   ____ ___  _   _  ____    _  _____ _____ _   _    _  _____ _____ 
				#  / ___/ _ \| \ | |/ ___|  / \|_   _| ____| \ | |  / \|_   _| ____|
				# | |  | | | |  \| | |     / _ \ | | |  _| |  \| | / _ \ | | |  _|  
				# | |__| |_| | |\  | |___ / ___ \| | | |___| |\  |/ ___ \| | | |___ 
				#  \____\___/|_| \_|\____/_/   \_\_| |_____|_| \_/_/   \_\_| |_____|
				# 
				my $_arrayofdata = [];

				$dataoftheday = $objectbydate->{$_key};

				# Lock the regular log and set file handle
				$_eachregrlog->lock() || do { $Cmd->d(1,'Cannot create the lock file'.qq(\n)); next() };
				$_handleoflog = new IO::File( qq{>> }.$_eachregrlog->stringify() );

				foreach my $_eachtmpdata ( @$dataoftheday )
				{
					push( @$_arrayofdata, $_eachtmpdata );

					if( scalar(@$_arrayofdata) > 10000 )
					{
						print( $_handleoflog ${ Kanadzuchi::Metadata->to_string($_arrayofdata) } );
						$pprogressbar->update() if( $pprogressbar );
						$_arrayofdata = [];
					}
				}

				if( scalar(@$_arrayofdata) )
				{
					print( $_handleoflog ${ Kanadzuchi::Metadata->to_string($_arrayofdata) } );
					$pprogressbar->update($recsofloaded) if( $pprogressbar );
					$_arrayofdata = [];
				}
				$_handleoflog->close() if( $_handleoflog );
				$_eachregrlog->unlock();
			}


		} # End of the loop foreach(WRITE_TO_REGULAR_LOG)
		continue
		{
			$objectbydate->{$_key} = undef();
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
			foreach my $_t ( @$templogfiles )
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
		elsif( $Cmd->operation & $Cmd->option->{'backup'} )
		{
			#  ____    _    ____ _  ___   _ ____    _____ __  __ ____  _     ___   ____ 
			# | __ )  / \  / ___| |/ / | | |  _ \  |_   _|  \/  |  _ \| |   / _ \ / ___|
			# |  _ \ / _ \| |   | ' /| | | | |_) |   | | | |\/| | |_) | |  | | | | |  _ 
			# | |_) / ___ \ |___| . \| |_| |  __/    | | | |  | |  __/| |__| |_| | |_| |
			# |____/_/   \_\____|_|\_\\___/|_|       |_| |_|  |_|_|   |_____\___/ \____|
			#                                                                           
			foreach my $_t ( @$templogfiles )
			{
				File::Copy::move( $_t->stringify(), $Bak ) 
			}
		}

	} # End of while()
	continue
	{
		$countofchunk--;
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
		$_opt_backup,
		$_opt_conf,
		$_opt_list,
		$_opt_concatenate,
		$_opt_merge,
		$_opt_remove,
		$_opt_test,
		$_opt_truncate,
		$_opt_silent,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'backup=s'	=> \$_opt_backup,
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'concatenate'	=> \$_opt_concatenate,
			'c'		=> \$_opt_concatenate,
			'list'		=> \$_opt_list,
			'l'		=> \$_opt_list,
			'merge'		=> \$_opt_merge,
			'm'		=> \$_opt_merge,
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
		map { $_->cleanup(); } @{ $Arg->{'files'} };
		push( @{ $Arg->{'dirs'}  }, @_logds );
	}

	if( $_opt_truncate || $_opt_remove )
	{
		$_operation |= $Cmd->option->{'truncate'} if( $_opt_truncate );
		$_operation |= $Cmd->option->{'remove'} if( $_opt_remove );
	}
	elsif( defined($_opt_backup) && -d $_opt_backup && -r _ && -x _ && -w _ )
	{
		$_operation |= $Cmd->option->{'backup'};
		$Bak = $_opt_backup;
	}

	# List
	$_operation |= $Cmd->option->{'list'} if( $_opt_list );

	# Concatenate or Merge
	if( $_opt_concatenate ){ $_operation |= $Cmd->option->{'concatenate'}; }
	elsif( $_opt_merge ){ $_operation |= $Cmd->option->{'merge'}; }

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
	printf( STDERR "    -c, --concatenate   : CONCATENATE temporary log files which are created by\n");
	printf( STDERR "                          bin/mailboxparser -l and write to regular logs.\n");
	printf( STDERR "    -l, --list          : Find and list existing temporary log files in the directory.\n");
	printf( STDERR "    -m, --merge         : CONCATENATE temporary log files which are created by\n");
	printf( STDERR "                          bin/mailboxparser -l and write to regular logs.\n");
	printf( STDERR "\n" );
	printf( STDERR " * LOGFILE OPTIONS\n" );
	printf( STDERR "    --truncate          : Truncate temporary log files after concatenating.\n");
	printf( STDERR "    --remove            : Remove temporary log files after concatenating.\n");
	printf( STDERR "    --backup <dir>      : Backup; move the temp logs to the directory after mergence.\n");
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
