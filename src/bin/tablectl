#__PERLEXECUTABLE__
# $Id: tablectl,v 1.12 2010/02/21 20:09:01 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Command::
                                                    
   ##         ##    ###                 ##   ###    
 ###### ####  ##     ##   ####   #### ######  ##    
   ##      ## #####  ##  ##  ## ##      ##    ##    
   ##   ##### ##  ## ##  ###### ##      ##    ##    
   ##  ##  ## ##  ## ##  ##     ##      ##    ##    
    ### ##### ##### ####  ####   ####    ### ####   
                                                    
package Kanadzuchi::Command::Tablectl;

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
use Kanadzuchi::RDB::MasterTable;
use Error ':try';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci = undef();		# Kanadzuchi System object
my $Cmd = undef();		# Kanadzuchi::UI::CLI object
my $Rdb = undef();		# Kanadzuchi::RDB object
my $Tab = undef();		# Master table, Kanadzuchi::RDB::Table::* object
my $Fmt = undef();		# Fotmat
my $Given = {};			# Hash reference for $Tab

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'usedb'		=> ( 1 << 2 ),
	'list'		=> ( 1 << 3 ),
	'insert'	=> ( 1 << 4 ),
	'remove'	=> ( 1 << 5 ),
	'update'	=> ( 1 << 6 ),
	'modify'	=> ( 1 << 7 ),
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

	try {
		if( defined($Rdb->table()) )
		{
			# Create master table object(Tab)
			$Tab = Kanadzuchi::RDB::MasterTable->newtable( $Rdb->table() );
		}
		else
		{
			Kanadzuchi::Exception::Command->throw( '-text' => q{No table name} );
		}

		# Set values to Kanadzuchi::Database object, Create data source name
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

		# Set values($Given) to object($Tab)
		$Tab->id($Given->{'id'});
		$Tab->name($Given->{'name'});
		$Tab->description($Given->{'description'});
		$Tab->disable($Given->{'disable'} || 0);

		undef($Given);

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
		$Cmd->d(2,sprintf("Using table = %s\n", $Tab->table()));
	}
	otherwise {
		$Cmd->exception(shift());
		$Cmd->abort();
	};


	if( $Cmd->operation & $Cmd->option->{'list'} )
	{
		#  ____  _____ _     _____ ____ _____   _     ___ ____ _____ 
		# / ___|| ____| |   | ____/ ___|_   _| | |   |_ _/ ___|_   _|
		# \___ \|  _| | |   |  _|| |     | |   | |    | |\___ \ | |  
		#  ___) | |___| |___| |__| |___  | |_  | |___ | | ___) || |  
		# |____/|_____|_____|_____\____| |_( ) |_____|___|____/ |_|  
		#                                  |/
		my $_resultset = undef();		# DBIx::Class::ResultSet object
		my $_objasctab = undef();		# Text::ASCIITable object
		my $_fieldname = \$Tab->field();	# Fieldname in the table

		$Cmd->d(2,sprintf("Execute 'SELECT', Print the list\n"));

		# Check output format
		if( $Fmt eq 'asciitable' )
		{
			# Human readable ASCII table
			require Text::ASCIITable;
			$_objasctab = new Text::ASCIITable( { 'headingText' => $Tab->table() } );
			$_objasctab->setOptions( 'outputWidth', 80 );
			$_objasctab->setCols( '#ID', $$_fieldname, 'description', 'disable' );
		}

		# Make 'ResultSet' object of the table
		if( defined($Tab->id()) && $Tab->id > 0 )
		{
			$Cmd->d(2,sprintf("Find by ID = %d\n", $Tab->id()));
			$_resultset = $Rdb->handle->resultset($Tab->table())->search({ id => $Tab->id() });
		}
		elsif( defined($Tab->name()) && length($Tab->name()) > 0 )
		{
			$Cmd->d(2,sprintf("Find by name = %s\n", $Tab->name()));
			$_resultset = $Rdb->handle->resultset($Tab->table())->search(
						{ $$_fieldname => $Tab->name() },
						{ 'order_by' => 'id' } );
		}
		else
		{
			$Cmd->d(3,sprintf("SELECT * FROM %s;\n", $Tab->table()));
			$_resultset = $Rdb->handle->resultset($Tab->table())->search({},{ 'order_by' => 'id' });
		}

		PRINT_THE_LIST: while( my $__rr = $_resultset->next() )
		{
			if( defined($_objasctab) )
			{
				$_objasctab->addRow( $__rr->id, $__rr->$$_fieldname, $__rr->description, $__rr->disable );
			}
			else
			{
				if( $Fmt eq 'yaml' )
				{
					printf( STDOUT qq|- { "id": %d, "%s": "%s", "description": "%s", "disable": %d }\n|,
						$__rr->id, $$_fieldname, $__rr->$$_fieldname, 
						( $__rr->description || q() ), $__rr->disable );
				}
				elsif( $Fmt eq 'csv' )
				{
					printf( STDOUT qq|%d,%s,"%s",%d\n|,
						$__rr->id, $__rr->$$_fieldname, ( $__rr->description || q() ), $__rr->disable );
				}
				else
				{
					printf( STDOUT "ID = %d, Value = %s, Description = %s, Disable = %d\n",
						$__rr->id, $__rr->$$_fieldname, ( $__rr->description || q() ), $__rr->disable );
				}
			}
		}

		if( defined($_objasctab) && scalar(@{$_objasctab->{'tbl_rows'}}) )
		{
			$_objasctab->addRowLine();
			printf( STDOUT "%s", $_objasctab->draw() );
		}

	}
	elsif( $Cmd->operation & $Cmd->option->{'modify'} )
	{
		#  __  __  ___  ____ ___ _______   __
		# |  \/  |/ _ \|  _ \_ _|  ___\ \ / /
		# | |\/| | | | | | | | || |_   \ V / 
		# | |  | | |_| | |_| | ||  _|   | |  
		# |_|  |_|\___/|____/___|_|     |_|  
		#
		my $_ismodified = 0;	# Flag, 1 = modified, 0 = failed
		my $_tableentry = {};	# Hash reference of the entry

		if( $Cmd->operation & $Cmd->option->{'update'} )
		{
			#  _   _ ____  ____    _  _____ _____ 
			# | | | |  _ \|  _ \  / \|_   _| ____|
			# | | | | |_) | | | |/ _ \ | | |  _|  
			# | |_| |  __/| |_| / ___ \| | | |___ 
			#  \___/|_|   |____/_/   \_\_| |_____|
			# 
			$Cmd->d(2,sprintf("Execute 'UPDATE'\n"));
			try {
				# ID is not given , ID:0 is not valid
				Kanadzuchi::Exception::Command->throw( 
					'-text' => q{No or invalid ID} ) unless($Tab->id());

				if( ! defined($Tab->name) && ! defined($Tab->description) && ! defined($Tab->disable) )
				{
					Kanadzuchi::Exception::Command->throw( '-text' =>
						q{There are neither --name, --discription nor --disable} );
				}
				elsif( defined($Tab->name) && length($Tab->name) == 0 )
				{
					Kanadzuchi::Exception::Command->throw( '-text' =>
						q{The argument of --name is empty!} );
				}

				if( ! defined($Tab->name) && ! defined($Tab->validation) )
				{
					Kanadzuchi::Exception::Database->throw(
						'-text' => q{Invalid argument of --name} );
				}
			}
			catch Kanadzuchi::Exception::Command with {
				$Cmd->exception(shift());
				$Cmd->abort();
			};
			
			# Get and check the current record
			$_tableentry = $Tab->getentbyid($Rdb);

			if( defined($_tableentry->{'id'}) && defined($_tableentry->{'name'}) )
			{
				# Set current value to the object
				if( ! defined($Tab->name) || $Tab->name eq q() )
				{
					$Tab->name($_tableentry->{'name'});
				}

				if( ! defined($Tab->description) || $Tab->description eq q() )
				{
					$Tab->description($_tableentry->{'description'});
				}

				if( ! defined($Tab->disable) || $Tab->disable eq q() )
				{
					$Tab->disable($_tableentry->{'disable'});
				}

				$_ismodified = $Tab->update($Rdb);
			}

			if( $_ismodified )
			{
				$Cmd->d(2,"Successfully updated(ID=".$Tab->id().")\n");
			}
			else
			{
				$Cmd->d(2,"Failed to UPDATE\n");
			}

		}
		elsif( $Cmd->operation & $Cmd->option->{'remove'} )
		{
			#  ____  _____ _     _____ _____ _____ 
			# |  _ \| ____| |   | ____|_   _| ____|
			# | | | |  _| | |   |  _|   | | |  _|  
			# | |_| | |___| |___| |___  | | | |___ 
			# |____/|_____|_____|_____| |_| |_____|
			#
			$Cmd->d(2,sprintf("Execute 'DELETE'\n"));
			try {
				# ID is not given , ID:0 is not valid
				Kanadzuchi::Exception::Command->throw( 
					'-text' => q{No or invalid ID} ) unless($Tab->id());
			}
			catch Kanadzuchi::Exception::Command with {
				$Cmd->exception(shift());
				$Cmd->abort();
			};

			$_ismodified = $Tab->remove($Rdb);
			if( $_ismodified )
			{
				$Cmd->d(2,"Successfully removed(ID=".$Tab->id().")\n");
			}
			else
			{
				$Cmd->d(2,"Failed to DELETE\n");
			}

		}
		elsif( $Cmd->operation & $Cmd->option->{'insert'} )
		{
			#  ___ _   _ ____  _____ ____ _____ 
			# |_ _| \ | / ___|| ____|  _ \_   _|
			#  | ||  \| \___ \|  _| | |_) || |  
			#  | || |\  |___) | |___|  _ < | |  
			# |___|_| \_|____/|_____|_| \_\|_|  
			#
			$Cmd->d(2,sprintf("Execute 'INSERT'\n"));
			try {
				if( ! defined($Tab->name) && ! defined($Tab->description) && ! defined($Tab->disable) )
				{
					Kanadzuchi::Exception::Command->throw( '-text' =>
						q{There are neither --name, --discription nor --disable} );
				}

				Kanadzuchi::Exception::Database->throw(
					'-text' => q{Invalid argument of --name} ) unless($Tab->validation());
			}
			catch Kanadzuchi::Exception::Command with {
				$Cmd->exception(shift());
				$Cmd->abort();
			};

			$_ismodified = $Tab->insert($Rdb);
			if( $_ismodified )
			{
				$Cmd->d(2,"Successfully inserted(ID=$_ismodified)\n");
			}
			else
			{
				$Cmd->d(2,"Failed to INSERT\n");
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
	my $_operation = 0;

	# Variables for decide operation
	my (
		$_opt_conf,
		$_opt_format,
		$_opt_database,
		$_opt_description,
		$_opt_disable,
		$_opt_host,
		$_opt_insert,
		$_opt_id,
		$_opt_list,
		$_opt_name,
		$_opt_port,
		$_opt_remove,
		$_opt_table,
		$_opt_type,
		$_opt_update,
		$_opt_usedb,
		$_opt_test,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'insert'	=> \$_opt_insert,
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'database=s'	=> \$_opt_database,
			'format=s'	=> \$_opt_format,
			'F=s'		=> \$_opt_format,
			'host=s'	=> \$_opt_host,
			'port=i'	=> \$_opt_port,
			'type=s'	=> \$_opt_type,
			'list'		=> \$_opt_list,
			'remove'	=> \$_opt_remove,
			'update'	=> \$_opt_update,
			't=s'		=> \$_opt_table,
			'table=s'	=> \$_opt_table,
			'id=i'		=> \$_opt_id,
			'name=s'	=> \$_opt_name,
			'description=s'	=> \$_opt_description,
			'disable=i'	=> \$_opt_disable,
			'test'		=> \$_opt_test,
			'T'		=> \$_opt_test,
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

	# Table control
	if( $_opt_list )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'list'};
	}
	elsif( $_opt_update )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'modify'}; 
		$_operation |= $Cmd->option->{'update'};
	}
	elsif( $_opt_insert )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'modify'}; 
		$_operation |= $Cmd->option->{'insert'};
	}
	elsif( $_opt_remove )
	{
		$_operation |= $Cmd->option->{'usedb'}; 
		$_operation |= $Cmd->option->{'modify'}; 
		$_operation |= $Cmd->option->{'remove'};
	}

	# Select a table
	$Rdb->table(lc(substr($_opt_table,0,1))) if( $_opt_table );

	# Field, Column options
	if( $_opt_id ){ $Given->{'id'} = int($_opt_id); }
	if( $_opt_name ){ $Given->{'name'} = $_opt_name; }
	if( $_opt_description ){ $Given->{'description'} = $_opt_description; }
	if( defined($_opt_disable) ){ $Given->{'disable'} = $_opt_disable ; }

	# Database spec option, Override values in the config file
	if( $_opt_host ){ $Rdb->hostname($_opt_host); }
	if( $_opt_type ){ $Rdb->dbtype($_opt_type); }
	if( $_opt_port ){ $Rdb->port($_opt_port); }

	if( $_opt_format )
	{
		if(    substr($_opt_format,0,1) eq 'y' ){ $Fmt = q(yaml); }
		elsif( substr($_opt_format,0,1) eq 'c' ){ $Fmt = q(csv); }
		elsif( substr($_opt_format,0,1) eq 'a' ){ $Fmt = q(asciitable); }
		else{ $Fmt = q(yaml); }
	}
	else
	{
		# Default Log format is 'YAML' -Fy
		$Fmt = q(yaml);
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
	printf( STDERR "Usage: %s [OPTIONS] -T<x>\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE CONTROL OPTIONS\n" );
	printf( STDERR "    -t, --table <t> : Table name, ALWAYS REQUIRED.\n");
	printf( STDERR "                      a = [A]ddressers, s = [S]enderDomains, d = [D]estinations\n");
	printf( STDERR "                      c = [H]ostgroups, p = [P]roviders, w = Reasons([w]hy)\n");
	printf( STDERR "                      *WARNING* -Tr(--table r) uses more memory!\n");
	printf( STDERR "    --list          : Print the table contents as a list.\n");
	printf( STDERR "    --update        : UPDATE specified records\n");
	printf( STDERR "    --insert        : INSERT a new record\n");
	printf( STDERR "    --remove        : DELETE a specified record\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in the config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address\n");
	printf( STDERR "    --port <portnum>    : DB Host port number\n");
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE COLUMN OPTIONS\n" );
	printf( STDERR "    --id <n>              : ID(>0), this option is required by --update, --remove option.\n");
	printf( STDERR "    --name <str>          : Name, this option is required by --insert option.\n");
	printf( STDERR "    --description <descr> : A value of description field of the record to UPDATE or INSERT.\n");
	printf( STDERR "    --disable <0|1>       : A value of disable field, 0 = Turn on, 1 = Turn off\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf\n");
	printf( STDERR "    -F, --format <f>    : Format of the results of --list option,\n");
	printf( STDERR "                          y = YAML, c = CSV a = ASCII Table.\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s -C./test-run.cf -Tw --list -Fa\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -Ts --insert --name 'example.jp' --discription 'Ex' -v\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -Ts --update --id 2 --discription 'My Domain'\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}


__END__
