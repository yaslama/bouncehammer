#__PERLEXECUTABLE__
# $Id: mailboxparser.PL,v 1.40.2.2 2011/03/18 05:46:12 ak Exp $
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
my $Argc = 0;		# (Integer) The number of files or dirs in argument
my $Mbox;		# (Path::Class::File) Mailbox Object
my $Mail = { 'files' => [], 'dirs' => [], };
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
	'batch'		=> ( 1 << 9 ),
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

	if( $Zci->config->{'syslog'}->{'enabled'} )
	{
		$Cmd->d( 2, sprintf("Syslog facility = %s\n", $Zci->config->{'syslog'}->{'facility'} ));
		$Zci->historique( 'info', 'starting (version '.$Zci->version.')' );
	}
}
otherwise {
	my $e = shift();
	$Cmd->exception($e);
	$Zci->historique('err',$e);
	$Cmd->abort();
};

# Set signal handlers
foreach my $sig qw( INT QUIT TERM KILL ALRM )
{
	$SIG{$sig} = sub { $Cmd->catch_signal($sig); };
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

	my $howmanymboxes = 0;		# (Integer) How many mailbox files
	my $sizeofmailbox = 0;		# (Integer) Total size of mailboxes
	my $parseprogress = undef();	# (Term::ProgressBar) Progress bar object
	my $progressbarcr = sub {};	# (Ref->Code) Term::ProgressBar
	my $debugmessages = q();	# (String) Debug message for Term::ProgressBar
	my $chunksofemail = [];		# (Ref->Array) Path::Class::File objects
	my $chunkmboxsize = ( $Zci->config->{'file'}->{'maxsize'} * 0.08 ) || 1048576;

	$chunkmboxsize = 102400 if( $chunkmboxsize < 102400 );		# 100 KB
	$chunkmboxsize = 1048576 if( $chunkmboxsize > 1048576 );	# 1 MB

	# Set timeout(ALRM) for reading from STDIN
	eval { alarm( ( $Zci->config->{'environment'}->{'timeout'} || 180 ) ) };

	# Read from a Maildir and concatenate files in the directory
	if( scalar @{$Mail->{'dirs'}} || scalar @{$Mail->{'files'}} )
	{
		# Read from the directory(Maildir)
		$Argc = ( scalar @{ $Mail->{'dirs'} } + scalar @{ $Mail->{'files'} } );
		my $pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
		my $directoryh;		# (GLob) Directory handle
		my $filesindir = 0;	# (Integer) The number of files in the directory

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
				next() if( -z $d.'/'.$mf || ! -r _ || ! -f _ || ! -T _ || ! -s _ );
				push( @{ $Mail->{'files'} }, $d.'/'.$mf );
				$filesindir++;
				alarm(0);
			}
			closedir( $directoryh );

		} # End of foreach(SEEK_EACH_DIRECTORY) 

		$Cmd->d( 1, sprintf( "The number of files in the directories = %d\n", $filesindir )) if( $filesindir );
		$Cmd->e('There is no valid email in the directories') unless( scalar @{$Mail->{'files'}} );



		my $tmpmailbox;		# (Path::Class::File) Temporary mailbox
		my $mboxhandle;		# (IO::File) object for a temporary mailbox
		my $mfcontents;		# (String) Contents of the mailbox
		my $filedigest;		# (String) MD5 digest of each file
		my $first5char = q();	# (String) First 5 characters
		my $md5digests = [];	# (Ref->Array) MD5 Digest hash values of each file

		# Create progress bar object if it is verbose mode
		if( scalar @{$Mail->{'files'}} && $Cmd->stream->{out} && $Cmd->debuglevel > -1 )
		{
			eval { require Term::ProgressBar; };
			$parseprogress = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => 'linear',
						'name' => 'Seek mailboxes',
						'count' => scalar @{ $Mail->{'files'} },
					});
			$progressbarcr = sub { $parseprogress->update() };
		}

		SEEK_EACH_FILE: while( my $mf = shift @{$Mail->{'files'}} )
		{
			#  _____ _ _           
			# |  ___(_) | ___  ___ 
			# | |_  | | |/ _ \/ __|
			# |  _| | | |  __/\__ \
			# |_|   |_|_|\___||___/
			#                      
			$progressbarcr->();
			next() if( -z $mf || ! -s _ );

			$filedigest = Digest::MD5->new->addfile(new IO::File(q{< }.$mf))->hexdigest();
			next() if( grep( { $_ eq $filedigest } @$md5digests ) );
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
			do { $_eachmailfh->close(); next() } unless( $first5char =~ m{\A[A-Za-z]} );

			# Does first 5 bytes of the message is 'From_' ?
			read( $_eachmailfh, $mfcontents, -s $mf );
			print( $mboxhandle $pseudofrom ) if( $first5char ne 'From ' );
			print( $mboxhandle $mfcontents ) if( $mfcontents );

			$_eachmailfh->close() if( $_eachmailfh );
			$sizeofmailbox += -s $mf;
			$howmanymboxes++;
			alarm(0);

			# Cleanup
			unlink($mf) if( $Cmd->operation & $Cmd->option->{'remove'} );
			truncate($mf,0) if( $Cmd->operation & $Cmd->option->{'truncate'} );
			File::Copy::move( $mf, $Bak ) if( $Cmd->operation & $Cmd->option->{'backup'} );

			if( $tmpmailbox->stat->size > $chunkmboxsize )
			{
				# The size of temporary mailbox file is bigger than the limit
				push( @$chunksofemail, $tmpmailbox );
				$mboxhandle->close() if( $mboxhandle );
				$mboxhandle = undef();
				$tmpmailbox = undef();
			}

		} # End of foreach(SEEK_EACH_FILE)

		if( defined $tmpmailbox && defined $mboxhandle )
		{
			push( @$chunksofemail, $tmpmailbox );
			$mboxhandle->close() if( $mboxhandle );
			$mboxhandle = undef();
			$tmpmailbox = undef();
		}

		# Flush the variables
		$Mail = undef();
		$filedigest = undef();
		$md5digests = [];
	}
	
	if( defined($parseprogress) )
	{
		$debugmessages = $Cmd->d( 2, sprintf( "Size of all mailboxes = %d bytes\n", $sizeofmailbox ));
		$parseprogress->message( $debugmessages ) if( $debugmessages );
	}

	if( scalar(@$chunksofemail) == 0 && $Argc > 0 )
	{
		$Cmd->e('No data in the mailboxes');
		$Zci->historique('notice','No data in the mailboxes');
		$Cmd->abort();
	}

	my $kanadzuchilog = new Kanadzuchi::Log();
	my $templogdevice = undef();	# (IO::File) Temporary log

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

		# Set temporary log directory and create temporary log file name.
		#  ex) her.2009-02-11.49b7c9e2.0011c5.tmp
		$_tmpld = $Out if( -d $Out && -w _ && -r _ );
		$_tmplf = $Zci->get_logfile( 't', { 'output' => $_tmpld } );

		# Set directory name and log fle name, and format
		$templogdevice = new IO::File( qq{>> $_tmplf} );
		$kanadzuchilog->directory(new Path::Class::Dir($_tmpld));
		$kanadzuchilog->format('yaml');
		$kanadzuchilog->logfile( new Path::Class::File::Lockable($_tmplf) );
		$kanadzuchilog->logfile->touch();
		$kanadzuchilog->logfile->lock();
		$kanadzuchilog->device( $templogdevice );

		if( defined($parseprogress) )
		{
			$debugmessages = $Cmd->d(1,sprintf( "Log directory = %s\n", $Out ));
			$parseprogress->message( $debugmessages ) if( $debugmessages );
			$debugmessages = $Cmd->d(1,sprintf( "Temporary log = %s\n", $kanadzuchilog->logfile() ));
			$parseprogress->message( $debugmessages ) if( $debugmessages );
		}
	}
	push( @$chunksofemail, q|<STDIN>| ) unless( scalar @$chunksofemail );

	my $howmanyemails = 0;		# (Integer) How many email messages
	my $howmanybounce = 0;		# (Integer) How many bounce messages
	my $howmanyparsed = 0;		# (Integer) How many parsed messages

	# (Ref->Hash) Options of K::M::Bounced->eatit()
	my $parseroptions = { 'verbose' => $Cmd->debuglevel(), 'skip' => $Skip, };

	PARSE_CHUNKS_OF_EMAIL: while( my $Mbox = shift @$chunksofemail )
	{
		my $mailboxparser;		# (Kanadzuchi::Mbox) Parser object
		my $mboxpiterator;		# (Kanadzuchi::Iterator) Kanadzuchi::Mail::Bounced objects

		if( $Mbox ne q|<STDIN>| )
		{
			$mailboxparser = new Kanadzuchi::Mbox( 'file' => $Mbox->stringify() );
			alarm(0);	# Reset alarm
		}
		else
		{
			# Read the mailbox From STDIN
			$mailboxparser = new Kanadzuchi::Mbox();
			$debugmessages = $Cmd->d(1, 'Waiting for data from STDIN..., timeout = '
						.( $Zci->config->{'environment'}->{'timeout'} || 180 ) );
			$parseprogress->message( $debugmessages ) if( $parseprogress && $debugmessages );
			undef($Mbox);
		}

		#  ____  _    _   _ ____  ____  
		# / ___|| |  | | | |  _ \|  _ \ 
		# \___ \| |  | | | | |_) | |_) |
		#  ___) | |__| |_| |  _ <|  __/ 
		# |____/|_____\___/|_| \_\_|    
		# 
		# Slurp the mailbox
		$mailboxparser->greed( $Cmd->operation & $Cmd->option->{'greed'} ? 1 : 0 );
		$mailboxparser->slurpit() || next();
		$howmanyemails += $mailboxparser->nmails();

		# Progress bar for each parser
		if( $Cmd->stream->{out} && $Cmd->debuglevel > -1 )
		{
			eval { require Term::ProgressBar; };
			$parseprogress = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => 'linear',
						'name' => 'Parse mailboxes('.(scalar(@$chunksofemail) + 1).')',
						'count' => $mailboxparser->nmails() * 2,
					});
		}

		#  ____                          
		# |  _ \ __ _ _ __ ___  ___ _ __ 
		# | |_) / _` | '__/ __|/ _ \ '__|
		# |  __/ (_| | |  \__ \  __/ |   
		# |_|   \__,_|_|  |___/\___|_|   
		#                                
		$mailboxparser->parseit( $progressbarcr ) || do { $progressbarcr->(); next(); };
		$howmanybounce += $mailboxparser->nmesgs();

		#  _____    _  _____   ___ _____ 
		# | ____|  / \|_   _| |_ _|_   _|
		# |  _|   / _ \ | |    | |  | |  
		# | |___ / ___ \| |    | |  | |  
		# |_____/_/   \_\_|   |___| |_|  
		# 
		# Call Kanadzuchi::Mail::Bounced->eatit()
		$mboxpiterator = Kanadzuchi::Mail::Bounced->eatit( $mailboxparser, $parseroptions, $progressbarcr );
		$howmanyparsed += $mboxpiterator->count();
		$parseprogress->update( $mailboxparser->nmails * 2 ) if( $parseprogress );

		# There is no parsed messages
		next() unless( $mboxpiterator->count() );

		$kanadzuchilog->entities( $mboxpiterator->all() );
		$kanadzuchilog->count( $mboxpiterator->count() );

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

	$Cmd->d( 0, sprintf( "Parsed emails/bounces(ratio) in the mailbox = %d/%d (%.4f)\n",
			$howmanyparsed, $howmanybounce, $howmanybounce == 0 ? 0 : ($howmanyparsed / $howmanybounce) ));

	if( $kanadzuchilog->logfile() )
	{
		$kanadzuchilog->device->close() if( ref($kanadzuchilog->device()) eq q|IO::File| );
		$kanadzuchilog->logfile->unlock() if( $kanadzuchilog->logfile->locked() );
		$kanadzuchilog->logfile->remove() if( -f $kanadzuchilog->logfile && ! -s _ );
	}

	if( $Cmd->operation & $Cmd->option->{'batch'} )
	{
		# Batch mode, output as a block style YAML format
		my $batchinfo = q();

		$batchinfo .= sprintf( qq|  all-of-mailbox-files: %d\n|, $howmanymboxes );
		$batchinfo .= sprintf( qq|  size-of-mailboxes:    %d\n|, $sizeofmailbox );
		$batchinfo .= sprintf( qq|  temporary-log-file:   "%s"\n|, -f $kanadzuchilog->logfile ? $kanadzuchilog->logfile : 'NA' );
		$batchinfo .= sprintf( qq|  messages:\n| );
		$batchinfo .= sprintf( qq|    all-of-emails:   %d\n|, $howmanyemails );
		$batchinfo .= sprintf( qq|    bounce-messages: %d\n|, $howmanybounce );
		$batchinfo .= sprintf( qq|    parsed-messages: %d\n|, $howmanyparsed );
		$batchinfo .= sprintf( qq|    ratio:\n| );
		$batchinfo .= sprintf( qq|      content-rate-for-bounce: %.4f\n|, $howmanyemails == 0 ? 0: ( $howmanybounce / $howmanyemails ) );
		$batchinfo .= sprintf( qq|      analytical-accuracy:     %.4f\n|, $howmanybounce == 0 ? 0: ( $howmanyparsed / $howmanybounce ) );

		$Cmd->batchstatus(\$batchinfo);
	}

	# syslog
	$Zci->historique( 'info',
		sprintf( "size=%d, emails=%d, bounces=%d, parsed=%d, output=%s",
			$sizeofmailbox, $howmanyemails, $howmanybounce, $howmanyparsed,
			( $Cmd->operation & $Cmd->option->{'two-way'} )
				? 'file, screen'
				: ( $Cmd->operation & $Cmd->option->{'log'} )
					? 'file' 
					: 'screen' 
		));

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
		$opt_2way,
		$opt_backup,
		$opt_batch,
		$opt_conf,
		$opt_format,
		$opt_greed,
		$opt_log,
		$opt_outputdir,
		$opt_remove,
		$opt_safe,	# Obsolete
		$opt_skip,
		$opt_skip_temperror,
		$opt_skip_norelaying,
		$opt_skip_mailererror,
		$opt_skip_hostunknown,
		$opt_test,
		$opt_truncate,
		$opt_verbose,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'B'		=> \$opt_batch,
			'batch'		=> \$opt_batch,
			'conf=s'	=> \$opt_conf,
			'C=s'		=> \$opt_conf,
			'test'		=> \$opt_test,
			'T'		=> \$opt_test,
			'help'		=> sub { help(); exit(0); },
			'silent'	=> sub { $Cmd->silent(1); },
			'verbose'	=> \$opt_verbose,
			'v+'		=> \$opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Log file options
			'2'		=> \$opt_2way,
			'two-way'	=> \$opt_2way,
			'output=s'	=> \$opt_outputdir,
			'o=s'		=> \$opt_outputdir,
			'log'		=> \$opt_log,
			'l'		=> \$opt_log,
			'format=s'	=> \$opt_format,
			'F=s'		=> \$opt_format,

			# Source file options
			'backup=s'	=> \$opt_backup,
			'remove'	=> \$opt_remove,
			'truncate'	=> \$opt_truncate,

			# Parser options
			'g'		=> \$opt_greed,
			'greed'		=> \$opt_greed,
			'S'		=> \$opt_safe,	# Obsolete
			'safe'		=> \$opt_safe,	# Obsolete
			's'		=> \$opt_skip,
			'skip'		=> \$opt_skip,
			'skip-temperror'   => \$opt_skip_temperror,
			'skip-norelaying'  => \$opt_skip_norelaying,
			'skip-mailererror' => \$opt_skip_mailererror,
			'skip-hostunknown' => \$opt_skip_hostunknown,
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
		$Cmd->cf->cleanup();
	}

	CHECK_MAIL_FILES_AND_DIRS:
	{
		last() if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' );

		my @_argvs = @ARGV;

		@{ $Mail->{'files'} } = grep { -f $_ && -T _ && -r _ } @_argvs;
		@{ $Mail->{'dirs'}  } = grep { -d $_ && -x _ && -r _ } @_argvs;

		if( scalar(@{$Mail->{'files'}}) == 0 && scalar(@{$Mail->{'dirs'}}) == 0 )
		{
			$Cmd->e( 'Neither the mailbox nor the maildir exists '
				.'nor it is not valid: '.join(', ',@_argvs) );
		}

		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @{ $Mail->{'files'} };
		map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @{ $Mail->{'dirs'}  };

		if( $opt_truncate || $opt_remove )
		{
			$operation |= $Cmd->option->{'truncate'} if( $opt_truncate );
			$operation |= $Cmd->option->{'remove'} if( $opt_remove );
		}
		elsif( defined($opt_backup) && -d $opt_backup && -r _ && -x _ && -w _ )
		{
			$operation |= $Cmd->option->{'backup'};
			$Bak = $opt_backup;
			require File::Copy;
		}
	}

	# Output format options
	if( $opt_format )
	{
		my $_1stcharacter = substr( $opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq q(y) ? q(yaml) :
			$_1stcharacter eq q(j) ? q(json) :
			$_1stcharacter eq q(c) ? q(csv) :
			$_1stcharacter eq q(a) ? q(asciitable) : q(yaml);
	}
	else
	{
		# Default Log format is 'YAML' -Fy
		$Fmt = q(yaml);
	}

	if( $opt_log || $opt_2way )
	{
		# Log option
		$operation |= $Cmd->option->{'log'};

		if( $opt_2way )
		{
			$operation |= $Cmd->option->{'two-way'};
		}
		elsif( $opt_batch )
		{
			# Output results as a YAML in batch mode 
			$operation |= $Cmd->option->{'batch'};
		}

		if( defined($opt_outputdir) && -d $opt_outputdir && -r _ && -x _ )
		{
			$Out = $opt_outputdir;
		}
	}

	# Enable Parsing, greedily parse
	if( $opt_greed ){ $operation |= $Cmd->option->{'greed'}; }

	# Skip by the reason 
	if( $opt_skip || $opt_skip_temperror || $opt_skip_norelaying 
		|| $opt_skip_mailererror || $opt_skip_hostunknown ){

		if( $opt_skip || $opt_skip_temperror   ){ $Skip->{'temperror'} = 1; }
		if( $opt_skip || $opt_skip_norelaying  ){ $Skip->{'norelaying'} = 1; }
		if( $opt_skip || $opt_skip_mailererror ){ $Skip->{'mailererror'} = 1; }
		if( $opt_skip || $opt_skip_hostunknown ){ $Skip->{'hostunknown'} = 1; }
	}

	$operation |= $Cmd->option->{'parse'};
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
	printf( STDERR "Usage: %s [OPTIONS] mbox1 [ mbox2 [ dir1 [ ... ]]]\n", $Cmd->calledfrom() );
	printf( STDERR "       cat mbox1 [ mbox2 [...] ] | %s [OPTIONS] \n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * PARSING OPTIONS\n" );
	printf( STDERR "    -g, --greed         : %s greedily parse messages\n", $Cmd->calledfrom() );
	printf( STDERR "    -S, --safe          : Obsolete\n" );
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
	printf( STDERR "    -B, --batch         : Run in batch mode, results are printed in YAML format.\n");
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -F, --format <char> : Output(STDOUT only) format, the followings are available.\n");
	printf( STDERR "                          [y]aml = Default, [j]son, [c]sv and [a]sciitable\n");
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
