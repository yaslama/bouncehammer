#__PERLEXECUTABLE__
# $Id: datadumper.PL,v 1.3 2010/03/01 23:41:33 ak Exp $
# -Id: datadumper.PL,v 1.16 2010/02/21 20:09:01 ak Exp -
# -Id: datadumper.PL,v 1.3 2009/08/31 06:57:18 ak Exp -
# -Id: datadumper.pl,v 1.9 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Command::
                                                                        
     ##          ##             ##                                      
     ##   #### ###### ####      ##  ##  ## ##  ## #####   ####  #####   
  #####      ##  ##      ##  #####  ##  ## ###### ##  ## ##  ## ##  ##  
 ##  ##   #####  ##   ##### ##  ##  ##  ## ###### ##  ## ###### ##      
 ##  ##  ##  ##  ##  ##  ## ##  ##  ##  ## ##  ## #####  ##     ##      
  #####   #####   ### #####  #####   ##### ##  ## ##      ####  ##      
                                                  ##                    
package Kanadzuchi::Command::Datadumper;

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

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci = undef();		# Kanadzuchi System object
my $Cmd = undef();		# Kanadzuchi::UI::CLI object
my $Rdb = undef();		# Kanadzuchi::RDB object
my $Fmt = undef();		# Format

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'dump'		=> ( 1 << 2 ),
	'usedb'		=> ( 1 << 3 ),
	'count'		=> ( 1 << 4 ),
	'comment'	=> ( 1 << 5 ),
};

# WhereCond strings for --select option
my $WhereCondition = {
	'addresser' => q(), 'recipient' => q(), 'senderdomain' => q(),
	'destination' => q(), 'reason' => q(), 'hostgroup' => q(),
	'token' => q(), 'bounced' => 0,
};

# ORDER BY
my $OrderBy = { 'column' => q(id), 'descend' => 0, };

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
	#  _   _ ____  _____   ____  ____    ______  _   _ __  __ ____  
	# | | | / ___|| ____| |  _ \| __ )  / /  _ \| | | |  \/  |  _ \ 
	# | | | \___ \|  _|   | | | |  _ \ / /| | | | | | | |\/| | |_) |
	# | |_| |___) | |___  | |_| | |_) / / | |_| | |_| | |  | |  __/ 
	#  \___/|____/|_____| |____/|____/_/  |____/ \___/|_|  |_|_|    
	#                                                               
	# Use Database
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
		$Cmd->d(2,"Connecting to the database\n") if(defined($Rdb->handle()));

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


	# Check given string as an argument of query
	require Kanadzuchi::Log;
	require Kanadzuchi::Time;
	require Kanadzuchi::RFC2822;
	require Kanadzuchi::Mail::Stored::RDB;
	require Kanadzuchi::RDB::Schema::BounceLogs;

	# Arguments of searchandnew() method
	my $whereconds = {};		# Where conditions
	my $pageconfig = {};		# Pager configuration
	my $dumpeddata = [];		# (Ref->Array) Dumped results
	my $objhlogger = undef();	# K::Log object
	my $reqsobject = 0;		# Requires object

	# Check parameters: recipient, senderdomain, destination, hostgroup, and reason
	foreach my $_key ( keys(%$WhereCondition) )
	{
		$whereconds->{$_key} = q();	# Initialize the value

		next() unless( length($WhereCondition->{$_key}) );
		$whereconds->{$_key} =  lc($WhereCondition->{$_key});
		$whereconds->{$_key} =~ y{[;=&`'"%*()[]|~$]}{}d;
		$whereconds->{$_key} =~ s{\A.+[@]}{}g if( $_key eq 'senderdomain' || $_key eq 'destination' );
		$whereconds->{$_key} =  Kanadzuchi::RFC2822->cleanup($whereconds->{$_key})
						if( $_key eq 'recipient' || $_key eq 'addresser' );

		if( $_key eq 'bounced' )
		{
			my $__tbounced = Kanadzuchi::Time->to_second($whereconds->{'bounced'});

			if( $__tbounced <= 0 || $__tbounced >= time() )
			{
				$whereconds->{'bounced'} = 0;
			}
			else
			{
				$whereconds->{'bounced'} = int( time() - $__tbounced );
			}
		}

		$Cmd->d( 1, sprintf( "WHERE->%s = '%s'\n", $_key, $whereconds->{$_key} ) );
	}

	# Check the host group and the reason
	try{
		my $_cid = Kanadzuchi::Mail->gname2id($whereconds->{'hostgroup'});
		my $_rid = Kanadzuchi::Mail->rname2id($whereconds->{'reason'});

		if( $whereconds->{'hostgroup'} ne q() && ! $_cid )
		{
			# Invalid host group 
			Kanadzuchi::Exception::Command->throw( 
				'-text' => q{Unknown host group: }.qq|$whereconds->{'hostgroup'}| );
		}

		if( $whereconds->{'reason'} ne q() && ! $_rid )
		{
			# Invalid reason
			Kanadzuchi::Exception::Command->throw( 
				'-text' => q{Unknown reason: }.qq|$whereconds->{'reason'}| );
		}
	}
	catch Kanadzuchi::Exception::Command with {
		$Cmd->exception(shift());
		$Cmd->abort();
	};

	# Check column name
	$OrderBy->{'column'} = q(ID) unless(Kanadzuchi::RDB::Schema::BounceLogs->is_validcolumn($OrderBy->{'column'}) );
	$Cmd->d(1, sprintf( "ORDER BY '%s' %s\n", $OrderBy->{'column'}, $OrderBy->{'descend'} ? q{DESCENDING} : q{} ) );

	# Receive 1 result for counting
	$pageconfig->{'currentpagenum'} = 1;
	$pageconfig->{'resultsperpage'} = 1;
	$pageconfig->{'colnameorderby'} = q{id};
	Kanadzuchi::Mail::Stored::RDB->searchandnew( $Rdb, $whereconds, \$pageconfig, $reqsobject );

	if( $Cmd->operation & $Cmd->option->{'count'} )
	{
		#   ____ ___  _   _ _   _ _____ 
		#  / ___/ _ \| | | | \ | |_   _|
		# | |  | | | | | | |  \| | | |  
		# | |__| |_| | |_| | |\  | | |  
		#  \____\___/ \___/|_| \_| |_|  
		#                               
		printf( STDOUT "%d\n", $pageconfig->{'totalentries'} );
	}
	else
	{
		#  ____  _   _ __  __ ____  
		# |  _ \| | | |  \/  |  _ \ 
		# | | | | | | | |\/| | |_) |
		# | |_| | |_| | |  | |  __/ 
		# |____/ \___/|_|  |_|_|    
		#                           
		$reqsobject = 1;
		$pageconfig->{'resultsperpage'} = int($pageconfig->{'totalentries'}/10) || 100;
		$pageconfig->{'resultsperpage'} = 100 if( $pageconfig->{'totalentries'} < 100 );
		$pageconfig->{'colnameorderby'} = lc( $OrderBy->{'column'} ) || q(id);
		$pageconfig->{'descendorderby'} = $OrderBy->{'descend'} || 0;

		# Search and Print
		while(1)
		{
			last() unless( $pageconfig->{'totalentries'} );	# reocrd == 0, exit

			# Receive results in a array reference
			$dumpeddata = Kanadzuchi::Mail::Stored::RDB->searchandnew( 
						$Rdb, $whereconds, \$pageconfig, $reqsobject );

			# Create H::Log object for using ->dumper() method
			$objhlogger = new Kanadzuchi::Log( 
						'count'	=> scalar(@{$dumpeddata}),
						'entities' => $dumpeddata,
						'device' => q{STDOUT},
						'format' => $Fmt, );

			if( $pageconfig->{'currentpagenum'} == 1 )
			{
				$Cmd->d( 1, sprintf("Total entries = %d\n", $pageconfig->{'totalentries'} ));

				# Print comment block
				if( $Cmd->operation & $Cmd->option->{'comment'} && $pageconfig->{'totalentries'} > 0 )
				{
					$objhlogger->header(1);
					$objhlogger->comment( sprintf( qq{Dumped by %s/%s %s},
							$Zci->myname(), $Cmd->calledfrom(), $Zci->version() ));
				}
				$objhlogger->dumper();
				$objhlogger->header(0);
				$objhlogger->comment(q{});
			}
			else
			{
				$objhlogger->dumper();
			}

			last() if( $pageconfig->{'currentpagenum'} >= $pageconfig->{'lastpagenumber'} );
			$pageconfig->{'currentpagenum'}++;
		} # End of the loop/while(1)
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
		$_opt_host,
		$_opt_port,
		$_opt_type,
		$_opt_count,
		$_opt_format,
		$_opt_addresser,
		$_opt_recipient,
		$_opt_senderdomain,
		$_opt_destination,
		$_opt_reason,
		$_opt_provider,
		$_opt_hostgroup,
		$_opt_token,
		$_opt_howrecent,
		$_opt_orderby,
		$_opt_orderbydesc,
		$_opt_comment,
		$_opt_alldata,
		$_opt_test,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'F=s'		=> \$_opt_format,
			'format=s'	=> \$_opt_format,
			'test'		=> \$_opt_test,
			'T'		=> \$_opt_test,
			'help'		=> sub { help(); exit(0); },
			'verbose'	=> \$_opt_verbose,
			'v+'		=> \$_opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Database options
			'host=s'	=> \$_opt_host,
			'port=i'	=> \$_opt_port,
			'type=s'	=> \$_opt_type,

			# Where condition options, require --select option
			'a=s'		=> \$_opt_addresser,
			'addresser=s'	=> \$_opt_addresser,
			'r=s'		=> \$_opt_recipient,
			'recipient=s'	=> \$_opt_recipient,
			's=s'		=> \$_opt_senderdomain,
			'senderdomain=s' => \$_opt_senderdomain,
			'd=s'		=> \$_opt_destination,
			'destination=s'	=> \$_opt_destination,
			'w=s'		=> \$_opt_reason,
			'reason=s'	=> \$_opt_reason,
			'g=s'		=> \$_opt_hostgroup,
			'hostgroup=s'	=> \$_opt_hostgroup,
			'p=s'		=> \$_opt_provider,
			'provider=s'	=> \$_opt_provider,
			't=s'		=> \$_opt_token,
			'token=s'	=> \$_opt_token,
			'h=s'		=> \$_opt_howrecent,
			'howrecent=s'	=> \$_opt_howrecent,
			'o=s'		=> \$_opt_orderby,
			'orderby=s'	=> \$_opt_orderby,
			'O=s'		=> \$_opt_orderbydesc,
			'orderbydesc=s'	=> \$_opt_orderbydesc,
			'count'		=> \$_opt_count,
			'comment'	=> \$_opt_comment,
			'alldata'	=> \$_opt_alldata,
			'A'		=> \$_opt_alldata,
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
	}

	# Database Statement
	$_operation |= $Cmd->option->{'usedb'}; 

	$WhereCondition->{'token'} = $_opt_token || q();
	$WhereCondition->{'reason'} = $_opt_reason || q();
	$WhereCondition->{'bounced'} = $_opt_howrecent || q();
	$WhereCondition->{'provider'} = $_opt_provider || q();
	$WhereCondition->{'hostgroup'} = $_opt_hostgroup || q();
	$WhereCondition->{'addresser'} = $_opt_addresser || q();
	$WhereCondition->{'recipient'} = $_opt_recipient || q();
	$WhereCondition->{'destination'} = $_opt_destination || q();
	$WhereCondition->{'senderdomain'} = $_opt_senderdomain || q();
	$WhereCondition->{'disable'} = 0 unless( $_opt_alldata );

	# Order by (desc)
	if( $_opt_orderby || $_opt_orderbydesc )
	{
		$OrderBy->{'column'} = $_opt_orderby || $_opt_orderbydesc;
		$OrderBy->{'descend'} = 1 if( $_opt_orderbydesc );
	}

	# Database spec option, Override values in the config file
	if( $_opt_host ){ $Rdb->hostname($_opt_host); }
	if( $_opt_type ){ $Rdb->dbtype($_opt_type); }
	if( $_opt_port ){ $Rdb->port($_opt_port); }

	if( $_opt_count ){ $_operation |= $Cmd->option->{'count'}; }
	if( $_opt_comment ){ $_operation |= $Cmd->option->{'comment'}; }

	# Output format options
	if( $_opt_format )
	{
		my $_1stcharacter = substr( $_opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq q(y) ? q(yaml) :
			$_1stcharacter eq q(c) ? q(csv) :
			$_1stcharacter eq q(s) ? q(sendmail) :
			$_1stcharacter eq q(p) ? q(postfix) : q(yaml);
	}
	else
	{
		# Default Log format is 'YAML' -Fy
		$Fmt = q(yaml);
	}

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
	printf( STDERR " * QUERY OPTIONS(Require --select option)\n" );
	printf( STDERR "    -A, --alldata              : Show all data: include a record that is disabled(=1)\n");
	printf( STDERR "    -a, --addresser <str>      : Sender address(Addresser).\n");
	printf( STDERR "    -r, --recipient <str>      : Recipient address.\n");
	printf( STDERR "    -s, --senderdomain <str>   : Sender domain name.\n");
	printf( STDERR "    -d, --destination <str>    : Destination domain name.\n");
	printf( STDERR "    -w, --reason <str>         : Reason, see tablectl -Tw --list\n");
	printf( STDERR "    -g, --hostgroup <str>      : Host group, see tablectl -Tc --list\n");
	printf( STDERR "    -p, --provider <str>       : Provider name, see tablectl -Tc --list\n");
	printf( STDERR "    -t, --token <str>          : Message token(MD5 hash value)\n");
	printf( STDERR "    -h, --howrecent <str>      : How recent the mail is past <day> days, e.g.)\n");
	printf( STDERR "                                 1w = 1 weeks, 2d = 2 days(default), 3h = 3 hours,\n");
	printf( STDERR "                                 4m = 4 minutes, 5s = 5 seconds, 6y = 6 years.\n");
	printf( STDERR "    -o, --orderby <column>     : ORDER BY column name \n");
	printf( STDERR "    -O, --orderbydesc <column> : ORDER BY column name DESCENDING\n");
	printf( STDERR "    --count                    : Count only, print total entries and exit.\n");
	printf( STDERR "    --comment                  : Add comment in the head of the results.\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>    : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf\n");
	printf( STDERR "    -F, --format <char> : Output format, the following are available.\n");
	printf( STDERR "                          [y]aml, [c]sv, [s]endmail, [p]ostfix\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s --alldata --count\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -c cellphone -w filtered -h 1y\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}


__END__
