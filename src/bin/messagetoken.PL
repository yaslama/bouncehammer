#__PERLEXECUTABLE__
# $Id: messagetoken.PL,v 1.4 2010/03/19 07:38:54 ak Exp $
# -Id: messagetoken.PL,v 1.3 2010/02/21 20:09:01 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
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
my $Zci = undef();		# Kanadzuchi System object
my $Cmd = undef();		# Kanadzuchi::UI::CLI object
my $AaR = {};			# Addresser and Recipient

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

if( $Cmd->operation & $Cmd->option->{'token'} )
{
	require Kanadzuchi::String;
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

	my $addresser = Kanadzuchi::RFC2822->cleanup(lc($AaR->{'addresser'}));
	my $recipient = Kanadzuchi::RFC2822->cleanup(lc($AaR->{'recipient'}));
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
	my $_operation = 0;

	# Variables for decide operation
	my (
		$_opt_conf,
		$_opt_test,
		$_opt_addresser,
		$_opt_recipient,
		$_opt_silent,
		$_opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'a=s'		=> \$_opt_addresser,
			'addresser=s'	=> \$_opt_addresser,
			'r=s'		=> \$_opt_recipient,
			'recipient=s'	=> \$_opt_recipient,
			'C=s'		=> \$_opt_conf,
			'conf=s'	=> \$_opt_conf,
			'help'		=> sub { help(); exit(0); },
			'T'		=> \$_opt_test,
			'test'		=> \$_opt_test,
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
		$Cmd->cf( new Path::Class::File('/dev/null'));
		$_operation |= $Cmd->option->{'test'};
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
		$Cmd->cf->cleanup();
	}

	CHECK_ADDRESSER_AND_RECIPIENT: {

		last() unless( defined($_opt_addresser) );
		last() unless( defined($_opt_recipient) );

		if( $_opt_addresser && $_opt_recipient )
		{
			$AaR = {
				'addresser' => $_opt_addresser,
				'recipient' => $_opt_recipient,
			};
			$_operation |= $Cmd->option->{'token'};
		}
	}

	# Check whether or not Required options are specified.
	return(0) unless( values(%$AaR) );
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
