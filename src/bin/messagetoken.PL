#__PERLEXECUTABLE__
# $Id: messagetoken.PL,v 1.8.2.4 2011/10/07 06:22:03 ak Exp $
# -Id: messagetoken.PL,v 1.3 2010/02/21 20:09:01 ak Exp -
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi:Command::
                                                                                    
 ##  ##                                         ######         ##                   
 ######   ####   ##### #####  ####   #####  ####  ##     ####  ##     ####  #####   
 ######  ##  ## ##    ##         ## ##  ## ##  ## ##    ##  ## ## ## ##  ## ##  ##  
 ##  ##  ######  ####  ####   ##### ##  ## ###### ##    ##  ## ####  ###### ##  ##  
 ##  ##  ##         ##    ## ##  ##  ##### ##     ##    ##  ## ## ## ##     ##  ##  
 ##  ##   ####  ##### #####   #####     ##  ####  ##     ####  ##  ## ####  ##  ##  
                                    #####                                           
package Kanadzuchi::Command::MessageToken;

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
use Error ':try';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Database object
my $AaR = {};		# (Ref->Hash) Addresser and Recipient

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'token'		=> ( 1 << 2 ),
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
foreach my $sig ( 'INT','QUIT','TERM','KILL','ALRM')
{
	$SIG{$sig} = sub { $Cmd->catch_signal($sig); };
}

if( $Cmd->operation & $Cmd->option->{'token'} )
{
	require Kanadzuchi::String;
	require Kanadzuchi::Address;
	require Kanadzuchi::RFC2822;

	try{
		unless( Kanadzuchi::RFC2822->is_emailaddress( $AaR->{'addresser'} ) )
		{
			Kanadzuchi::Exception::Data->throw(
				'-text' => $AaR->{'addresser'}.' is invalid email address' );
		}

		unless( Kanadzuchi::RFC2822->is_emailaddress( $AaR->{'recipient'} ) )
		{
			Kanadzuchi::Exception::Data->throw(
				'-text' => $AaR->{'recipient'}.' is invalid email address' );
		}
	}
	catch Kanadzuchi::Exception::Data with {
		$Cmd->exception(shift());
		$Cmd->abort();
	};

	my $addresser = Kanadzuchi::Address->canonify(lc $AaR->{'addresser'});
	my $recipient = Kanadzuchi::Address->canonify(lc $AaR->{'recipient'});
	my $mesgtoken = Kanadzuchi::String->token( $addresser, $recipient );

	$Cmd->d( 1, sprintf("Addresser = %s\n", $addresser ) );
	$Cmd->d( 1, sprintf("Recipient = %s\n", $recipient ) );
	
	printf(STDOUT "%s\n", $mesgtoken );
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
		$opt_conf,
		$opt_recipient,
		$opt_test,
		$opt_verbose,
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

			# Data source options
			'a=s'		=> \$opt_addresser,
			'addresser=s'	=> \$opt_addresser,
			'r=s'		=> \$opt_recipient,
			'recipient=s'	=> \$opt_recipient,
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
		$Cmd->cf( new Path::Class::File('/dev/null'));
		$operation |= $Cmd->option->{'test'};
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
		$Cmd->cf->cleanup();
	}

	CHECK_ADDRESSER_AND_RECIPIENT: {

		last() unless( defined $opt_addresser );
		last() unless( defined $opt_recipient );

		if( $opt_addresser && $opt_recipient )
		{
			$AaR = {
				'addresser' => $opt_addresser,
				'recipient' => $opt_recipient,
			};
			$operation |= $Cmd->option->{'token'};
		}
	}

	# Check whether or not Required options are specified.
	return(0) unless( values(%$AaR) );
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
	printf( STDERR "Usage: %s [OPTIONS] file1 [file2 dir1 dir2 ...]\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * ADDRESS OPTIONS\n" );
	printf( STDERR "    -a, --addresser <str> : Sender address(Addresser)\n");
	printf( STDERR "    -r, --recipient <str> : Recipient address(Addresser)\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config>   : Location of the configuration file used instead of \n");
	printf( STDERR "                            __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test            : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    --silent              : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose         : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help                : Print help message(This screen)\n");
	printf( STDERR "    --version             : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "    %s -a %s -r %s\n", $Cmd->calledfrom(), 'postmaster@example.jp', 'user@example.org' );
	printf( STDERR "\n" );
	printf( STDERR " * Use printf command\n" );
	printf( STDERR "    Addresser(From:): %s\n", 'sender@example.jp' );
	printf( STDERR "    Recipient(To:):   %s\n", 'recipient@example.org' );
	printf( STDERR "    Message Token:    %s\n", '75cda805dc105761e8db23305d845075' );
	printf( STDERR "\n" );
	printf( STDERR q{    > printf "\x02%%s\x1e%%s\x03"}.qq{ %s %s }.q{| md5}.qq{\n},
			'sender@example.jp', 'recipient@example.org' );
	printf( STDERR "\n" );
	return(1);
}

__END__
