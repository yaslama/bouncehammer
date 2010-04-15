#__PERLEXECUTABLE__
# $Id: mailboxparser.PL,v 1.20 2010/04/15 08:39:11 ak Exp $
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

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Commandline object
my $Out;		# (String) Output directory for temp log
my $Bak;		# (String) Backup directory for the mailbox
my $Fmt;		# (String) Output format
my $Mbox;		# (Path::Class::File) Mailbox Object
my $Mail = {
	'stdin' => 0,
	'files' => [],
	'dirs' => [], };
my $Skip = {
	'temperror'	=> 0,
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
	'backup'	=> ( 1 << 7 ),
	'greed'		=> ( 1 << 8 ),
	'safe'		=> ( 1 << 9 ),
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
	require Path::Class::File::Lockable;
	require Kanadzuchi::Mail::Bounced;
	require Kanadzuchi::Mbox;
	require Kanadzuchi::Log;
	require Digest::MD5;
	require IO::File;

	my $chunksofemail = [];		# (Ref->Array) Path::Class::File objects
	my $chunkmboxsize = ($Zci->config->{'file'}->{'maxsize'} * 0.20787 ) || 33554432;
	my $seekprogressx = undef();

	$chunkmboxsize = 102400 if( $chunkmboxsize < 102400 );		# 100 KB
	$chunkmboxsize = 33554432 if( $chunkmboxsize > 33554432 );	# 32 MB

	# Set timeout(ALRM) for reading from STDIN
	eval { alarm( ( $Zci->config->{'environment'}->{'timeout'} || 180 ) ) };

	# Read from a Maildir and concatenate files in the directory
	if( scalar(@{$Mail->{'dirs'}}) || scalar(@{$Mail->{'files'}}) )
	{
		# Read from the directory(Maildir)
		my $pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
		my $tmpmailbox;		# (Path::Class::File) Temporary mailbox
		my $mboxhandle;		# (IO::File) object for a temporary mailbox
		my $directoryh;		#
		my $mfcontents;		# (String) Contents of the mailbox
		my $filedigest;		# (String) MD5 digest of each file
		my $filesindir = 0;	# (Integer) The number of files in the directory
		my $first5char = q();	# (String) First 5 characters
		my $md5digests = [];	# (Ref->Array) MD5 Digest hash values of each file

		$Cmd->d( 2, sprintf( "Max size of each chunk = %d bytes\n", $chunkmboxsize ));

		SEEK_EACH_DIRECTORY: foreach my $d ( @{$Mail->{'dirs'}} )
		{
			#  ____  _               _             _           
			# |  _ \(_)_ __ ___  ___| |_ ___  _ __(_) ___  ___ 
			# | | | | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
			# | |_| | | | |  __/ (__| || (_) | |  | |  __/\__ \
			# |____/|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
			#                                                  
			$Cmd->d( 1, sprintf( "Seek the directory = %s\n", $d ));

			opendir( $directoryh, $d );
			READ_FILES_IN_THE_DIRECTORY: while( my $mf = readdir($directoryh) )
			{
				next() if( -z $d.'/'.$mf || ! -r _ || ! -f _ || ! -T _ );
				push( @{ $Mail->{'files'} }, $d.'/'.$mf );
				$filesindir++;
				alarm(0);
			}
			closedir( $directoryh );

		} # End of foreach(SEEK_EACH_DIRECTORY) 
		$Cmd->d( 1, sprintf( "The number of files in the directories = %d\n", $filesindir ));

		if( scalar(@{$Mail->{'files'}}) && $Cmd->debuglevel > -1 )
		{
			eval { require Term::ProgressBar; };
			$seekprogressx = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => q(linear),
						'name' => q(Seek mailboxes),
						'count' => scalar(@{$Mail->{'files'}}),
					});
		}


		SEEK_EACH_FILE: foreach my $mf ( @{$Mail->{'files'}} )
		{
			#  _____ _ _           
			# |  ___(_) | ___  ___ 
			# | |_  | | |/ _ \/ __|
			# |  _| | | |  __/\__ \
			# |_|   |_|_|\___||___/
			#                      
			$seekprogressx->update() if( defined($seekprogressx) );
			next() if( -z $mf || ! -r _ || ! -f _ || ! -T _ );

			$filedigest = Digest::MD5->new->addfile(new IO::File(q{< }.$mf))->hexdigest();
			next() if( grep( m{\A$filedigest\z}, @$md5digests ) );
			push( @$md5digests, $filedigest );

			unless( $mboxhandle )
			{
				$tmpmailbox = new Path::Class::File(
						$Cmd->tmpdir->stringify().q{/tempmailbox.}.$filedigest.q{.mbox});

				$tmpmailbox->touch();
				$mboxhandle = $tmpmailbox->openw();
			}

			# Read and write
			open( my $_eachmailfh, q{<}, $mf ) || next();

			# Skip to the next loop if the file does not seem to email.
			read( $_eachmailfh, $first5char, 5 );
			seek( $_eachmailfh, 0, 0 );

			# Skip to the next loop if the file not like email.
			next() unless( $first5char =~ m{\A[A-Za-z]} );

			# Does first 5 bytes of the message is 'From_' ?
			read( $_eachmailfh, $mfcontents, -s $mf );
			print( $mboxhandle $pseudofrom ) if( $first5char ne 'From ' );
			print( $mboxhandle $mfcontents ) if( $mfcontents );
			$_eachmailfh->close() if( ref($_eachmailfh) eq q|IO::Handle| );
			alarm(0);

			# Cleanup
			unlink($mf) if( $Cmd->operation & $Cmd->option->{'remove'} );
			truncate($mf,0) if( $Cmd->operation & $Cmd->option->{'truncate'} );
			File::Copy::move( $mf, $Bak ) if( $Cmd->operation & $Cmd->option->{'backup'} );

			if( $tmpmailbox->stat->size > $chunkmboxsize )
			{
				# The size of temporary mailbox file is bigger than the limit
				push( @$chunksofemail, $tmpmailbox );
				$mboxhandle->close() if( ref($mboxhandle) eq q|IO::Handle| );
				$mboxhandle = undef();
				$tmpmailbox = undef();
			}

		} # End of foreach(SEEK_EACH_FILE)

		if( defined($tmpmailbox) && defined($mboxhandle) )
		{
			push( @$chunksofemail, $tmpmailbox );
			$mboxhandle->close() if( ref($mboxhandle) eq q|IO::File| );
			$mboxhandle = undef();
			$tmpmailbox = undef();
		}

		# Flush the variables
		$Mail = undef();
		$filedigest = undef();
		$md5digests = [];
	}


	my $kanadzuchilog = new Kanadzuchi::Log();
	my $templogdevice;		# (IO::File) Temporary log
	my $mailboxparser;		# (Kanadzuchi::Mbox) Parser object
	my $returnedmesgs = [];		# (Ref->Array) Kanadzuchi::Mail::Bounced objects
	my $stageofparser = 0;		# (Integer) Present state number
	my $msgsintheklog = 0;		# (Integer) The number of parsed messages
	my $msgsinthembox = 0;		# (Integer) The number of emails in the mbox

	if( $Cmd->operation & $Cmd->option->{'log'} )
	{
		#  _     ___   ____  ____ _____ ____  
		# | |   / _ \ / ___|/ ___| ____|  _ \ 
		# | |  | | | | |  _| |  _|  _| | |_) |
		# | |__| |_| | |_| | |_| | |___|  _ < 
		# |_____\___/ \____|\____|_____|_| \_\
		# 
		# Decide output directory
		$Out ||= $Zci->config->{'directory'}->{'spool'};

		# Log to temporary log file.
		my $_tmpld = q(/tmp);				# Temporary directory
		my $_tmplf = q();				# Temporary file name
		my $_conff = $Zci->config->{'file'};		# File name configurations in YAML
		#my $_objdt = bless(localtime(),'Time::Piece');	# Time::Piece object

		# Set temporary log directory and create temporary log file name.
		#  ex) her.2009-02-11.49b7c9e2.0011c5.tmp
		$_tmpld = $Out if( -d $Out && -w _ && -r _ );
		$_tmplf = $Zci->get_logfile( 't', { 'output' => $_tmpld } );
		# $_tmplf = sprintf("%s/%s.%s.%08x.%06x.%s", $_tmpld, $_conff->{'templog'}->{'prefix'},
		#		$_objdt->ymd('-'), $_objdt->epoch(), $$, $_conff->{'templog'}->{'suffix'} );
		#$_tmplf = uc($_tmplf) if( -e $_tmplf );		# If it already exists

		# Set directory name and log fle name, and format
		$templogdevice = new IO::File( qq{>> $_tmplf} );
		$kanadzuchilog->directory(new Path::Class::Dir($_tmpld));
		$kanadzuchilog->format('yaml');
		$kanadzuchilog->logfile( new Path::Class::File::Lockable($_tmplf) );
		$kanadzuchilog->logfile->touch();
		$kanadzuchilog->logfile->lock();
		$kanadzuchilog->device( $templogdevice );

		$Cmd->d(1,sprintf( "[This process] Log directory = %s\n", $Out ));
		$Cmd->d(1,sprintf( "[This process] Temporary log = %s\n", $kanadzuchilog->logfile() ));
	}


	push( @$chunksofemail, q|<STDIN>| ) unless( scalar(@$chunksofemail) );
	$Cmd->d(1,sprintf( "[This Process] Safe parse\n", $Out )) if($Cmd->operation & $Cmd->option->{'safe'} );

	PARSE_CHUNKS_OF_EMAIL: foreach my $Mbox ( @$chunksofemail )
	{
		#  ____                          
		# |  _ \ __ _ _ __ ___  ___ _ __ 
		# | |_) / _` | '__/ __|/ _ \ '__|
		# |  __/ (_| | |  \__ \  __/ |   
		# |_|   \__,_|_|  |___/\___|_|   
		#                                
		if( $Mbox ne q|<STDIN>| )
		{
			$mailboxparser = new Kanadzuchi::Mbox( 'file' => $Mbox->stringify() );
		}
		else
		{
			# Read the mailbox From STDIN
			$mailboxparser = new Kanadzuchi::Mbox();
			$Mbox = undef();
		}

		$stageofparser++;

		#  ____  _    _   _ ____  ____  
		# / ___|| |  | | | |  _ \|  _ \ 
		# \___ \| |  | | | | |_) | |_) |
		#  ___) | |__| |_| |  _ <|  __/ 
		# |____/|_____\___/|_| \_\_|    
		# 
		# Slurp the mailbox
		$mailboxparser->greed( $Cmd->operation & $Cmd->option->{'greed'} ? 1 : 0 );
		$mailboxparser->slurpit();

		# Reset alarm(Read from STDIN)
		alarm(0);

		# Put decided configuration values as debug message
		$Cmd->d(1,sprintf( "[Stage: #%04d] Mailbox file = %s(%d Bytes)\n", $stageofparser, (
						defined($Mbox)
						? ( $Mbox->stringify(), -s $Mbox->stringify() )
						: ( '<STDIN>', -1 ) )
					));
		next() unless( $mailboxparser->nmails() );

		#  _____    _  _____   ___ _____ 
		# | ____|  / \|_   _| |_ _|_   _|
		# |  _|   / _ \ | |    | |  | |  
		# | |___ / ___ \| |    | |  | |  
		# |_____/_/   \_\_|   |___| |_|  
		# 
		# Parse the mailbox 
		$mailboxparser->parseit();

		# Call Kanadzuchi::Mail::Bounced->eatit()
		$returnedmesgs = Kanadzuchi::Mail::Bounced->eatit( 
					\$mailboxparser, {
						'cache' => $Cmd->tmpdir(), 
						'verbose' => $Cmd->debuglevel(), 
						'skip' => $Skip,
						'fast' => ( $Cmd->operation() & $Cmd->option->{'safe'} ? 0 : 1 ), } );

		$Cmd->d( 1, sprintf( "[Stage: #%04d] Parsed Messages/emails in the mailbox = %d/%d\n", 
					$stageofparser, scalar(@$returnedmesgs), $mailboxparser->nmails() )); 
		$msgsinthembox += $mailboxparser->nmails();
		$msgsintheklog += scalar(@$returnedmesgs);

		# There is no parsed messages
		next() unless( scalar(@{$returnedmesgs}) );

		$kanadzuchilog->entities( $returnedmesgs );
		$kanadzuchilog->count( scalar( @$returnedmesgs ) );

		if( $Cmd->operation & $Cmd->option->{'log'} )
		{
			#      __    _     ___   ____ _____ ___ _     _____ 
			#      \ \  | |   / _ \ / ___|  ___|_ _| |   | ____|
			#  _____\ \ | |  | | | | |  _| |_   | || |   |  _|  
			# |_____/ / | |__| |_| | |_| |  _|  | || |___| |___ 
			#      /_/  |_____\___/ \____|_|   |___|_____|_____|
			# 
			$kanadzuchilog->format('yaml');
			$kanadzuchilog->device($templogdevice);
			$kanadzuchilog->logger();
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
			$kanadzuchilog->format($Fmt);
			$kanadzuchilog->device('STDOUT');
			$kanadzuchilog->dumper();
		}


	} # End of foreach(PARSE_CHUNKS_OF_EMAIL)

	$Cmd->d(0,sprintf( "[This process] Parsed messages/emails in the mailbox = %d/%d\n", $msgsintheklog, $msgsinthembox ));
	if( ref($kanadzuchilog->device()) eq q|IO::File| && $kanadzuchilog->logfile() )
	{
		$kanadzuchilog->device->close();
		$kanadzuchilog->logfile->unlock() if( $kanadzuchilog->logfile->locked() );
		$kanadzuchilog->logfile->remove() if( -f $kanadzuchilog->logfile && ! -s _ );
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
		$_opt_backup,
		$_opt_verbose,
		$_opt_silent,
		$_opt_safe,
		$_opt_skip,
		$_opt_skip_temperror,
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
			'backup=s'	=> \$_opt_backup,
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
			'skip-temperror'   => \$_opt_skip_temperror,
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

		map { $_ =~ y{[ ]}{}d; } @_argvs;
		@{ $Mail->{'files'} } = grep { -f $_ && -T _ && -r _ } @_argvs;
		@{ $Mail->{'dirs'}  } = grep { -d $_ && -x _ && -r _ } @_argvs;

		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @{ $Mail->{'files'} };
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @{ $Mail->{'dirs'}  };

		if( $_opt_truncate || $_opt_remove )
		{
			$_operation |= $Cmd->option->{'truncate'} if( $_opt_truncate );
			$_operation |= $Cmd->option->{'remove'} if( $_opt_remove );
		}
		elsif( defined($_opt_backup) && -d $_opt_backup && -r _ && -x _ && -w _ )
		{
			$_operation |= $Cmd->option->{'backup'};
			$Bak = $_opt_backup;
			require File::Copy;
		}
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
	if( $_opt_skip || $_opt_skip_temperror || $_opt_skip_norelaying 
		|| $_opt_skip_mailererror || $_opt_skip_hostunknown ){

		if( $_opt_skip || $_opt_skip_temperror   ){ $Skip->{'temperror'} = 1; }
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
	printf( STDERR "    --skip-temperror    :  - Skip if the status is temporary error(4xx).\n");
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
	printf( STDERR "    --backup <dir>      : Backup; move the mailbox to the directory after parsing.\n");
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
