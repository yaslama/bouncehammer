#__PERLEXECUTABLE__
# $Id: datadumper.PL,v 1.20.2.3 2011/05/13 06:29:07 ak Exp $
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
use lib '__PERLEXTERNALLIB__';
use strict;
use warnings;
use Kanadzuchi;
use Kanadzuchi::UI::CLI;
use Kanadzuchi::BdDR;
use Error ':try';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Commandline object
my $Rdb;		# (Kanadzuchi::BdDR) Database object
my $Fmt;		# (String) Output format

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'dump'		=> ( 1 << 2 ),
	'database'	=> ( 1 << 3 ),
	'count'		=> ( 1 << 4 ),
	'comment'	=> ( 1 << 5 ),
};

# WhereCond strings
my $WhereCondition = {
	'addresser' => q(),	# From:
	'recipient' => q(),	# To:
	'senderdomain' => q(),	# Sender's domain name
	'destination' => q(),	# Recipient's domain name
	'reason' => q(),	# Reason name
	'hostgroup' => q(),	# Host Group name
	'provider' => q(),	# Provider name
	'token' => q(),		# Message token
	'bounced' => 0,		# Bounced date
	'frequency' => 0,	# Frequency
};

# ORDER BY
my $OrderBy = { 'column' => 'id', 'descend' => 0, };

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
	#  _   _ ____  _____   ____  ____    ______  _   _ __  __ ____  
	# | | | / ___|| ____| |  _ \| __ )  / /  _ \| | | |  \/  |  _ \ 
	# | | | \___ \|  _|   | | | |  _ \ / /| | | | | | | |\/| | |_) |
	# | |_| |___) | |___  | |_| | |_) / / | |_| | |_| | |  | |  __/ 
	#  \___/|____/|_____| |____/|____/_/  |____/ \___/|_|  |_|_|    
	#                                                               
	# Use Database
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::Page;
	require Kanadzuchi::Mail::Stored::BdDR;
	require Kanadzuchi::Log;
	require Kanadzuchi::Time;
	require Kanadzuchi::Address;

	my $xntableobj = undef();	# (Kanadzuchi::BdDR::BounceLogs::Table) Txn table object
	my $pagination = undef();	# (Kanadzuchi::BdDR::Page) Pagination object
	my $whereconds = {};		# (Ref->Hash) Where conditions
	my $nrecordsin = 0;		# (Integer) The number of records in the database
	my $linesapage = 500;		# (Integer) How many lines a page


	# Set values to Kanadzuchi::BdDR object, Create data source name
	try {
		$Rdb->setup( $Zci->config->{'database'} );
		Kanadzuchi::Exception::Database->throw( 
			'-text' => 'Failed to connect DB' ) unless( $Rdb->connect() );
		$Cmd->d(2,"Connecting to the database\n") if( defined $Rdb->handle() );

		# Create master table objects
		$xntableobj = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $Rdb->handle() );
		Kanadzuchi::Exception::Database->throw( 
			'-text' => 'Failed to create table objects' ) unless $xntableobj;

		( $Rdb->hostname() ne 'localhost' && $Rdb->port() ne q() )
			? $Cmd->d(2,sprintf("Database host = %s:%s\n", $Rdb->hostname(), $Rdb->port()))
			: $Rdb->hostname() eq 'localhost' ? $Cmd->d(2,'Database host = Socket'.qq{\n}) : 1;

		$Cmd->d(2,sprintf("Database name = %s(%s)\n", $Rdb->dbname(), $Rdb->dbtype()));
		$Cmd->d(2,sprintf("Database user = %s\n", $Rdb->username()));
		$Cmd->d(2,sprintf("Using table = %s\n", $xntableobj->alias()));

	}
	catch Kanadzuchi::Exception::Database with {
		my $e = shift();
		my $b = '-' x 64;
		my $m = $e;

		if( length $Rdb->error->{'string'} )
		{
			$m .= "\n".$b;
			$m .= "\n ".$Rdb->error->{'string'};
			$m .= $b;
			$m .= "\n";
			$e .= ': '.$Rdb->error->{'string'};
		}
		$Cmd->exception($m);
		$Cmd->abort();
	};

	# Check parameters: recipient, senderdomain, destination, hostgroup, and reason
	foreach my $_key ( keys(%$WhereCondition) )
	{
		next() unless( length($WhereCondition->{$_key}) );
		$whereconds->{$_key} =  lc($WhereCondition->{$_key});
		$whereconds->{$_key} =~ y{[;=&`'"%*()[]|~$]}{}d;
		$whereconds->{$_key} =~ s{\A.+[@]}{}g if( $_key eq 'senderdomain' || $_key eq 'destination' );
		$whereconds->{$_key} =  Kanadzuchi::Address->canonify($whereconds->{$_key})
						if( $_key eq 'recipient' || $_key eq 'addresser' );

		if( $_key eq 'bounced' )
		{
			my $__tbounced = Kanadzuchi::Time->to_second($whereconds->{'bounced'});
			my $__timepobj = 0;

			if( $__tbounced <= 0 || $__tbounced >= time() )
			{
				$whereconds->{'bounced'} = { '>=' => 0 };
			}
			else
			{
				$__timepobj = Time::Piece->new(int( time() - $__tbounced ));
				$whereconds->{'bounced'} = { '>=' => $__timepobj->epoch() };
			}
			$Cmd->d( 1, sprintf( "WHERE->%s >= '%s'\n", $_key, $__timepobj->cdate() ) );
		}
		elsif( $_key eq 'frequency' )
		{
			my $__freq = abs( $whereconds->{'frequency'} );
			if( $__freq > 1 )
			{
				$whereconds->{'frequency'} = { '>=' => $__freq };
				$Cmd->d( 1, sprintf( "WHERE->%s >= %d\n", $_key, $__freq ) );
			}
		}
		else
		{
			$Cmd->d( 1, sprintf( "WHERE->%s = '%s'\n", $_key, $whereconds->{$_key} ) );
		}
	}

	# Check the host group and the reason
	try{
		my( $_str, $_xid, $_err );
		if( exists($whereconds->{'hostgroup'}) && length($whereconds->{'hostgroup'}) )
		{
			# Invalid host group 
			$_str = $whereconds->{'hostgroup'};
			$_xid = Kanadzuchi::Mail->gname2id($_str);
			$_err = 'Unknown host group: '.$whereconds->{'hostgroup'}.'; try tablectl --list -tg';
			Kanadzuchi::Exception::Command->throw( '-text' => $_err ) unless $_xid;
		}

		if( exists($whereconds->{'reason'}) && length($whereconds->{'reason'}) )
		{
			# Invalid reason
			$_str = $whereconds->{'reason'};
			$_xid = Kanadzuchi::Mail->rname2id($_str);
			$_err = 'Unknown reason: '.$whereconds->{'reason'}.'; try tablectl --list -tw';
			Kanadzuchi::Exception::Command->throw( '-text' => $_err ) unless $_xid;
		}
	}
	catch Kanadzuchi::Exception::Command with {
		$Cmd->exception(shift());
		$Cmd->abort();
	};

	# ORDER BY
	$OrderBy->{'column'} = q(id) unless( $xntableobj->is_validcolumn($OrderBy->{'column'}) );
	$Cmd->d(1, sprintf( "ORDER BY '%s' %s\n", $OrderBy->{'column'}, $OrderBy->{'descend'} ? q{DESCENDING} : q{} ) );

	# Pagination
	$pagination = new Kanadzuchi::BdDR::Page();
	$nrecordsin = $xntableobj->count( $whereconds, $pagination );

	if( $Cmd->operation & $Cmd->option->{'count'} )
	{
		#   ____ ___  _   _ _   _ _____ 
		#  / ___/ _ \| | | | \ | |_   _|
		# | |  | | | | | | |  \| | | |  
		# | |__| |_| | |_| | |\  | | |  
		#  \____\___/ \___/|_| \_| |_|  
		#                               
		# Receive 1 result for counting
		print( STDOUT $nrecordsin.qq{\n} );
	}
	else
	{
		#  ____  _   _ __  __ ____  
		# |  _ \| | | |  \/  |  _ \ 
		# | | | | | | | |\/| | |_) |
		# | |_| | |_| | |  | |  __/ 
		# |____/ \___/|_|  |_|_|    
		#                           
		# 0 records in the database
		$Cmd->finish() unless( $nrecordsin );

		$linesapage = 5000 if( $nrecordsin > $linesapage );
		$pagination->resultsperpage( $linesapage );
		$pagination->set($nrecordsin);
		$pagination->colnameorderby( $OrderBy->{'column'} );
		$pagination->descendorderby( $OrderBy->{'descend'} ? 1 : 0 );

		$Cmd->d( 1, sprintf("Total entries = %d\n", $pagination->count() ));

		# Search and Print
		SEARCH_AND_NEW: while(1)
		{
			my $dumpeddata = [];		# (Ref->Array) Dumped results
			my $xniterator = Kanadzuchi::Mail::Stored::BdDR->searchandnew( 
						$Rdb->handle(), $whereconds, $pagination );

			DUMP_EACH_OBJECT: while( my $obj = $xniterator->next() )
			{
				push( @$dumpeddata, $obj );
			}

			# Create K::Log object and dump
			my $kanazcilog = new Kanadzuchi::Log(
						'count' => scalar @$dumpeddata,
						'entities' => $dumpeddata,
						'device' => q|STDOUT|,
						'format' => $Fmt );

			if( $pagination->currentpagenum == 1 )
			{
				# Print comment block
				if( $Cmd->operation & $Cmd->option->{'comment'} )
				{
					$kanazcilog->header(1);
					$kanazcilog->comment( sprintf( qq{Dumped by %s/%s %s},
							$Zci->myname(), $Cmd->calledfrom(), $Zci->version() ));
				}
				$kanazcilog->dumper();
				$kanazcilog->header(0);
				$kanazcilog->comment(q{});
			}
			else
			{
				$kanazcilog->dumper();
			}

			last() unless $pagination->hasnext();
			$pagination->next();

		} # End of while(SEACH_AND_NEW)

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
		$opt_addresser,
		$opt_alldata,
		$opt_comment,
		$opt_conf,
		$opt_count,
		$opt_destination,
		$opt_format,
		$opt_frequency,
		$opt_host,
		$opt_hostgroup,
		$opt_howrecent,
		$opt_orderby,
		$opt_orderbydesc,
		$opt_port,
		$opt_provider,
		$opt_reason,
		$opt_recipient,
		$opt_senderdomain,
		$opt_test,
		$opt_token,
		$opt_type,
		$opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'conf=s'	=> \$opt_conf,
			'C=s'		=> \$opt_conf,
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

			# Where condition options
			'a=s'		=> \$opt_addresser,
			'addresser=s'	=> \$opt_addresser,
			'r=s'		=> \$opt_recipient,
			'recipient=s'	=> \$opt_recipient,
			's=s'		=> \$opt_senderdomain,
			'senderdomain=s' => \$opt_senderdomain,
			'd=s'		=> \$opt_destination,
			'destination=s'	=> \$opt_destination,
			'w=s'		=> \$opt_reason,
			'reason=s'	=> \$opt_reason,
			'g=s'		=> \$opt_hostgroup,
			'hostgroup=s'	=> \$opt_hostgroup,
			'p=s'		=> \$opt_provider,
			'provider=s'	=> \$opt_provider,
			't=s'		=> \$opt_token,
			'token=s'	=> \$opt_token,
			'h=s'		=> \$opt_howrecent,
			'howrecent=s'	=> \$opt_howrecent,
			'f=i'		=> \$opt_frequency,
			'frequency=i'	=> \$opt_frequency,

			# Order
			'o=s'		=> \$opt_orderby,
			'orderby=s'	=> \$opt_orderby,
			'O=s'		=> \$opt_orderbydesc,
			'orderbydesc=s'	=> \$opt_orderbydesc,

			# Control and format options
			'F=s'		=> \$opt_format,
			'format=s'	=> \$opt_format,
			'count'		=> \$opt_count,
			'comment'	=> \$opt_comment,
			'alldata'	=> \$opt_alldata,
			'A'		=> \$opt_alldata,
		);


	# (verbose|debug) mode
	$Cmd->debuglevel( ( $opt_verbose ? $opt_verbose : 0 ) - 1 );

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
	$operation |= $Cmd->option->{'database'}; 

	$WhereCondition->{'token'} = $opt_token || q();
	$WhereCondition->{'reason'} = $opt_reason || q();
	$WhereCondition->{'bounced'} = $opt_howrecent || q();
	$WhereCondition->{'provider'} = $opt_provider || q();
	$WhereCondition->{'hostgroup'} = $opt_hostgroup || q();
	$WhereCondition->{'addresser'} = $opt_addresser || q();
	$WhereCondition->{'recipient'} = $opt_recipient || q();
	$WhereCondition->{'frequency'} = $opt_frequency || q();
	$WhereCondition->{'destination'} = $opt_destination || q();
	$WhereCondition->{'senderdomain'} = $opt_senderdomain || q();
	$WhereCondition->{'disabled'} = 0 unless( $opt_alldata );

	# Order by (desc)
	if( $opt_orderby || $opt_orderbydesc )
	{
		$OrderBy->{'column'} = $opt_orderby || $opt_orderbydesc;
		$OrderBy->{'descend'} = 1 if( $opt_orderbydesc );
	}

	# Database spec option, Override values in the config file
	if( $opt_host ){ $Rdb->hostname($opt_host); }
	if( $opt_type ){ $Rdb->dbtype($opt_type); }
	if( $opt_port ){ $Rdb->port($opt_port); }

	if( $opt_count ){ $operation |= $Cmd->option->{'count'}; }
	if( $opt_comment ){ $operation |= $Cmd->option->{'comment'}; }

	# Output format options
	if( $opt_format )
	{
		my $_1stcharacter = substr( $opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq 'y' ? 'yaml' :
			$_1stcharacter eq 'j' ? 'json' :
			$_1stcharacter eq 'c' ? q(csv) : 'yaml';
	}
	else
	{
		# Default Log format is 'YAML' -Fy
		$Fmt = 'yaml';
	}

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
	printf( STDERR "Usage: %s [OPTIONS] \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * QUERY OPTIONS\n" );
	printf( STDERR "    -A, --alldata              : Show all data: include the record that is disabled(=1)\n");
	printf( STDERR "    -a, --addresser <str>      : Sender address(Addresser), see tablectl -ta --list\n");
	printf( STDERR "    -r, --recipient <str>      : Recipient address\n");
	printf( STDERR "    -s, --senderdomain <str>   : Sender domain name, see tablectl -ts --list\n");
	printf( STDERR "    -d, --destination <str>    : Destination domain name, see tablectl -td --list\n");
	printf( STDERR "    -w, --reason <str>         : Reason, see tablectl -tw --list\n");
	printf( STDERR "    -g, --hostgroup <str>      : Host group, see tablectl -th --list\n");
	printf( STDERR "    -p, --provider <str>       : Provider name, see tablectl -tp --list\n");
	printf( STDERR "    -t, --token <str>          : Message token(MD5 hash value)\n");
	printf( STDERR "    -h, --howrecent <str>      : How recent the mail is past <day> days, e.g.)\n");
	printf( STDERR "                                 1w = 1 weeks, 2d = 2 days(default), 3h = 3 hours,\n");
	printf( STDERR "                                 4m = 4 minutes, 5s = 5 seconds, 6y = 6 years.\n");
	printf( STDERR "    -f, --frequency <n>        : Frequency, -f 3 is equal to '>= 3'\n");
	printf( STDERR "    -o, --orderby <column>     : ORDER BY column name \n");
	printf( STDERR "    -O, --orderbydesc <column> : ORDER BY column name DESCENDING\n");
	printf( STDERR "    --count                    : Count only, print total entries and exit.\n");
	printf( STDERR "    --comment                  : Add comment in the head of the results.\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>                 : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>          : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>           : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config>        : Location of the configuration file used instead of \n");
	printf( STDERR "                                 __KANADZUCHIETC__/bouncehammer.cf\n");
	printf( STDERR "    -T, --test                 : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -F, --format <char>        : Output format, the followings are available.\n");
	printf( STDERR "                                 [y]aml = Default, [j]son, [c]sv and [a]sciitable\n");
	printf( STDERR "    --silent                   : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose              : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help                     : Print help message(This screen)\n");
	printf( STDERR "    --version                  : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s --alldata --count\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -g cellphone -w filtered -h 1y\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}

__END__
