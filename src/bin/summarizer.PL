#__PERLEXECUTABLE__
# $Id: summarizer.PL,v 1.6 2010/06/25 19:32:15 ak Exp $
# -Id: summarizer.PL,v 1.13 2010/02/22 05:09:01 ak Exp -
# -Id: summarizer.PL,v 1.2 2009/10/06 09:10:32 ak Exp -
# -Id: summarizer.PL,v 1.3 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi:Command::
                                             ##                       
  ##### ##  ## ##  ## ##  ##  ####  #####        ###### ####  #####   
 ##     ##  ## ###### ######     ## ##  ##  ###     ## ##  ## ##  ##  
  ####  ##  ## ###### ######  ##### ##       ##    ##  ###### ##      
     ## ##  ## ##  ## ##  ## ##  ## ##       ##   ##   ##     ##      
 #####   ##### ##  ## ##  ##  ##### ##      #### ###### ####  ##      
package Kanadzuchi::Command::Summarizer;

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

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Database object
my $Rdb;		# (Kanadzuchi::BdDR) Database object
my $Fmt = q();		# (String) Output format
my $Day = 0;		# (Integer) Date offset
my $Log = [];		# (Ref->Array) Log files
my $Col = [];		# (Ref->Array) Aggregate by ...

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'aggregate'	=> ( 1 << 2 ),
	'database'	=> ( 1 << 3 ),
	'summary'	=> ( 1 << 4 ),
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

if( $Cmd->operation & $Cmd->option->{'aggregate'} )
{
	#     _                                    _       
	#    / \   __ _  __ _ _ __ ___  __ _  __ _| |_ ___ 
	#   / _ \ / _` |/ _` | '__/ _ \/ _` |/ _` | __/ _ \
	#  / ___ \ (_| | (_| | | |  __/ (_| | (_| | ||  __/
	# /_/   \_\__, |\__, |_|  \___|\__, |\__,_|\__\___|
	#         |___/ |___/          |___/               
	#                                                         
	my $statistics = undef();	# (Kanazuchi::Statistics::Stored::*) Statistics object
	my $agprogress = undef();	# (Term::ProgressBar ) Progress bar object
	my $asciitable = undef();	# (Text::ASCIITable) ASCII Table object
	my $samplesize = 0;		# (Integer) Sample size
	my $afrequency = 0;		# (Integer) Sum. of frequency
	my $aggregated = {};		# (Ref->Hash) Aggregated Data(Ref->Array)
	my $summarized = {};		# (Ref->Hash) Summarized Data(Ref->Array)
	my $outputdata = q();		# (String) Output data for displaying
	my $graphchara = '+';		# (String) Graph character in ASCII Table
	my $graphscale = 100;		# (Integer) Graph scale in ASCII Table


	if( $Rdb && ( $Cmd->operation & $Cmd->option->{'database'} ) )
	{
		# Aggregate records in the Database
		require Kanadzuchi::Statistics::Stored::BdDR;
		$statistics = new Kanadzuchi::Statistics::Stored::BdDR();

		# Set values to Kanadzuchi::BdDR object, Create data source name
		try {
			$Rdb->setup( $Zci->config->{'database'} );
			Kanadzuchi::Exception::Database->throw( '-text' => 'Failed to connect DB' ) unless $Rdb->connect();
			$Cmd->d(2,"Connecting to the database\n") if( defined $Rdb->handle() );

			( $Rdb->hostname() && $Rdb->port() )
				? $Cmd->d(2,sprintf("Database host = %s:%d\n", $Rdb->hostname(),$Rdb->port()))
				: $Cmd->d(2,qq{Database host = Socket\n});

			$Cmd->d(2,sprintf("Database name = %s(%s)\n", $Rdb->dbname(), $Rdb->dbtype()));
			$Cmd->d(2,sprintf("Database user = %s\n", $Rdb->username()));
			$Cmd->d(1,sprintf("Aggregate records in the Database: %s\n", $Rdb->dbname()));
		}
		catch Kanadzuchi::Exception::Database with {
			$Cmd->exception(shift());
			$Cmd->abort();
		};

		$statistics->handle( $Rdb->handle );
	}
	else
	{
		# Aggregate records in the log file
		require Kanadzuchi::Statistics::Stored::YAML;
		$statistics = new Kanadzuchi::Statistics::Stored::YAML();

		# Create the log file name by the day(-t, -y, or -b option )
		if( scalar(@$Log) == 0 && defined($Day) )
		{
			# Set the log file name
			my $_theday = bless( (localtime() - ( $Day * 86400 )), q|Time::Piece| );
			my $_thelog = new Path::Class::File( $Zci->get_logfile('r',{ 'data' => $_theday->ymd('-') }) );
			push( @$Log, $_thelog );
		}

		try {
			foreach my $f ( @$Log )
			{
				next() if( -e $f && -s _ && -T _ && -r _ );
				Kanadzuchi::Exception::File->throw( '-text' => 'No such file: '.$f ) unless( -e $f );
				Kanadzuchi::Exception::File->throw( '-text' => 'Cannot read: '.$f ) unless( -r $f );
				Kanadzuchi::Exception::File->throw( '-text' => 'Empty file: '.$f ) unless( -s $f );
				Kanadzuchi::Exception::File->throw( '-text' => 'Not text: '.$f ) unless( -T $f );
			}
			continue
			{
				$Cmd->d( 1, sprintf("Log file = %s\n", $f->stringify() ));
			}
		}
		catch Kanadzuchi::Exception::File with {
			$Cmd->exception(shift());
			$Cmd->abort();
		};

		$statistics->file( $Log );
		$statistics->load();

	}

	$Cmd->d( 1, sprintf("Aggregate by %s\n", join( ', ', @$Col ) ) );
	require Text::ASCIITable if( $Fmt eq 'asciitable' );
	require Term::ProgressBar if( $Cmd->debuglevel > -1 );

	# Prepare the progress bar
	if( -t STDIN && $Cmd->debuglevel > -1 )
	{
		$agprogress = new Term::ProgressBar( { 
					'fh' => \*STDERR,
					'ETA' => 'linear',
					'name' => 'Aggregation',
					'count' => scalar(@$Col) * 2 } );
	}

	if( $Fmt eq 'asciitable' )
	{
		;
	}

	while( my $c = shift @$Col )
	{
		$aggregated->{$c} = $statistics->aggregate($c);
		map { $samplesize += $_->{'size'} } @{ $statistics->cache() } unless $samplesize;
		map { $afrequency += $_->{'freq'} } @{ $statistics->cache() } unless $afrequency;
		$agprogress->update() if( defined $agprogress );

		if( $Cmd->operation & $Cmd->option->{'summary'} )
		{
			# Calculate descriptive statistics
			foreach my $x ( 'size', 'freq' )
			{
				$statistics->sample( [ map { $_->{$x} } @{ $statistics->cache() } ] );
				$statistics->rounding(3);
				$summarized->{$c}->{$x}->{'min'} = $statistics->min();
				$summarized->{$c}->{$x}->{'max'} = $statistics->max();
				$summarized->{$c}->{$x}->{'mean'} = $statistics->mean();
				$summarized->{$c}->{$x}->{'stddev'} = $statistics->stddev();
			}
		}
		$agprogress->update() if( defined $agprogress );
	}

	foreach my $col ( keys %$aggregated )
	{
		my $_ratio = {};
		my $_graph = {};

		foreach my $e ( @{ $aggregated->{$col} } )
		{
			$_ratio->{$e}->{'size'} = $samplesize > 0 ? sprintf( "%0.3f", $e->{'size'} / $samplesize ): 'NA';
			$_ratio->{$e}->{'freq'} = $afrequency > 0 ? sprintf( "%0.3f", $e->{'freq'} / $afrequency ): 'NA';
			$_graph->{$e} = $graphchara x int( ( $e->{'size'} / $samplesize ) * $graphscale );
		}

		if( $Fmt eq 'asciitable' )
		{
			# Human readable ASCII table
			$asciitable = new Text::ASCIITable( { 'headingText' => 'Aggregate by '.$col } );
			$asciitable->setOptions( 'outputWidth', 80 );
			$asciitable->setCols( 'Name', 'Count', 'Freq.', 'Ratio(Count/Freq.)', 'Graph(Count)' );

			foreach my $e ( @{ $aggregated->{$col} } )
			{
				$asciitable->addRow( $e->{'name'}, $e->{'size'}, $e->{'freq'},
							' '.$_ratio->{$e}->{'size'}.' / '.$_ratio->{$e}->{'freq'},
							$_graph->{$e} );
			}
			$asciitable->addRowLine();
			$asciitable->addRow( 'sum', $samplesize, $afrequency, ' 1.000 / 1.000' );

			if( $Cmd->operation & $Cmd->option->{'summary'} )
			{
				$asciitable->addRowLine();
				foreach my $d ( 'min', 'mean', 'max', 'stddev' )
				{
					$asciitable->addRow( $d, 
							sprintf("%0.2f", $summarized->{$col}->{'size'}->{$d} ),
							sprintf("%0.2f", $summarized->{$col}->{'freq'}->{$d} ),
					);
				}
			}
			print $asciitable->draw();
		}
		else
		{
			# YAML format
			printf( "%s:\n", $col );
			printf( "  data:\n" );

			foreach my $y ( @{ $aggregated->{$col} } )
			{
				printf( "    - { name: %s, count: %d, ratio-of-count: %0.3f, freq: %d, ratio-of-freq: %0.3f }\n",
					$y->{'name'}, $y->{'size'}, $_ratio->{$y}->{'size'}, $y->{'freq'}, $_ratio->{$y}->{'freq'} );
			}

			printf( "  sum: { count: %d, freq: %d }\n", $samplesize, $afrequency );

			if( $Cmd->operation & $Cmd->option->{'summary'} )
			{
				printf( "  stat:\n" );
				foreach my $d ( 'min', 'mean', 'max', 'stddev' )
				{
					printf( "    %s: { count: %0.2f, freq: %0.2f }\n", $d,
							$summarized->{$col}->{'size'}->{$d},
							$summarized->{$col}->{'freq'}->{$d} );
				}
			}
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
	my $operation = 0;

	# Variables for decide operation
	my (
		$opt_aggregate,
		$opt_aggregateall,
		$opt_before,
		$opt_conf,
		$opt_database,
		# $opt_date,
		$opt_format,
		$opt_host,
		$opt_port,
		$opt_silent,
		$opt_summary,
		$opt_test,
		$opt_today,
		$opt_type,
		$opt_verbose,
		$opt_yesterday,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'C=s'		=> \$opt_conf,
			'conf=s'	=> \$opt_conf,
			'help'		=> sub { help(); exit(0); },
			'T'		=> \$opt_test,
			'test'		=> \$opt_test,
			'silent'	=> sub { $Cmd->silent(1); },
			'verbose'	=> \$opt_verbose,
			'v+'		=> \$opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Date options
			'b=i'		=> \$opt_before,
			'before=i'	=> \$opt_before,
			# 'd=s'		=> \$opt_date,
			# 'date=s'	=> \$opt_date,
			't'		=> \$opt_today,
			'today'		=> \$opt_today,
			'y'		=> \$opt_yesterday,
			'yesterday'	=> \$opt_yesterday,

			# Aggreagate options
			'A'		=> \$opt_aggregateall,
			'aggregate-all'	=> \$opt_aggregateall,
			'a=s'		=> \$opt_aggregate,
			'aggregate=s'	=> \$opt_aggregate,
			's'		=> \$opt_summary,
			'summary'	=> \$opt_summary,

			# Format options
			'format=s'	=> \$opt_format,
			'F=s'		=> \$opt_format,

			# Database options
			'D'		=> \$opt_database,
			'database'	=> \$opt_database,
			'host=s'	=> \$opt_host,
			'port=i'	=> \$opt_port,
			'type=s'	=> \$opt_type,
		);


	# (verbose|debug|silent) mode
	$Cmd->debuglevel( ( $opt_verbose ? $opt_verbose : 0 ) - 1 );

	# Specify Config File(YAML)	
	if( defined($opt_conf) )
	{
		# Use specified config file(YAML)
		$operation |= $Cmd->option->{'conf'};
		$Cmd->cf( new Path::Class::File($opt_conf) );
	}
	elsif( $opt_test )
	{
		# Test mode,
		$Cmd->cf( new Path::Class::File('/dev/null'));
		$operation |= $Cmd->option->{'test'};
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
		$Cmd->cf->cleanup();
	}

	if( $opt_aggregateall || $opt_aggregate )
	{
		require Kanadzuchi::BdDR::BounceLogs::Masters;
		my $mastertable = q|Kanadzuchi::BdDR::BounceLogs::Masters::Table|;

		if( $opt_aggregate )
		{
			$opt_aggregate = 'w' if( lc $opt_aggregate eq 'r' );
			$Col = [ $mastertable->whichtable( lc substr($opt_aggregate,0,1) )];
			$Cmd->e('Invalid column name: '.$opt_aggregate ) unless( $Col->[0] );
		}
		else
		{
			foreach my $c qw(s d h p w)
			{
				push( @$Col, $mastertable->whichtable(lc $c) );
			}
		}

		map { $_ = lc $_; chop $_ } @$Col;
		$operation |= $Cmd->option->{'aggregate'};
		$operation |= $Cmd->option->{'summary'} if( $opt_summary );
	}
	else
	{
		$Cmd->e('Aggregation option -A or -a required ');
	}

	if( $opt_database )
	{
		# Create Kanadzuchi::BdDR object
		require Kanadzuchi::BdDR;
		$Rdb = new Kanadzuchi::BdDR();

		# Database spec option, Override values in the config file
		if( $opt_host ){ $Rdb->hostname($opt_host); }
		if( $opt_type ){ $Rdb->dbtype($opt_type); }
		if( $opt_port ){ $Rdb->port($opt_port); }
		$operation |= $Cmd->option->{'database'};
	}
	else
	{
		DETECT_LOG_FILES: {
			if( $opt_today || $opt_yesterday || $opt_before )
			{
				# The day
				$Day = 0 if( $opt_today );
				$Day = 1 if( $opt_yesterday );
				$Day = abs($opt_before) if( defined($opt_before) );
				last(DETECT_LOG_FILES);
			}
			last(DETECT_LOG_FILES) if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' );

			my @_logfs = @ARGV;
			map { $_ =~ y{[ ]}{}d; } @_logfs;
			map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logfs;

			@$Log = map { Path::Class::File->new($_); } @_logfs;
		}
	}

	# Output format options
	if( $opt_format )
	{
		my $_1stcharacter = substr( $opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq 'y' ? 'yaml' :
			$_1stcharacter eq 'a' ? 'asciitable' : 'asciitable';
	}
	else
	{
		$Fmt = 'asciitable';
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
	printf( STDERR "Usage: %s <AGGREGATE OPTION> [OPTIONS] [file]\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * AGGREGATION OPTION\n" );
	printf( STDERR "    -A, --aggregate-all : Aggregate by all of the following columns <c>.\n");
	printf( STDERR "    -a, --aggregate <c> : Aggregate by the following column <c>: \n");
	printf( STDERR "                          s = [s]enderdomain, d = [d]estinations\n");
	printf( STDERR "                          h = [h]ostgroup, p = [p]rovider, r,w = [r]easons([w]hy)\n");
	printf( STDERR "    -s, --summary       : Display descriptive statistics\n");
	printf( STDERR "\n" );
	printf( STDERR " * AGGREGATION OPTION(Data Source)\n" );
	printf( STDERR "    -b, --before <n>    : (Log file) Aggregate records in the log: the day before of the <n>th\n");
	printf( STDERR "    -y, --yesterday     : (Log file) Aggregate records in yesterday's log.\n");
	printf( STDERR "    -t, --today         : (Log file) Aggregate records in today's log(default)\n");
	printf( STDERR "    -D, --database      : (Database) Aggregate records in the database\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>    : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -F, --format <char> : Output(STDOUT only) format, the followings are available.\n");
	printf( STDERR "                          [y]aml, [a]sciitable (Default)\n");
	printf( STDERR "    --silent            : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s -At\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -ah __KANADZUCHIVAR__/log/hammer.2009-04-29.log\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}


__END__
