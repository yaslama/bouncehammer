#__PERLEXECUTABLE__
# $Id: databasectl.PL,v 1.17 2010/07/07 01:07:12 ak Exp $
# -Id: databasectl.PL,v 1.16 2010/02/21 20:09:01 ak Exp -
# -Id: databasectl.PL,v 1.1 2009/08/29 14:36:53 ak Exp -
# -Id: databasectl.PL,v 1.15 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Command::
                                                                            
     ##          ##         ##                                  ##   ###    
     ##   #### ###### ####  ##      ####   #####  ####   #### ######  ##    
  #####      ##  ##      ## #####      ## ##     ##  ## ##      ##    ##    
 ##  ##   #####  ##   ##### ##  ##  #####  ####  ###### ##      ##    ##    
 ##  ##  ##  ##  ##  ##  ## ##  ## ##  ##     ## ##     ##      ##    ##    
  #####   #####   ### ##### #####   ##### #####   ####   ####    ### ####   
package Kanadzuchi::Command::Databasectl;

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
use Kanadzuchi::BdDR;
use Error ':try';
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Commadline object
my $Rdb;		# (Kanadzuchi::BdDR) Database object
my $Day;		# (Integer) The day (before|after), 0 = today, -1 = yesterday
my $Log = [];		# (Ref->Array) Log files for INSERT or UPDATE
my $Cnd = {};		# (Ref->Hash) Where condition for --remove or --disable

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'database'	=> ( 1 << 2 ),
	'update'	=> ( 1 << 3 ),
	'remove'	=> ( 1 << 4 ),
	'force'		=> ( 1 << 5 ),
	'disable'	=> ( 1 << 6 ),
	'cleanup'	=> ( 1 << 7 ),
	'batch'		=> ( 1 << 8 ),
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

# Create Kanadzuchi::BdDR object
$Rdb = new Kanadzuchi::BdDR();

# Parse options, initialize object
try {
	if( $Cmd->operation( parse_options() ) == 0 )
	{
		Kanadzuchi::Exception::Command->throw( '-text' => 'Try --help' );
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
foreach my $sig qw( INT QUIT TERM KILL )
{
	$SIG{$sig} = sub { $Cmd->catch_signal($sig); };
}

if( $Cmd->operation & $Cmd->option->{'database'} )
{
	#  _   _ ____  _____   ____  ____  
	# | | | / ___|| ____| |  _ \| __ ) 
	# | | | \___ \|  _|   | | | |  _ \ 
	# | |_| |___) | |___  | |_| | |_) |
	#  \___/|____/|_____| |____/|____/ 
	#
	# Use Database
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require Kanadzuchi::BdDR::Cache;
	require Kanadzuchi::Mail::Stored::YAML;
	require Kanadzuchi::Mail::Stored::BdDR;

	my $xntableobj = undef();	# (Kanadzuchi::BdDR::BounceLogs::Table) Txn table object
	my $mastertabs = {};		# (Ref->Hash) Kanadzuchi::BdDR::BounceLogs::Masters::Table objects

	# Set timeout(ALRM) for reading from STDIN
	eval { alarm( ( $Zci->config->{'environment'}->{'timeout'} || 180 ) ) };

	# Set values to Kanadzuchi::BdDR object, Create data source name
	try {
		$Rdb->setup( $Zci->config->{'database'} );
		Kanadzuchi::Exception::Database->throw( '-text' => 'Failed to connect DB' ) unless $Rdb->connect();
		$Cmd->d(2,"Connecting to the database\n") if( defined $Rdb->handle() );

		# Create master table objects
		$xntableobj = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $Rdb->handle() );
		$mastertabs = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($Rdb->handle());
		Kanadzuchi::Exception::Database->throw( 
			'-text' => 'Failed to create table objects' ) if( ! $xntableobj || ! $mastertabs );

		( $Rdb->hostname() && $Rdb->port() )
			? $Cmd->d(2,sprintf("Database host = %s:%d\n", $Rdb->hostname(),$Rdb->port()))
			: $Cmd->d(2,qq{Database host = Socket\n});

		$Cmd->d(2,sprintf("Database name = %s(%s)\n", $Rdb->dbname(), $Rdb->dbtype()));
		$Cmd->d(2,sprintf("Database user = %s\n", $Rdb->username()));
		$Cmd->d(2,sprintf("Using table = %s\n", $xntableobj->alias()));

	}
	catch Kanadzuchi::Exception::Database with {
		$Cmd->exception(shift());
		$Cmd->abort();
	};

	# Read log file for UPDATE or DELETE
	if( $Cmd->operation & $Cmd->option->{'update'} )
	{
		#  _   _ ____  ____    _  _____ _____   _   ___ _   _ ____  _____ ____ _____ 
		# | | | |  _ \|  _ \  / \|_   _| ____| | | |_ _| \ | / ___|| ____|  _ \_   _|
		# | | | | |_) | | | |/ _ \ | | |  _|   | |  | ||  \| \___ \|  _| | |_) || |  
		# | |_| |  __/| |_| / ___ \| | | |___  | |  | || |\  |___) | |___|  _ < | |  
		#  \___/|_|   |____/_/   \_\_| |_____| | | |___|_| \_|____/|_____|_| \_\|_|  
		#                                      |_|                                   
		my $rthreshold = 10000;		# (Integer) About 10,000 records
		my $thelinesof = 0;		# (Integer) The number of records in the logs
		my $sizeoflogs = 0;		# (Integer) File size of all of the logs
		my $theprogbar = undef();	# (Term::ProgressBar) Progress bar

		# Create the log file name by the day(-t, -y, or -b option )
		if( scalar(@$Log) == 0 && defined($Day) )
		{
			# Set the log file name
			my $_theday = bless( (localtime() - ( $Day * 86400 )), q|Time::Piece| );
			my $_thelog = new Path::Class::File( $Zci->get_logfile('r',{ 'date' => $_theday->ymd('-') }) );
			push( @$Log, $_thelog );
			$Cmd->d( 1, sprintf("Log file(date) = %s\n", $_thelog->stringify() ));
		}

		# Check the log files
		if( scalar(@$Log) )
		{
			try {
				Kanadzuchi::Exception::File->throw(
					'-text' => 'There is no log file' ) unless( grep { -s $_ && -r _ && -T _ } @$Log );
				alarm(0);

				# Prepare the progress bar
				if( -t STDIN && $Cmd->debuglevel > -1 )
				{
					eval{ require Term::ProgressBar; };
					$theprogbar = new Term::ProgressBar( { 
								'fh' => \*STDERR,
								'ETA' => 'linear',
								'name' => 'Check log files',
								'count' => scalar @$Log } );
				}

				# Check the number of records in the log files
				foreach my $f ( @$Log )
				{
					open( my $loghandle, q{<}, $f );
					$sizeoflogs += -s $f;
					$thelinesof++ while( <$loghandle> );
					close($loghandle);
				}
			}
			otherwise {
				$Cmd->exception(shift());
				$Cmd->abort();
			};
		}
		else
		{
			# Read parsed data from STDIN
			push( @$Log, \*STDIN );
		}


		my $tablecache = new Kanadzuchi::BdDR::Cache();	# (K::BdDR::Cache) Table cache
		my $snegativec = {};				# (Ref->Hash) Negative cache for senderdomain
		my $xntabalias = lc $xntableobj->alias();	# (String) lower cased txn table alias
		my $sddomtable = $mastertabs->{'senderdomains'};# (K::BdDR::B::Masters::Table) senderdomains table

		my $loadedsize = 0;				# (Integer) Loaded data size
		my $loadedline = 0;				# (Integer) Loaded line

		my $debugmesgs = q();				# (String) Debug message string
		my $recinthedb = $xntableobj->count();		# (Integer) The number of records in the db
		my $xsoftlimit = $Zci->config->{'database'}->{'table'}->{'bouncelogs'}->{'maxrecords'} || 0;
		my $execstatus = {
			'update' => 0, 'insert' => 0, 'tooold' => 0, 'exceed' => 0,
			'failed' => 0, 'nofrom' => 0, 'whited' => 0, };

		# Verbose message
		if( $theprogbar )
		{
			$debugmesgs = $Cmd->d(1,sprintf("Total size of log files = %d\n", $sizeoflogs));
			$theprogbar->message( $debugmesgs );

			$debugmesgs = $Cmd->d(1,sprintf("Bounce messages in the log file = %d\n", $thelinesof));
			$theprogbar->message( $debugmesgs );

			$debugmesgs = $Cmd->d(1,sprintf("Bounce messages in the database = %d\n", $recinthedb));
			$theprogbar->message( $debugmesgs );

			$debugmesgs = $Cmd->d(1,sprintf("Limit the number of records(db) = %d\n", $xsoftlimit));
			$theprogbar->message( $debugmesgs );
		}

		# Prepare the progress bar
		if( -t STDIN && $Cmd->debuglevel > -1 )
		{
			$theprogbar = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => 'linear',
						'name' => '(UPDATE|INSERT)',
						'count' => -t STDIN ? $thelinesof : $sizeoflogs } );
		}

		LOAD_EACH_FILE: while( my $logfileobj = shift(@$Log) )
		{
			my $filehandle = undef();	# (GLOB) File handle of each log file
			my $kanazciitr = undef();	# (Kanadzuchi::Iterator)
			my $jsonstring = q();		# (String) Loaded JSON/YAML string
			my $thiscached = {};		# (Ref->Hash) Cached data of each table
			my $thismtoken = q();		# (String) This record's message token
			my $thismepoch = 0;		# (Integer) Bounced time
			my $thisstatus = 0;		# (Integer) Returned status value
			my $execinsert = 0;		# (Integer) Flag; Exec INSERT

			ref($logfileobj) eq q|GLOB|
				? $filehandle = $logfileobj
				: open( $filehandle, q{<}, $logfileobj );

			READ_EACH_LINE: while( <$filehandle> )
			{
				# Incremant loaded data size, loaded lines
				$loadedline++;
				$loadedsize += length($_);

				# Check limit the number of records
				if( $xsoftlimit > 0 && ($execstatus->{'insert'} + $recinthedb) >= $xsoftlimit )
				{
					# Exceeds limit!
					$execstatus->{'exceed'}++;
					next();
				}

				# Read JSON string from the log
				$jsonstring = $_; chomp($jsonstring);
				$kanazciitr = Kanadzuchi::Mail::Stored::YAML->loadandnew(\$jsonstring);

				READ_AND_UPDATE: while( my $parseddata = $kanazciitr->next() )
				{
					# Check cached data
					$thismtoken = $parseddata->token();
					$thismepoch = $parseddata->bounced->epoch();
					$thiscached = $tablecache->getit( $xntabalias, $thismtoken );
					$execinsert = 0;

					if( exists($thiscached->{'bounced'}) )
					{
						# Cache hit!
						# This record's bounced date is OLDER THAN the record in the cache.
						if( $thiscached->{'bounced'} >= $thismepoch )
						{
							$execstatus->{'tooold'}++;
							next();
						}
					}
					else
					{
						# No cache data of this entity
						if( $parseddata->findbytoken($xntableobj,$tablecache) )
						{
							# The record that has same token exists in the database
							$thiscached = $tablecache->getit( $xntabalias, $thismtoken );

							if( $thiscached->{'bounced'} >= $thismepoch )
							{
								# Bounced date of this record is older than the record in the database.
								$execstatus->{'tooold'}++;
								next();
							}
							elsif( ! ($Cmd->operation & $Cmd->option->{'force'}) && $thiscached->{'reason'} eq 'whitelisted' )
							{
								# The whitelisted record is not updated without --force option.
								$execstatus->{'whited'}++;
								next();
							}
						}
						else
						{
							# Record that have same token DOES NOT EXIST in the database
							# Does the senderdomain exist in the mastertable?
							if( $sddomtable->getidbyname($parseddata->senderdomain()) )
							{
								$execinsert = 1;
							}
							else
							{
								# The senderdomain DOES NOT EXIST in the mastertable
								# Set this senderdomain into negative cache
								$execstatus->{'nofrom'}++;
								$snegativec->{ $parseddata->senderdomain }++;
								next();
							}
						}

					}

					# Check negative cache
					if( $snegativec->{ $parseddata->senderdomain } )
					{
						# The senderdomain exists in the negative cache
						$execstatus->{'nofrom'}++;
						$snegativec->{ $parseddata->senderdomain }++;
						next();
					}

					# UPDATE OR INSERT
					if( $execinsert )
					{
						# INSERT this record INTO the database
						$thisstatus = $parseddata->insert($xntableobj,$mastertabs,$tablecache);
					warn 'INSERT'.$thisstatus;
						( $thisstatus > 0 ) ? $execstatus->{'insert'}++ : $execstatus->{'failed'}++;
					}
					else
					{
						$thisstatus = $parseddata->update($xntableobj,$tablecache);
						( $thisstatus == 1 ) ? $execstatus->{'update'}++ : $execstatus->{'failed'}++;
					}

				} # End of while(READ_AND_UPDATE)

			}
			continue
			{
				$theprogbar->update( $loadedline ) if( defined $theprogbar );
			} # End of while(READ_EACH_FILE)

			close($filehandle);

		} # End of while(LOAD_EACH_FILE)

		# Verbose messages of update status and cache information
		$Cmd->d(2,sprintf("%5d Records are successfully inserted\n", $execstatus->{'insert'} ));
		$Cmd->d(2,sprintf("%5d Records are successfully updated\n",  $execstatus->{'update'} ));
		$Cmd->d(2,sprintf("%5d Records are skipped|no senderdomain\n", $execstatus->{'nofrom'} ));
		$Cmd->d(2,sprintf("%5d Records are skipped|older or same time stmap\n", $execstatus->{'tooold'} ));
		$Cmd->d(2,sprintf("%5d Records are skipped|reason is whitelisted\n", $execstatus->{'whited'} ));
		$Cmd->d(2,sprintf("%5d Records are skipped|exceeds limit:%d\n", $execstatus->{'exceed'}, $xsoftlimit ));
		$Cmd->d(2,sprintf("%5d Records are failed to insert or update\n", $execstatus->{'failed'} ));

		if( $Cmd->operation & $Cmd->option->{'batch'} )
		{
			# Batch mode, output as a block style YAML format
			my $batchinfo = q();
			my $skippedis = 0;
			map { $skippedis += $execstatus->{$_} } ( qw{nofrom tooold whited exceed} );

			$batchinfo .= sprintf( qq|  record: %d\n|, $thelinesof );
			$batchinfo .= sprintf( qq|  insert: %d\n|, $execstatus->{'insert'} );
			$batchinfo .= sprintf( qq|  update: %d\n|, $execstatus->{'update'} );

			$batchinfo .= sprintf( qq|  skipped:\n| );
			$batchinfo .= sprintf( qq|    no-senderdomain: %d\n|, $execstatus->{'nofrom'} );
			$batchinfo .= sprintf( qq|    too-old-or-same: %d\n|, $execstatus->{'tooold'} );
			$batchinfo .= sprintf( qq|    is-whitelisted: %d\n|, $execstatus->{'whited'} );
			$batchinfo .= sprintf( qq|    exceeds-limit: %d\n|, $execstatus->{'exceed'} );

			if( $xntableobj->error->{'count'} || grep { $mastertabs->{$_}->error->{'count'} > 0 } keys(%$mastertabs) )
			{
				$batchinfo .= sprintf( qq|  failed:\n| );
				$batchinfo .= sprintf( qq|    bouncelogs: %d\n|, $xntableobj->error->{'count'} );
				$batchinfo .= sprintf( qq|    mastertables:\n| );
				$batchinfo .= sprintf( qq|      addressers: %d\n|, $mastertabs->{'addressers'}->error->{'count'} );
				$batchinfo .= sprintf( qq|      senderdomains: %d\n|, $mastertabs->{'senderdomains'}->error->{'count'} );
				$batchinfo .= sprintf( qq|      destinations: %d\n|, $mastertabs->{'destinations'}->error->{'count'} );
				$batchinfo .= sprintf( qq|      providers: %d\n|, $mastertabs->{'providers'}->error->{'count'} );
			}

			if( scalar values( %{ $tablecache->count } ) )
			{
				$batchinfo .= sprintf( qq|  cache:\n| );
				$batchinfo .= sprintf( qq|    positive:\n| );
				$batchinfo .= sprintf( qq|      bouncelogs: %d\n|, $tablecache->count->{'bouncelogs'} || 0 );
				$batchinfo .= sprintf( qq|      mastertables:\n| );
				$batchinfo .= sprintf( qq|        addressers: %d\n|, $tablecache->count->{'addressers'} || 0 );
				$batchinfo .= sprintf( qq|        senderdomains: %d\n|, $tablecache->count->{'senderdomains'} || 0 );
				$batchinfo .= sprintf( qq|        destinations: %d\n|, $tablecache->count->{'destinations'} || 0 );
				$batchinfo .= sprintf( qq|        providers: %d\n|, $tablecache->count->{'providers'} || 0 );
			}

			if( scalar values(%$snegativec) )
			{
				$batchinfo .= sprintf( qq|    negative:\n| );
				$batchinfo .= sprintf( qq|      mastertables:\n| );
				$batchinfo .= sprintf( qq|        senderdomains:\n| );
				map { $batchinfo .= 
						sprintf( qq|          %s: %d\n|, $_, $snegativec->{$_} )
					} keys( %$snegativec );
			}

			$Cmd->batchstatus(\$batchinfo);
		}

	} # End of if(UPDATE)
	elsif( $Cmd->operation & ( $Cmd->option->{'remove'} + $Cmd->option->{'disable'} ) )
	{
		require Kanadzuchi::String;
		my $doesexist = 0;
		my $itsstatus = 0;
		my $operation = q();
		my $wherecond = undef();

		try {
			if( ! exists($Cnd->{'id'}) && ! exists($Cnd->{'token'}) )
			{
				Kanadzuchi::Exception::Command->throw( '-text' => 'There are neither --id nor --token' );
			}

			if( exists($Cnd->{'id'}) && ! $xntableobj->is_validid($Cnd->{'id'}) )
			{
				Kanadzuchi::Exception::Command->throw( '-text' => 'The argument of --id is invalid!' );
			}

			if( exists($Cnd->{'token'}) && ! Kanadzuchi::String->is_validtoken($Cnd->{'token'}) )
			{
				Kanadzuchi::Exception::Command->throw( '-text' => 'The argument of --token is invalid!' );
			}

			$Cmd->d( 1, sprintf( "WHERE id = %d\n", $Cnd->{'id'} ) ) if( $Cnd->{'id'} );
			$Cmd->d( 1, sprintf( "WHERE token = '%s'\n", $Cnd->{'token'} ) ) if( $Cnd->{'token'} );

			$wherecond = $Cnd;
			$doesexist = $xntableobj->count( $wherecond );
			Kanadzuchi::Exception::Data->throw( 
				'-text' => 'No such record: '.sprintf("id = %d, token = %s",
						( $Cnd->{'id'} ? $Cnd->{'id'} : '?' ),
						( $Cnd->{'token'} ? $Cnd->{'token'} : 'none' ) ) ) unless( $doesexist );
		}
		otherwise {
			$Cmd->exception(shift());
			$Cmd->abort();
		};


		if( $Cmd->operation & $Cmd->option->{'remove'} )
		{
			$operation = 'remove';
			$itsstatus = $xntableobj->remove($wherecond);
		}
		elsif( $Cmd->operation & $Cmd->option->{'disable'} )
		{
			$operation = 'disable';
			$itsstatus = $xntableobj->disable($wherecond);
		}

		# Verbose messages of update status and cache information
		$Cmd->d(2,sprintf("%d Record is successfully %sd\n", $itsstatus, $operation ));

		if( $Cmd->operation & $Cmd->option->{'batch'} )
		{
			# Batch mode, output as a block style YAML format
			my $batchinfo = q();

			$batchinfo .= sprintf( qq|  %s: %d\n|, $operation, $itsstatus );

			if( $xntableobj->error->{'count'} )
			{
				$batchinfo .= sprintf( qq|  failed:\n| );
				$batchinfo .= sprintf( qq|    bouncelogs: %d\n|, $xntableobj->error->{'count'} );
			}
			$Cmd->batchstatus(\$batchinfo);
		}

	} # End of if(remove|disable)

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
	my $operation = 0;

	# Variables for decide operation
	my (
		$opt_batch,
		$opt_before,
		$opt_cleanup,
		$opt_conf,
		$opt_disable,
		$opt_file,
		$opt_force,
		$opt_host,
		$opt_id,
		$opt_port,
		$opt_remove,
		$opt_update,
		$opt_test,
		$opt_today,
		$opt_token,
		$opt_type,
		$opt_yesterday,
		$opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'B'		=> \$opt_batch,
			'batch'		=> \$opt_batch,
			'conf=s'	=> \$opt_conf,
			'C=s'		=> \$opt_conf,
			'cleanup'	=> \$opt_cleanup,
			'test'		=> \$opt_test,
			'T'		=> \$opt_test,
			'help'		=> sub { help(); exit(0); },
			'silent'	=> sub { $Cmd->silent(1); },
			'verbose'	=> \$opt_verbose,
			'v+'		=> \$opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Database options
			'host=s'	=> \$opt_host,
			'port=i'	=> \$opt_port,
			'type=s'	=> \$opt_type,

			# Date options, require --update option, and Update options
			'update'	=> \$opt_update,
			'U'		=> \$opt_update,
			'file=s'	=> \$opt_file,
			'f=s'		=> \$opt_file,
			'force'		=> \$opt_force,
			't'		=> \$opt_today,
			'today'		=> \$opt_today,
			'y'		=> \$opt_yesterday,
			'yesterday'	=> \$opt_yesterday,
			'b=i'		=> \$opt_before,
			'before=i'	=> \$opt_before,

			# Condition, for --remove and --diasble
			'disable'	=> \$opt_disable,
			'remove'	=> \$opt_remove,
			'id=i'		=> \$opt_id,
			'token=s'	=> \$opt_token,
		);


	# (verbose|debug) mode
	$Cmd->debuglevel( ( $opt_verbose ? $opt_verbose : 0 ) - 1 );

	# Output results as a YAML in batch mode 
	$operation |= $Cmd->option->{'batch'} if($opt_batch);

	# Specify Config File(YAML)	
	if( defined $opt_conf )
	{
		# Use specified config file(YAML)
		$operation |= $Cmd->option->{'conf'};
		$Cmd->cf( new Path::Class::File($opt_conf) );
	}
	elsif( $opt_test )
	{
		# Test mode,
		$operation |= $Cmd->option->{'test'};
		$Cmd->cf( new Path::Class::File('/dev/null'));
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
	}

	# Database Statement
	if( $opt_update )
	{
		$operation |= $Cmd->option->{'database'}; 
		$operation |= $Cmd->option->{'update'};
		$operation |= $Cmd->option->{'force'} if( $opt_force );
	}
	elsif( $opt_remove || $opt_disable )
	{
		$operation |= $Cmd->option->{'database'}; 
		$operation |= $Cmd->option->{'remove'} if( $opt_remove);
		$operation |= $Cmd->option->{'disable'} if( $opt_disable );
		$Cnd->{'id'} = $opt_id if( $opt_id );
		$Cnd->{'token'} = $opt_token if( $opt_token );
	}

	# Clean up
	if( $opt_cleanup )
	{
		$operation |= $Cmd->option->{'database'}; 
		$operation |= $Cmd->option->{'cleanup'};
	}

	# Database spec option, Override values in the config file
	if( $opt_host ){ $Rdb->hostname($opt_host); }
	if( $opt_type ){ $Rdb->dbtype($opt_type); }
	if( $opt_port ){ $Rdb->port($opt_port); }

	DETECT_LOG_FILES: {

		if( $opt_today || $opt_yesterday || $opt_before )
		{
			# The day
			$Day = 0 if( $opt_today );
			$Day = 1 if( $opt_yesterday );
			$Day = abs($opt_before) if( defined $opt_before );
			last(DETECT_LOG_FILES);
		}

		last(DETECT_LOG_FILES) if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' );

		my @_logfs = @ARGV;
		map { $_ =~ y{[ ]}{}d; } @_logfs;
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logfs;

		@$Log = map { Path::Class::File->new($_); } @_logfs;
	}

	# Check whether or not Required options are specified.
	return($operation);
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
	printf( STDERR "Usage: %s -U [OPTIONS] file1 [, file2 [, file3 [,...]]]\n", $Cmd->calledfrom() );
	printf( STDERR "Usage: cat file1 | %s -U [OPTIONS]\n", $Cmd->calledfrom() );
	printf( STDERR "Usage: %s DELETE and DISABLE OPTIONS  \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * (UP)DATE OPTIONS\n" );
	printf( STDERR "    -U, --update        : UPDATE or INSERT records in the database from the log file\n");
	printf( STDERR "                          which is decided by -b, -y, -t or -f option.\n" );
	printf( STDERR "    -b, --before <n>    : Use a log the day before of the <n>th\n");
	# printf( STDERR "    --date <string>     : Use a log of given date('2008-02-11')\n");
	printf( STDERR "    -y, --yesterday     : Use yesterday's log.\n");
	printf( STDERR "    -t, --today         : Use today's log(default)\n");
	printf( STDERR "\n" );
	printf( STDERR " * DELETE and DISABLE OPTIONS\n" );
	printf( STDERR "    --remove            : DELETE a record FROM the database(require --id or --token)\n");
	printf( STDERR "    --disable           : Turn disable column of a record ON(require --id or --token)\n");
	printf( STDERR "    --id <id>           : Specify ID number of the record to delete or disable\n");
	printf( STDERR "    --token <string>    : Specify message token of the record to delete or disable\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE CONTROL OPTIONS\n");
	printf( STDERR "    --force             : Also whitelisted records are updated, this option\n");
	printf( STDERR "                          requires -U(--update) option.\n" );
	# printf( STDERR "    --cleanup           : DELETE disabled records(not implemented)\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>    : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -B, --batch         : Run in batch mode, results are printed in YAML format.\n");
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    --silent            : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s --today --update -v\n", $Cmd->calledfrom() );
	printf( STDERR "  %s --yesterday --update --force\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -C./test-run.cf /tmp/hers.log --update \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}

__END__
