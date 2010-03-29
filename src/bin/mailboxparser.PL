#__PERLEXECUTABLE__
# $Id: mailboxparser.PL,v 1.12 2010/03/29 08:23:33 ak Exp $
# -Id: mailboxparser.PL,v 1.21 2010/02/21 20:09:01 ak Exp -
# -Id: mailboxparser.PL,v 1.2 2009/09/30 03:20:26 ak Exp -
# -Id: mailboxparser.PL,v 1.16 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Command::
                                                                                        
                 ##  ###  ##                                                            
 ##  ##  ####         ##  ##      #### ##  ## #####  ####  #####   #####  ####  #####   
 ######     ##  ###   ##  #####  ##  ## ####  ##  ##    ## ##  ## ##     ##  ## ##  ##  
 ######  #####   ##   ##  ##  ## ##  ##  ##   ##  ## ##### ##      ####  ###### ##      
 ##  ## ##  ##   ##   ##  ##  ## ##  ## ####  ##### ##  ## ##         ## ##     ##      
 ##  ##  #####  #### #### #####   #### ##  ## ##     ##### ##     #####   ####  ##      
                                              ##                                        
package Kanadzuchi::Command::MailboxParser;

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
use Time::Piece;
use Path::Class::File::Lockable;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Commandline object
my $Out;		# (String) Output directory for temp log
my $Fmt;		# (String) Output format
my $Mbox;		# (Path::Class::File) Mailbox Object
my $Mail = {
	'stdin' => 0,
	'files' => [],
	'dirs' => [], };
my $Skip = {
	'norelaying'	=> 0,
	'mailererror'	=> 0,
	'hostunknown'	=> 0,
};

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'parse'		=> ( 1 << 2 ),
	'log'		=> ( 1 << 3 ),
	'two-way'	=> ( 1 << 4 ),
	'truncate'	=> ( 1 << 5 ),
	'remove'	=> ( 1 << 6 ),
	'greed'		=> ( 1 << 7 ),
	'safe'		=> ( 1 << 8 ),
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
foreach my $__sig qw( INT QUIT TERM KILL ALRM )
{
	$SIG{$__sig} = sub { $Cmd->catch_signal($__sig); };
}

if( $Cmd->operation & $Cmd->option->{'parse'} )
{
	#  ____   _    ____  ____  _____ 
	# |  _ \ / \  |  _ \/ ___|| ____|
	# | |_) / _ \ | |_) \___ \|  _|  
	# |  __/ ___ \|  _ < ___) | |___ 
	# |_| /_/   \_\_| \_\____/|_____|
	#
	require Kanadzuchi::Mail::Bounced;
	require Kanadzuchi::Mbox;
	require Digest::MD5;

	my $hermboxparser;		# Kanadzuchi::Mbox object
	my $returnedmesgs = [];		# (Ref->Array) K::M::Bounced objects

	# Set timeout(ALRM) for reading from STDIN
	eval{ alarm( ( $Zci->config->{'environment'}->{'timeout'} || 180 ) ) };

	# Read from a Maildir and concatenate files in the directory
	if( scalar(@{$Mail->{'dirs'}}) || scalar(@{$Mail->{'files'}}) )
	{
		# Read from the directory(Maildir)
		my $pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
		my $tmpmailbox = new Path::Class::File($Cmd->tmpdir->stringify().q{/tempmailbox.mbox});
		my $mboxhandle;		# (IO::File) object for a temporary mailbox
		my $mfcontents;		# (String) Contents of the mailbox
		my $md5digests = [];	# (Ref->Array) MD5 digest strings of each file
		my $filedigest;		# (String) MD5 digest of each file

		SEEK_EACH_DIRECTORY: foreach my $d ( @{$Mail->{'dirs'}} )
		{
			$Cmd->d( 1, sprintf( "Seek the directory = %s\n", $d->stringify() ));

			READ_THE_DIRECTORY: while( my $mf = $d->next() )
			{
				next() if( -z $mf || ! -r _ || ! -f _ || ! -T _ );
				push( @{$Mail->{'files'}}, $mf );
			}

		} # End of foreach() 

		try {
			eval {
				$tmpmailbox->touch();
				$mboxhandle = $tmpmailbox->openw();
			}; 
			Kanadzuchi::Exception::Permission->throw( '-text' => $@ ) if($@);
		}
		otherwise {
			$Cmd->exception(shift());
			$Cmd->abort();
		};


		SEEK_EACH_FILE: foreach my $mf ( @{$Mail->{'files'}} )
		{
			next() if( -z $mf || ! -r _ || ! -f _ || ! -T _ );

			# Skip if the file has same MD5 digest
			$filedigest = Digest::MD5->new()->addfile($mf->openr())->hexdigest();
			next() if( grep( m{\A$filedigest\z}, @$md5digests ) );
			push( @{$md5digests}, $filedigest );

			# Read and write
			$Cmd->d( 1, sprintf( "Seek the mailbox file = %s\n", $mf->stringify() ));
			open( my $_eachmboxfh, q{<}, $mf ) || next();
			sysread( $_eachmboxfh, $mfcontents, -s $mf );

			# Does first 5 bytes of the message is 'From_' ?
			printf( $mboxhandle "%s", $pseudofrom ) if( substr($mfcontents,0,5) ne 'From ' );
			printf( $mboxhandle "%s", $mfcontents ) if( $mfcontents );
			$_eachmboxfh->close();

		} # End of foreach()

		$mboxhandle->close() if( ref($mboxhandle) eq q|IO::File| );
		$Mbox = new Path::Class::File( $tmpmailbox );
	}

	if( defined($Mbox) )
	{
		try {
			# Check the mailbox size
			my $_fsize = $Mbox->stat->size();
			my $_limit = $Zci->config->{'file'}->{'maxsize'};
			my $_error = $Mbox->stringify().qq{ is too big: $_fsize ( > $_limit bytes)};

			if( $_fsize > $_limit && $_limit != 0 )
			{
				Kanadzuchi::Exception::File->throw( '-text' => $_error );
			}
			$hermboxparser = new Kanadzuchi::Mbox( 'file' => $Mbox->stringify() );
		}
		catch Kanadzuchi::Exception::File with {
			$Cmd->exception(shift());
			$Cmd->abort();
		};
	}
	else
	{
		# Read the mailbox From STDIN
		$hermboxparser = new Kanadzuchi::Mbox();
	}


	if( $Cmd->operation & ( $Cmd->option->{'truncate'} + $Cmd->option->{'remove'} ) )
	{
		#   ____ _     _____    _    _   _   _   _ ____  
		#  / ___| |   | ____|  / \  | \ | | | | | |  _ \ 
		# | |   | |   |  _|   / _ \ |  \| | | | | | |_) |
		# | |___| |___| |___ / ___ \| |\  | | |_| |  __/ 
		#  \____|_____|_____/_/   \_\_| \_|  \___/|_|    
		#
		# Clean up, Remove mBox or Truncate mBox
		# Truncate the mailbox
		foreach my $f ( @{$Mail->{'files'}} )
		{
			if( $Cmd->operation & $Cmd->option->{'truncate'} )
			{
				$Cmd->d(2,sprintf("Truncate the mailbox = %s\n", $f->stringify() ));
				eval{ truncate($f->stringify(),0); };
				$Cmd->d(2,"Failed to truncate mailbox\n") if($@);
			}

			# Remove the mailbox
			if( $Cmd->operation & $Cmd->option->{'remove'} )
			{
				$Cmd->d(2,sprintf("Remove mailbox = %s\n", $f->stringify() ));
				eval{ $f->remove(); };
				$Cmd->d(2,"Failed to remove mailbox\n") if($@);
			}
		}
	}
	$Mail = undef();	# Flush the variable

	# Decide output directory
	if( $Cmd->operation & $Cmd->option->{'log'} )
	{
		$Out ||= $Zci->config->{'directory'}->{'spool'};
	}


	#  ____  _    _   _ ____  ____  
	# / ___|| |  | | | |  _ \|  _ \ 
	# \___ \| |  | | | | |_) | |_) |
	#  ___) | |__| |_| |  _ <|  __/ 
	# |____/|_____\___/|_| \_\_|    
	# 
	# Slurp the mailbox
	alarm(0);
	$hermboxparser->greed( $Cmd->operation & $Cmd->option->{'greed'} ? 1 : 0 );
	$hermboxparser->slurpit();

	# Put decided configuration values as debug message
	$Cmd->d(1,sprintf( "Log directory = %s\n", $Out )) if($Cmd->operation & $Cmd->option->{'log'} );
	$Cmd->d(1,sprintf( "Safe parse\n", $Out )) if($Cmd->operation & $Cmd->option->{'safe'} );
	$Cmd->d(1,sprintf( "Mbox file is = %s(%d Bytes)\n", (
					defined($Mbox)
					? ( $Mbox->stringify(), -s $Mbox->stringify() )
					: ( '<STDIN>', -1 ) )
				));
	$Cmd->d(0,sprintf( "Messages in the mbox = %d\n", $hermboxparser->nmails() )); 

	#  _____    _  _____   ___ _____ 
	# | ____|  / \|_   _| |_ _|_   _|
	# |  _|   / _ \ | |    | |  | |  
	# | |___ / ___ \| |    | |  | |  
	# |_____/_/   \_\_|   |___| |_|  
	# 
	# Parse the mailbox 
	$hermboxparser->parseit();

	# Call Kanadzuchi::Mail::Bounced->eatit()
	$returnedmesgs = Kanadzuchi::Mail::Bounced->eatit( 
				\$hermboxparser, {
					'cache' => $Cmd->tmpdir(), 
					'verbose' => $Cmd->debuglevel(), 
					'skip' => $Skip,
					'fast' => ( $Cmd->operation() & $Cmd->option->{'safe'} ? 0 : 1 ), } );

	$Cmd->d(0,sprintf( "Bounced message = %d\n", scalar(@{$returnedmesgs}) ));


	if( scalar(@{$returnedmesgs}) > 0 )
	{
		#  _     ___   ____  ____ _____ ____  
		# | |   / _ \ / ___|/ ___| ____|  _ \ 
		# | |  | | | | |  _| |  _|  _| | |_) |
		# | |__| |_| | |_| | |_| | |___|  _ < 
		# |_____\___/ \____|\____|_____|_| \_\
		# 
		require Kanadzuchi::Log;
		my $objherlogger = new Kanadzuchi::Log(
				entities => $returnedmesgs,
				count => scalar( @{$returnedmesgs} ),
			);

		if( $Cmd->operation & $Cmd->option->{'log'} )
		{
			#      __    _     ___   ____ _____ ___ _     _____ 
			#      \ \  | |   / _ \ / ___|  ___|_ _| |   | ____|
			#  _____\ \ | |  | | | | |  _| |_   | || |   |  _|  
			# |_____/ / | |__| |_| | |_| |  _|  | || |___| |___ 
			#      /_/  |_____\___/ \____|_|   |___|_____|_____|
			# 
			# Log to temporary log file.
			my $_tmpld = q(/tmp);				# Temporary directory
			my $_tmplf = q();				# Temporary file name
			my $_conff = \$Zci->config->{'file'};		# File name configurations in YAML
			my $_objdt = bless(localtime(),'Time::Piece');	# Time::Piece object

			# Set temporary log directory
			$_tmpld = $Out if( -d $Out && -w _ && -r _ );

			# Create temporary log file name, ex) her.2009-02-11.49b7c9e2.0011c5.tmp
			$_tmplf = sprintf("%s/%s.%s.%08x.%06x.%s", $_tmpld, $$_conff->{'templog'}->{'prefix'},
					$_objdt->ymd('-'), $_objdt->epoch(), $$, $$_conff->{'templog'}->{'suffix'} );
			$_tmplf = uc($_tmplf) if( -e $_tmplf );		# If it already exists

			# Set directory name and log fle name, and format
			$objherlogger->directory(new Path::Class::Dir($_tmpld));
			$objherlogger->logfile(new Path::Class::File::Lockable($_tmplf));
			$objherlogger->format('yaml');

			if( $objherlogger->logfile->locked() )
			{
				# Temporary logfile is now locked !
				$Cmd->d(1,sprintf( "Lock file exists = %s\n", $objherlogger->logfile->lock_file() ));
			}
			else
			{
				$Cmd->d(1,sprintf( "Writing temporary log = %s\n", $objherlogger->logfile() ));

				$objherlogger->logfile->touch();
				$objherlogger->logfile->lock();
				$objherlogger->device($objherlogger->logfile->openw());
				$objherlogger->logger();
				$objherlogger->device->close() if( ref($objherlogger->device()) eq q|IO::File| );
				$objherlogger->logfile->unlock();
			}
		}

		if( ! ( $Cmd->operation & $Cmd->option->{'log'} ) || $Cmd->operation & $Cmd->option->{'two-way'} )
		{
			#      __    ____   ____ ____  _____ _____ _   _ 
			#      \ \  / ___| / ___|  _ \| ____| ____| \ | |
			#  _____\ \ \___ \| |   | |_) |  _| |  _| |  \| |
			# |_____/ /  ___) | |___|  _ <| |___| |___| |\  |
			#      /_/  |____/ \____|_| \_\_____|_____|_| \_|
			# 
			# Output to the screen
			$Cmd->d(2,sprintf("Writing to the screen with format(%s)\n", $Fmt));
			$objherlogger->format($Fmt);
			$objherlogger->device('STDOUT');
			$objherlogger->dumper();
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
		$_opt_greed,
		$_opt_log,
		$_opt_2way,
		$_opt_outputdir,
		$_opt_remove,
		$_opt_truncate,
		$_opt_verbose,
		$_opt_silent,
		$_opt_safe,
		$_opt_skip,
		$_opt_skip_norelaying,
		$_opt_skip_mailererror,
		$_opt_skip_hostunknown,
		$_opt_test,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'2'		=> \$_opt_2way,
			'two-way'	=> \$_opt_2way,
			'conf=s'	=> \$_opt_conf,
			'C=s'		=> \$_opt_conf,
			'format=s'	=> \$_opt_format,
			'F=s'		=> \$_opt_format,
			'g'		=> \$_opt_greed,
			'greed'		=> \$_opt_greed,
			'log'		=> \$_opt_log,
			'l'		=> \$_opt_log,
			'output=s'	=> \$_opt_outputdir,
			'o=s'		=> \$_opt_outputdir,
			'remove'	=> \$_opt_remove,
			'S'		=> \$_opt_safe,
			'safe'		=> \$_opt_safe,
			's'		=> \$_opt_skip,
			'skip'		=> \$_opt_skip,
			'skip-norelaying'  => \$_opt_skip_norelaying,
			'skip-mailererror' => \$_opt_skip_mailererror,
			'skip-hostunknown' => \$_opt_skip_hostunknown,
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

	CHECK_MAIL_FILES_AND_DIRS:
	{
		if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' )
		{
			$Mail->{'stdin'} = 1;
			last(CHECK_MAIL_FILES_AND_DIRS);
		}

		my @_argvs = @ARGV;
		my @_mailfs = ();
		my @_mailds = ();

		map { $_ =~ y{[, ]}{}d; } @_argvs;
		@_mailfs = grep { -f $_ && -T _ && -s _ && -r _ } @_argvs;
		@_mailds = grep { -d $_ && -x _ && -r _ } @_argvs;

		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_mailfs;
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_mailds;

		@{ $Mail->{'files'} } = map { Path::Class::File->new($_) } @_mailfs;
		@{ $Mail->{'dirs'} } = map { Path::Class::Dir->new($_) } @_mailds;

		map { $_->cleanup(); } @{ $Mail->{'files'} };
		map { $_->cleanup(); } @{ $Mail->{'dirs'} };

		$_operation |= $Cmd->option->{'truncate'} if( $_opt_truncate );
		$_operation |= $Cmd->option->{'remove'} if( $_opt_remove );
	}

	# Output format options
	if( $_opt_format )
	{
		my $_1stcharacter = substr( $_opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq q(y) ? q(yaml) :
			$_1stcharacter eq q(j) ? q(json) :
			$_1stcharacter eq q(a) ? q(asciitable) : q(yaml);
	}
	else
	{
		# Default Log format is 'YAML' -Fy
		$Fmt = q(yaml);
	}

	if( $_opt_log || $_opt_2way )
	{
		# Log option
		$_operation |= $Cmd->option->{'log'};
		$_operation |= $Cmd->option->{'two-way'} if( $_opt_2way );

		if( defined($_opt_outputdir) && -d $_opt_outputdir && -r _ && -x _ )
		{
			$Out = $_opt_outputdir;
		}
	}

	# Enable Parsing, greedily parse
	if( $_opt_greed ){ $_operation |= $Cmd->option->{'greed'}; }
	if( $_opt_safe  ){ $_operation |= $Cmd->option->{'safe'};  }

	# Skip by the reason 
	if( $_opt_skip || $_opt_skip_norelaying || $_opt_skip_mailererror || $_opt_skip_hostunknown )
	{
		if( $_opt_skip || $_opt_skip_norelaying  ){ $Skip->{'norelaying'} = 1; }
		if( $_opt_skip || $_opt_skip_mailererror ){ $Skip->{'mailererror'} = 1; }
		if( $_opt_skip || $_opt_skip_hostunknown ){ $Skip->{'hostunknown'} = 1; }
	}

	$_operation |= $Cmd->option->{'parse'};
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
	printf( STDERR "Usage: %s [OPTIONS] mbox1 [ mbox2 [ dir1 [ ... ]]]\n", $Cmd->calledfrom() );
	printf( STDERR "       cat mbox1 [ mbox2 [...] ] | %s [OPTIONS] \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * PARSING OPTIONS\n" );
	printf( STDERR "    -g, --greed         : %s greedily parse messages\n", $Cmd->calledfrom() );
	printf( STDERR "    -S, --safe          : (SLOW) The parser output all their decoded body data to disk files.\n");
	printf( STDERR "    -s, --skip          : Skip if the reason is the followings, \n");
	printf( STDERR "    --skip-norelaying   :  - Skip if the reason is 'Relaying Denied'.\n");
	printf( STDERR "    --skip-mailererror  :  - Skip if the reason is 'Mailer Error'.\n");
	printf( STDERR "    --skip-hostunknown  :  - Skip if the reason is 'Host Unknown'.\n");
	printf( STDERR "\n" );
	printf( STDERR " * LOGGING OPTIONS\n" );
	printf( STDERR "    -2, --two-way       : Write parsed data to a log file and STDOUT.\n");
	printf( STDERR "    -l, --log           : Write parsed data to a log file.\n");
	printf( STDERR "    -o, --output <dir>  : Output directory location of a temporary log file which\n");
	printf( STDERR "                          created by -l(--log) option, uses with -l option\n");
	printf( STDERR "    --truncate          : Truncate the mailbox after parsing.\n");
	printf( STDERR "    --remove            : Remove the mailbox after parsing.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -F, --format <char> : Output(STDOUT only) format, the following are available.\n");
	printf( STDERR "                          [y]aml = Default, [j]son, and [a]sciitable\n");
	printf( STDERR "    --silent            : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s -C./test-run.cf -l /var/mail/bounce --truncate -vvv\n", $Cmd->calledfrom() );
	printf( STDERR "  /bin/cat /var/spool/mail/postmaster | %s --log -2g \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	return(1);
}


__END__
