#__PERLEXECUTABLE__
# $Id: databasectl.PL,v 1.5 2010/03/19 07:38:53 ak Exp $
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
use Kanadzuchi::RDB::Schema;
use Kanadzuchi::RDB;
use Error ':try';
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci = undef();		# Kanadzuchi System object
my $Cmd = undef();		# Kanadzuchi::UI::CLI object
my $Rdb = undef();		# Kanadzuchi::RDB object
my $Day = undef();		# The day (before|after), 0 = today, -1 = yesterday
my $Lfs = [];			# Log files for INSERT or UPDATE

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'usedb'		=> ( 1 << 2 ),
	'UPDATE'	=> ( 1 << 3 ),
	'REMOVE'	=> ( 1 << 4 ),
	'force'		=> ( 1 << 5 ),
	'disabled'	=> ( 1 << 6 ),
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

# Create Kanadzuchi::RDB object
$Rdb = new Kanadzuchi::RDB( 'count' => 0, 'cache' => {}, );

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

if( $Cmd->operation & $Cmd->option->{'usedb'} )
{
	#  _   _ ____  _____   ____  ____  
	# | | | / ___|| ____| |  _ \| __ ) 
	# | | | \___ \|  _|   | | | |  _ \ 
	# | |_| |___) | |___  | |_| | |_) |
	#  \___/|____/|_____| |____/|____/ 
	#
	# Use Database
	require Kanadzuchi::Mail::Stored::YAML;
	require Kanadzuchi::Mail::Stored::RDB;

	# Set values to Kanadzuchi::RDB object, Create data source name
	try {
		unless( $Rdb->setup($Zci->config->{'database'}) )
		{
			Kanadzuchi::Exception::Database->throw( '-text' => q{Failed to setup} );
		}

		if( length($Rdb->datasn()) == 0 )
		{
			# Unsupported database type
			Kanadzuchi::Exception::Database->throw(
				'-text' => q{Unsupported database type: }.$Rdb->dbtype );
		}
		elsif( length($Rdb->datasn()) < 5 )
		{
			# Datatabase name or database type is not defined
			Kanadzuchi::Exception::Database->throw( 
				'-text' => q{Failed to create data source name} );
		}

		# Connect and set database handle
		$Rdb->handle( Kanadzuchi::RDB::Schema->connect(
				$Rdb->datasn(), $Rdb->username(), $Rdb->password()) );
		$Cmd->d(2,q{Connecting to the database}.qq{\n}) if(defined($Rdb->handle()));

		if( $Rdb->hostname() && $Rdb->port() )
		{
			$Cmd->d(2,sprintf("Database host = %s:%d\n", $Rdb->hostname(),$Rdb->port()));
		}
		else
		{
			$Cmd->d(2,qq{Database host = Socket\n});
		}
		$Cmd->d(2,sprintf("Database name = %s(%s)\n", $Rdb->dbname(), $Rdb->dbtype()));
		$Cmd->d(2,sprintf("Database user = %s\n", $Rdb->username()));
	}
	catch Kanadzuchi::Exception::Database with {
		$Cmd->exception(shift());
		$Cmd->abort();
	};


	# Read log file for UPDATE or DELETE
	if( $Cmd->operation & ( $Cmd->option->{'UPDATE'} + $Cmd->option->{'REMOVE'} + $Cmd->option->{'disabled'} ) )
	{
		#  _   _ ____  ____    _  _____ _____     ____  _____ _     _____ _____ _____ 
		# | | | |  _ \|  _ \  / \|_   _| ____|   |  _ \| ____| |   | ____|_   _| ____|
		# | | | | |_) | | | |/ _ \ | | |  _|     | | | |  _| | |   |  _|   | | |  _|  
		# | |_| |  __/| |_| / ___ \| | | |___ _  | |_| | |___| |___| |___  | | | |___ 
		#  \___/|_|   |____/_/   \_\_| |_____( ) |____/|_____|_____|_____| |_| |_____|
		#                                    |/        
		# Create the log file name by the day(-t, -y, or -b option )
		if( scalar(@$Lfs) == 0 && defined($Day) )
		{
			# Set the log file name
			my $_theday = bless( (localtime() - ( $Day * 86400 )), q|Time::Piece| );
			my $_thelog = new Path::Class::File( sprintf("%s/%s.%s.%s", 
							$Zci->config->{'directory'}->{'log'},
							$Zci->config->{'file'}->{'storage'}->{'prefix'},
							$_theday->ymd('-'),
							$Zci->config->{'file'}->{'storage'}->{'suffix'} ));
			push( @$Lfs, $_thelog );
			$Cmd->d( 1, sprintf("Log file(date) = %s\n", $_thelog->stringify() ));
		}

		if( scalar(@$Lfs) )
		{
			try {
				unless( grep({ -e $_ && -f _ } @$Lfs) )
				{
					Kanadzuchi::Exception::IO->throw( '-text' => 'There is no log file' );
				}

				unless( grep({ -r $_ && -T _ } @$Lfs) )
				{
					Kanadzuchi::Exception::File->throw( '-text' => 'log is not readable or text file' );
				}
			}
			otherwise {
				$Cmd->exception(shift());
				$Cmd->abort();
			};
		}
		else
		{
			push( @$Lfs, \*STDIN );
		}


		try {
			LOAD_AND_NEW: foreach my $_lf ( @$Lfs )
			{
				push( @{$Rdb->records}, @{ Kanadzuchi::Mail::Stored::YAML->loadandnew( $_lf, 1 ) } );
				$Cmd->d( 2, sprintf( "Load log file = %s\n", 
						ref($_lf) eq q|Path::Class::File| ? $_lf->stringify() : q{<STDIN>} ));
			}

			Kanadzuchi::Exception::Data->throw(
				'-text' => 'No data in the log files' ) unless( scalar(@{$Rdb->records}) );
		}
		catch Kanadzuchi::Exception::Data with {
			$Cmd->exception(shift());
			$Cmd->abort();
		};


		my $_pgconfig = { 'currentpagenum' => 1, 'resultperpage' => 1, 'columnorderby' => 'id' };
		my $_wherecnd = { 'disabled' => 0 };
		Kanadzuchi::Mail::Stored::RDB->searchandnew( $Rdb, $_wherecnd, \$_pgconfig, 0 );

		my $_prbar = undef();	# Term::ProgressBar object
		my $_white = Kanadzuchi::Mail::Stored::YAML->rname2id('whitelisted');
		my $_curis = $_pgconfig->{'totalentries'} || 0;
		my $_maxis = $Zci->config->{'database'}->{'table'}->{'bouncelogs'}->{'maxrecords'} || 0;
		my $_times = { 'insert' => 0, 'update' => 0, 'nosender' => 0, 'exceedlimit' => 0,
				'older' => 0, 'error' => 0, 'whitelist' => 0, };
		my $_theid = { 'insert' => 0, 'update' => 0, };

		$Cmd->d(1,sprintf("Bounce messages in the log files = %d\n",scalar(@{$Rdb->records})));
		$Cmd->d(1,sprintf("Bounce messages in the db = %d\n",$_pgconfig->{'totalentries'}));
		$Cmd->d(1,sprintf("Record limit of the db = %d\n", $_maxis ) );


		if( $Cmd->debuglevel > -1 )
		{
			my $_pname = q(UPDATE|INSERT);
			eval{ require Term::ProgressBar; };

			$_pname = q(REMOVE) if( $Cmd->operation & $Cmd->option->{'REMOVE'} );
			$_pname = q(To disable) if( $Cmd->operation & $Cmd->option->{'disabled'} );

			$_prbar = new Term::ProgressBar( { 'fh' => \*STDERR, 'ETA' => q{linear},
					'name' => $_pname, 'count' => scalar(@{$Rdb->records}), });
		}

		if( $Cmd->operation & $Cmd->option->{'UPDATE'} )
		{
			#  _   _ ____  ____    _  _____ _____     ___ _   _ ____  _____ ____ _____ 
			# | | | |  _ \|  _ \  / \|_   _| ____|   |_ _| \ | / ___|| ____|  _ \_   _|
			# | | | | |_) | | | |/ _ \ | | |  _|      | ||  \| \___ \|  _| | |_) || |  
			# | |_| |  __/| |_| / ___ \| | | |___ _   | || |\  |___) | |___|  _ < | |  
			#  \___/|_|   |____/_/   \_\_| |_____( ) |___|_| \_|____/|_____|_| \_\|_|  
			#                                    |/ 
			# Make 'SenderDomain','HostGroups' table cache
			$Rdb->makecache('SenderDomains','domainname'); 
			$Rdb->cache->{'Providers'} = {};
			$Rdb->cache->{'Addressers'} = {};
			$Rdb->cache->{'MesgTokens'} = {};
			$Rdb->cache->{'Destinations'} = {};

			my $_rindex = 0;
			my $_dcache = {};

			foreach my $_rr ( @{$Rdb->records} )
			{
				$_dcache = {};

				unless( exists($Rdb->cache->{'SenderDomains'}->{$_rr->senderdomain()}) )
				{
					# There is no sender domain in the database and the cache
					$_prbar->update() if( defined($_prbar) );
					$_times->{'nosender'}++;
					next();
				}

				if( $_rr->findbytoken($Rdb) )
				{
					$_dcache = $Rdb->cache->{'MesgTokens'}->{$_rr->token()};

					# The record that has same message token already exists
					if( $_rr->bounced->epoch <= $_dcache->{'bounced'} )
					{
						# The record is too older than the record in the database, Skip
						$_times->{'older'}++;
						$_prbar->update() if(defined($_prbar));
						next();
					}

					# The record in the db is whitelisted ?
					if( ! ( $Cmd->operation & $Cmd->option->{'force'} ) && ( $_dcache->{'reason'} == $_white ) )
					{
						# with no --force option, no whitelisted records are updated
						$_times->{'whitelist'}++;
						$_prbar->update() if(defined($_prbar));
						next();
					}

					# The bounced machine time of the record is newer than the record 
					# in the database, do UPDATE
					$_theid->{'update'} = $_rr->update( $Rdb, $_dcache->{'id'} );
					$_times->{'update'}++ if( $_theid->{'update'} == 1 );
					$_times->{'error'}++ if( $_theid->{'update'} == 0 );	# 0e0
					$_prbar->update() if(defined($_prbar));
				}
				else
				{
					# If 'maxrecords < ( current_record + inserted )' go to the next loop
					if( $_maxis && $_maxis <= ( $_curis + $_times->{'insert'} ) )
					{
						$_times->{'exceedlimit'}++;
					}
					else
					{
						# There is no record that has same message token, do INSERT
						$_theid->{'insert'} = $_rr->insert($Rdb);
						if( $_theid->{'insert'} )
						{
							$_times->{'insert'}++
						}
						else
						{
							$_times->{'error'}++;
						}
					}
					$_prbar->update() if(defined($_prbar));
				}
			}
			continue
			{
				# Flush the checked record
				$Rdb->records->[$_rindex++] = undef();
			} # End of the loop(for())

			if( $Cmd->debuglevel > 1 || ( $Cmd->operation & $Cmd->option->{'batch'} ) )
			{
				$Cmd->d(2,sprintf("%5d records are inserted\n", $_times->{'insert'} ));
				$Cmd->d(2,sprintf("%5d records are updated\n", $_times->{'update'} ));
				$Cmd->d(2,sprintf("%5d records are skipped(no sender domain)\n", $_times->{'nosender'} ));
				$Cmd->d(2,sprintf("%5d records are skipped(older or same record)\n", $_times->{'older'} ));
				$Cmd->d(2,sprintf("%5d records are skipped(is whitelist)\n", $_times->{'whitelist'} ));
				$Cmd->d(2,sprintf("%5d records are skipped(exceed limit:%d)\n", $_times->{'exceedlimit'}, $_maxis ));
				$Cmd->d(2,sprintf("%5d errors are occurred\n", $_times->{'error'} ));

				if( $Cmd->operation & $Cmd->option->{'batch'} )
				{
					# Batch mode, output as a (YAML|JSON) format(flow style)
					printf( STDOUT 
						qq|{ "insert": %d, "update": %d, "error": %d, "skip": %d, |.
						qq|"asitis": { "nosender": %d, "older": %d, "whitelist": %d, "exceedlimit": %d } }\n|,
						$_times->{'insert'}, $_times->{'update'}, $_times->{'error'}, 
						( $_times->{'nosender'}
							+ $_times->{'older'}
							+ $_times->{'whitelist'}
							+ $_times->{'exceedlimit'}
						),
						$_times->{'nosender'}, $_times->{'older'}, $_times->{'whitelist'},
						$_times->{'exceedlimit'}
					);
				}

				foreach my $_x ('Providers','Addressers','SenderDomains','Destinations','MesgTokens' )
				{
					$Cmd->d( 3, sprintf("%5d cached records in the %s\n", 
							my $_k = keys( %{ $Rdb->cache->{$_x} } ), $_x ));
				}
			}
		}
		elsif( $Cmd->operation & $Cmd->option->{'REMOVE'} )
		{
			#  ____  _____ _     _____ _____ _____ 
			# |  _ \| ____| |   | ____|_   _| ____|
			# | | | |  _| | |   |  _|   | | |  _|  
			# | |_| | |___| |___| |___  | | | |___ 
			# |____/|_____|_____|_____| |_| |_____|
			# 

			# Not implemented yet.
		}
		elsif( $Cmd->operation & $Cmd->option->{'disabled'} )
		{
			#  ____ ___ ____    _    ____  _     _____ 
			# |  _ \_ _/ ___|  / \  | __ )| |   | ____|
			# | | | | |\___ \ / _ \ |  _ \| |   |  _|  
			# | |_| | | ___) / ___ \| |_) | |___| |___ 
			# |____/___|____/_/   \_\____/|_____|_____|
			# 

			# Not implemented yet.
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
		$_opt_batch,
		$_opt_conf,
		$_opt_file,
		$_opt_host,
		$_opt_port,
		$_opt_type,
		$_opt_disabled,
		$_opt_cleanup,
		$_opt_update,
		$_opt_force,
		$_opt_remove,
		$_opt_today,
		$_opt_yesterday,
		$_opt_before,
		$_opt_test,
		$_opt_silent,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'B'		=> \$_opt_batch,
			'batch'		=> \$_opt_batch,
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'cleanup'	=> \$_opt_cleanup,
			'disabled'	=> \$_opt_disabled,
			'remove'	=> \$_opt_remove,
			'test'		=> \$_opt_test,
			'T'		=> \$_opt_test,
			'help'		=> sub { help(); exit(0); },
			'silent'	=> \$_opt_silent,
			'verbose'	=> \$_opt_verbose,
			'v+'		=> \$_opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Database options
			'host=s'	=> \$_opt_host,
			'port=i'	=> \$_opt_port,
			'type=s'	=> \$_opt_type,

			# Date options, require --update option, and Update options
			'update'	=> \$_opt_update,
			'U'		=> \$_opt_update,
			'file=s'	=> \$_opt_file,
			'f=s'		=> \$_opt_file,
			'force'		=> \$_opt_force,
			't'		=> \$_opt_today,
			'today'		=> \$_opt_today,
			'y'		=> \$_opt_yesterday,
			'yesterday'	=> \$_opt_yesterday,
			'b=i'		=> \$_opt_before,
			'before=i'	=> \$_opt_before,
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
	}

	# Database Statement
	if( $_opt_update )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'UPDATE'};
		$_operation |= $Cmd->option->{'force'} if( $_opt_force );
	}
	elsif( $_opt_remove )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'REMOVE'};
	}
	elsif( $_opt_disabled )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'disabled'};
	}

	# Clean up
	if( $_opt_cleanup )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'cleanup'};
	}

	# Output results as a YAML in batch mode 
	$_operation |= $Cmd->option->{'batch'} if($_opt_batch);

	# Database spec option, Override values in the config file
	if( $_opt_host ){ $Rdb->hostname($_opt_host); }
	if( $_opt_type ){ $Rdb->dbtype($_opt_type); }
	if( $_opt_port ){ $Rdb->port($_opt_port); }

	DETECT_LOG_FILES: {

		if( $_opt_today || $_opt_yesterday || $_opt_before )
		{
			# The day
			$Day = 0 if( $_opt_today );
			$Day = 1 if( $_opt_yesterday );
			$Day = abs($_opt_before) if( defined($_opt_before) );
			last(DETECT_LOG_FILES);
		}

		last(DETECT_LOG_FILES) if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' );

		my @_logfs = @ARGV;

		map { $_ =~ y{[, ]}{}d; } @_logfs;
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logfs;

		@$Lfs = map { Path::Class::File->new($_); } @_logfs;
	}

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
	printf( STDERR "Usage: %s -U [OPTIONS] file1 [, file2 [, file3 [,...]]]\n", $Cmd->calledfrom() );
	printf( STDERR "Usage: cat file1 | %s -U [OPTIONS]\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE CONTROL OPTIONS(Overrides the value in the config file)\n" );
	# printf( STDERR "    --cleanup           : DELETE disabled records(not implemented)\n");
	# printf( STDERR "    --remove            : DELETE FROM the log file(not implemented)\n");
	# printf( STDERR "    --disabled          : Turn disabled colum ON(not implemented)\n");
	printf( STDERR "    -U, --update        : UPDATE or INSERT records in the database from the log file\n");
	printf( STDERR "                          which is decided by -b, -y, -t or -f option.\n" );
	printf( STDERR "    --force             : Also whitelisted records are updated, this option\n");
	printf( STDERR "                          requires -U(--update) option.\n" );
	printf( STDERR "\n" );
	printf( STDERR " * (UP)DATE OPTIONS\n" );
	printf( STDERR "    -b, --before <n>    : Use a log the day before of the <n>th\n");
	# printf( STDERR "    --date <string>     : Use a log of given date('2008-02-11')\n");
	printf( STDERR "    -y, --yesterday     : Use yesterday's log.\n");
	printf( STDERR "    -t, --today         : Use today's log(default)\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>    : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -B, --batch         : Run in batch mode, results are printed in YAML|JSON format.\n");
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
