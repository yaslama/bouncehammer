# $Id: Mbox.pm,v 1.28.2.3 2011/08/23 21:29:53 ak Exp $
# -Id: Parser.pm,v 1.10 2009/12/26 19:40:12 ak Exp -
# -Id: Parser.pm,v 1.1 2009/08/29 08:50:27 ak Exp -
# -Id: Parser.pm,v 1.4 2009/07/31 09:03:53 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                             
 ##  ## ##                   
 ###### ##      #### ##  ##  
 ###### #####  ##  ## ####   
 ##  ## ##  ## ##  ##  ##    
 ##  ## ##  ## ##  ## ####   
 ##  ## #####   #### ##  ##  
package Kanadzuchi::Mbox;

# See also
#  * http://en.wikipedia.org/wiki/Comparison_of_mail_servers
#  * http://en.wikipedia.org/wiki/List_of_mail_servers

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Perl6::Slurp;
use JSON::Syck;
use Kanadzuchi::MTA::Sendmail;
use Kanadzuchi::MTA::Postfix;
use Kanadzuchi::MTA::qmail;
use Kanadzuchi::MTA::Exim;
use Kanadzuchi::MTA::Courier;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'file',		# (String) File name to parse
	'greed',	# (Integer) Flag, 1 is greedily parse
	'emails',	# (Ref->Array) eMails, Raw test data
	'nmails',	# (Interger) The number of eMails
	'messages',	# (Ref->Array) Messages(Ref->Hash)
	'nmesgs',	# (Integer) The number of parsed messages
);

#  ____ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||o |||n |||s |||t |||a |||n |||t ||
# ||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub ENDOF() { qq(\n__THE_END_OF_THE_EMAIL__\n); }
my $TransferAgents = __PACKAGE__->postulat();
my $MostFamousMTAs = [ 'Sendmail', 'Postfix', 'qmail', 'Exim', 'Courier' ];

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param
	# @Return	Kanadzuchi::Mbox Object
	my $class = shift();
	my $argvs = { @_ };

	DEFAULT_VALUES: {
		$argvs->{'greed'} = 0 unless $argvs->{'greed'};
		$argvs->{'nmails'} = 0;
		$argvs->{'emails'} = [];
		$argvs->{'nmesgs'} = 0;
		$argvs->{'messages'} = [];
	}

	return $class->SUPER::new( $argvs );
}

sub postulat
{
	# +-+-+-+-+-+-+-+-+
	# |p|o|s|t|u|l|a|t|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Require Kanadzuchi::MTA::??::*
	# @Param	<None>
	# @Return	(Ref->Array) Loaded class names
	# @See		etc/avalable-countries
	#
	#     agents: [ 'name-of-mta1', 'name-of-mta2', ... ]
	#       * The key 'agents' does not exist: Load all of modules in Kanadzuchi::
	#         Mbox::<CCTLD or ISO3166>::*.pm
	#       * The key 'agents' is EMPTY: Does NOT load any moduels in Kanadzuchi::
	#         Mbox::<CCTLD or ISO3166>::*.pm
	#       * The key 'agents' has a value: Load only the module of its name in 
	#         Kanadzuch::Mbox::<CCTLD or ISO3166>::<its name>.pm
	my $class = shift();

	# Experimental implementation for the future.
	my $libmboxroot = '__KANADZUCHILIB__/Kanadzuchi/MTA';
	my $iso3166list = [ 'User', 'JP', 'US' ];
	my $iso3166conf = '__KANADZUCHIETC__/available-countries';
	my $countryconf = ( -r $iso3166conf && -s _ && -T _ ) ? JSON::Syck::LoadFile($iso3166conf) : {};
	my $didfileload = keys %$countryconf ? 1 : 0;
	my $listofclass = [];
	my $acclassname = q();

	EACH_COUNTRY: foreach my $code ( @$iso3166list )
	{
		# etc/avalable-countries does not exist, load all of modules in 
		# Kanadzuchi/MTA/??/*.pm
		my $directory = $libmboxroot.'/'.$code;
		my $mtaoption = [];	# Require files in this array

		# The directory does not exist or is not readable, or is not executable.
		next(EACH_COUNTRY) unless( -d $directory && -r _ && -x _ );

		if( $didfileload && exists( $countryconf->{ lc $code }->{'agents'} ) )
		{
			# The key 'agents' exists, check the value of the key
			$mtaoption = $countryconf->{ lc $code }->{'agents'};

			# agents: []
			#   * The key 'agents' is EMPTY: Does NOT load any moduels in 
			#     Kanadzuchi::MTA::<CCTLD or ISO3166>::*.pm
			next(EACH_COUNTRY) unless( scalar @$mtaoption );

			# agents: [ 'something', ... ]
			#   * The key 'agents' has a value: Load only the module of its
			#     name in Kanadzuch::MTA::<CCTLD or ISO3166>::<its name>.pm
			map { $_ = lc $_.'.pm' } @$mtaoption;
		}

		opendir( my $dh, $directory );
		READDIR: while( my $de = readdir($dh) )
		{
			my $fp = $directory.'/'.$de;

			# the file is not *.pm, nor regular file, nor readable
			next(READDIR) if( $fp !~ m{[.]pm\z} || ! -f $fp || ! -r _ );
			next(READDIR) if( scalar @$mtaoption && ! grep { lc($de) eq $_ } @$mtaoption );

			$acclassname  = 'Kanadzuchi::MTA::'.$code.'::'.$de;
			$acclassname =~ s{[.]pm\z}{};

			eval { require $fp; };
			push( @$listofclass, $acclassname ) unless $@;
		}
		closedir($dh);

	} # End of foreach(EACH_COUNTRY)

	return $listofclass;
}

sub breakit
{
	# +-+-+-+-+-+-+-+
	# |b|r|e|a|k|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Break the header of message and return its body
	# @Param <ref>	(Ref->Hash) Message entity.
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Message body or empty string
	my $packagename = shift();
	my $thismessage = shift() || return q();
	my $thebodypart = shift() || return q();
	my $theheadpart = $thismessage->{'head'};

	# For Code Refactoring IN THE FUTURE.
	# my $contenttype = [	
	#	qr{\Amultipart/(?:report|mixed)},
	#	qr{\Amessage/(?:delivery-status|rfc822)},
	#	qr{\Atext/rfc822-headers},
	# ];

	# Check whether or not the message is a bounce mail.
	#  _____             _     _____                                _          _ 
	# |  ___|_      ____| |_  |  ___|__  _ ____      ____ _ _ __ __| | ___  __| |
	# | |_  \ \ /\ / / _` (_) | |_ / _ \| '__\ \ /\ / / _` | '__/ _` |/ _ \/ _` |
	# |  _|  \ V  V / (_| |_  |  _| (_) | |   \ V  V / (_| | | | (_| |  __/ (_| |
	# |_|     \_/\_/ \__,_(_) |_|  \___/|_|    \_/\_/ \__,_|_|  \__,_|\___|\__,_|
	#                                                                            
	# Pre-Process eMail body if it is a forwarded bounce message.
	#  Get forwarded text if a subject begins from 'fwd:' or 'fw:'
	if( lc( $theheadpart->{'subject'} ) =~ m{\A\s*fwd?:} )
	{
		# Break quoted strings, quote symbols(>)
		$$thebodypart =~ s{\A.+?[>]}{>}s;
		$$thebodypart =~ s{^[>]+[ ]}{}gm;
		$$thebodypart =~ s{^[>]$}{}gm;
	}

	#  ____  _                  _               _   _____                          _   
	# / ___|| |_ __ _ _ __   __| | __ _ _ __ __| | |  ___|__  _ __ _ __ ___   __ _| |_ 
	# \___ \| __/ _` | '_ \ / _` |/ _` | '__/ _` | | |_ / _ \| '__| '_ ` _ \ / _` | __|
	#  ___) | || (_| | | | | (_| | (_| | | | (_| | |  _| (_) | |  | | | | | | (_| | |_ 
	# |____/ \__\__,_|_| |_|\__,_|\__,_|_|  \__,_| |_|  \___/|_|  |_| |_| |_|\__,_|\__|
	#                                                                                  
	# Pre-Process eMail headers of standard bounce message
	#return $$thebodypart if( $theheadpart->{'content-type'} && 
	#			grep { $theheadpart->{'content-type'} =~ $_ } @$contenttype );
	#
	my $parserclass = q();		# (String) Package|Class name
	my $pseudofield = q();		# (String) Pseudo headers
	my $agentmodule = q();		# (String) Agent class name
	my $isforwarded = 0;		# (Integer) Is forwarded message

	# Most famous MTAs
	foreach my $mta ( @$MostFamousMTAs )
	{
		$agentmodule  = q|Kanadzuchi::MTA::|.$mta;
		$pseudofield .= $agentmodule->reperit( $theheadpart, $thebodypart );
		last() if( $pseudofield );
	}

	# Optionals
	unless( $pseudofield )
	{
		foreach my $mod ( @$TransferAgents )
		{
			$pseudofield .= $mod->reperit( $theheadpart, $thebodypart );
			last() if( $pseudofield );
		}

		# Fallback
		unless( $pseudofield )
		{
			require Kanadzuchi::MTA::Fallback;
			$pseudofield .= Kanadzuchi::MTA::Fallback->reperit( $theheadpart, $thebodypart );

			unless( $pseudofield )
			{
				if( $$thebodypart =~ m{^[Ss]tatus: [45][.][0-7][.]\d+(.*)}m )
				{
					unless( $$thebodypart =~ m{^[Dd]iagnostic-[Cc]ode: }m )
					{
						$pseudofield .= 'X-SMTP-Diagnosis: '.$1.qq(\n);
					}
					$pseudofield .= Kanadzuchi::MTA->xsmtpcommand('DATA');
					$pseudofield .= Kanadzuchi::MTA->xsmtpagent('unknown');
				}
			}
		}
	}
	return $pseudofield.$$thebodypart;
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub slurpit
{
	# +-+-+-+-+-+-+-+
	# |s|l|u|r|p|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Slurp the email
	# @Param	<None>
	# @Return	(Integer) n = The number of slurped emails
	my $self = shift();
	my $file = defined($self->{'file'}) ? $self->{'file'} : \*STDIN;

	unless( ref($file) eq q|SCALAR| )
	{
		return(0) if( $file =~ m{[\n\r]} || $file =~ m{[\x00-\x1f\x7f]} );
		return(0) if(
			! ( -f $file && -T _ && -s _ ) &&
			! ( ref($file) eq q|GLOB| && -T $file ) );
	}

	$self->{'emails'} = [];

	eval {
		# Slurp the mailbox, Convert from CRLF to LF,
		#
		# mboxes
		#  mboxo	Original mbox implementation
		#  mboxcl	Content-Length field in UNIX From_ line
		#  mboxcl2	From_ in the message body is not quoted.
		#  mboxrd
		#  MMDF		No UNIX From_ line, and blank line at the end of the message body.
		# 		^A^A^A^A(4 Ctrl-As) around the message.
		#  Eudora	No blank line at the end of the message, From_ ???@???
		#  Netscape	From_ -
		@{ $self->{'emails'} } =
			map( { s{\x0d\x0a}{\n}g; y{\x0d\x0a}{\n\n}; q(From ).$_; }
				Perl6::Slurp::slurp( $file,
					{
						'irs' => qr(\nFrom ),
						'chomp' => ENDOF
					}
				)
			);

		if( scalar @{ $self->{'emails'} } )
		{
			$self->{'emails'}->[0] =~ s{\AFrom (.+)\z}{$1}s;
			$self->{'emails'}->[-1] .= ENDOF;
		}
	};

	return(0) if $@;
	$self->{'nmails'} = scalar( @{$self->{'emails'}} );
	return $self->{'nmails'};
}

sub parseit
{
	# +-+-+-+-+-+-+-+
	# |p|a|r|s|e|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Parse the email text
	# @Param <ref>	(Ref->Code) Callback function
	# @Return	(Integer) n = The number of parsed messages
	my $self = shift();
	my $call = shift() || sub {};
	my $ends = ENDOF;
	my $seek = 0;

	my $agentclasses = [ map { 'Kanadzuchi::MTA::'.$_ } @$MostFamousMTAs ];
	my $emailheaders = [ 'From', 'To', 'Date', 'Subject', 'Content-Type', 'Reply-To', 'Message-Id' ];
	my $agentheaders = [];

	# Load each agent's headers
	map { push @$agentheaders, @{ $_->emailheaders() } } @$agentclasses;
	map { push @$agentheaders, @{ $_->emailheaders() } } @$TransferAgents;


	PARSE_EMAILS: while( my $_email = shift @{$self->{'emails'}} )
	{
		my $_mail = {};
		my $_from = q();	# 'From_' of UNIX mbox
		my $_head = q();	# Message header as a string
		my $_body = q();	# Message body as a string

		# Callback(), Term::ProgressBar
		$call->();

		if( $_email =~ m{\AFrom[ ](.+?)\n(.+?)\n\n(.+)$ends\z}so )
		{
			$_from = $1;
			$_head = $2;
			$_body = $3;
		}
		elsif( $_email =~ m{\A(.+?)\n\n(.+)$ends\z}so )
		{
			# There is no UNIX From line, Insert pseudo it.
			$_from = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000);
			$_head = $1;
			$_body = $2;
		}
		else
		{
			next(PARSE_EMAILS);
		}

		# 1. Set the content in UNIX From_ Line
		$_mail->{'from'} = $_from;
		$_mail->{'head'} = { 
				'received' => [], 'subject' => q(), 'from' => q(),
				'to' => q(), 'date' => q(), 'content-type' => q(),
				'reply-to' => q(), 'message-id' => q() };

		# 2. Parse email headers
		my $__continued = 0;	# Flag; Continued from the previous line.
		my $__ehcounter = 0;	# Temporary counter for email headers

		LINES: foreach my $_ln ( split( qq{\n}, $_head ) )
		{
			HEADERS: foreach my $_eh ( @$emailheaders, @$agentheaders )
			{
				next(HEADERS) unless( $_ln =~ m{\A$_eh[:][ ]*}i );
				$_mail->{'head'}->{ lc $_eh } = $1 if( $_ln =~ m/\A${_eh}[:][ ]*(.+?)\z/i );
			}

			# Get and concatenate 'Received:' headers
			if( $_ln =~ m{\AReceived[:][ ]*(.+?)\z}i )
			{
				push( @{ $_mail->{'head'}->{'received'} }, $1 );
				$__continued = 1;
				$__ehcounter = scalar( @{ $_mail->{'head'}->{'received'} } ) - 1;
			}
			elsif( $__continued && $_ln =~ m{\A[\s\t]+(.+?)\z} )
			{
				# This line is countinued from the previous line.
				next(LINES) unless( scalar @{ $_mail->{'head'}->{'received'} } );
				$_mail->{'head'}->{'received'}->[$__ehcounter] .= q( ).$1;
			}
			else
			{
				$__continued = 0;
				$__ehcounter = 0;
			}
		}

		# 3. Rewrite the part of the message body
		$_mail->{'body'} = __PACKAGE__->breakit( $_mail, \$_body );
		$_head = q();


		# Parse message body
		# Concatenate multiple-lined headers
		next(PARSE_EMAILS) unless( $_mail->{'body'} );
		$_mail->{'body'} =~ s{^[Ff]rom:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{From: $1 $2}gm;
		$_mail->{'body'} =~ s{^[Tt]o:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{To: $1 $2}gm;
		$_mail->{'body'} =~ s{^[Dd]iagnostic-[Cc]ode:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{Diagnostic-Code: $1 $2}gm;

		# Delete non-required headers
		$_mail->{'body'} =~ y{\n}{\n}s;		# Delete blank lines
		$_mail->{'body'} =~ s{^\W.+[\r\n]}{}mg;	# Delete non-email headers

		# Parse greedy
		if( $self->{'greed'} )
		{
			# Addresser
			$_mail->{'body'} =~ s{^[Aa]pparently-[Ff]rom:[ ]*(.+)$}{<<<<: Apparently-From: $1}m;
			$_mail->{'body'} =~ s{^[Rr]esent-[Ff]rom:[ ]*(.+)$}{<<<<: Resent-From: $1}m;
			$_mail->{'body'} =~ s{^[Rr]esent-[Rr]eply-[Tt]o:[ ]*(.+)$}{<<<<: Resent-Reply-To: $1}m;
			$_mail->{'body'} =~ s{^[Rr]esent-[Ss]ender:[ ]*(.+)$}{<<<<: Resent-Sender: $1}m;
			$_mail->{'body'} =~ s{^[Ss]ender:[ ]*(.+)$}{<<<<: Sender: $1}m;

			# Recipient
			$_mail->{'body'} =~ s{^[Aa]pparently-[Tt]o:[ ]*(.+)$}{<<<<: Apparently-To: $1}m;
			$_mail->{'body'} =~ s{^[Ee]nvelope-[Tt]o:[ ]*(.+)$}{<<<<: Envelope-To: $1}m;
			$_mail->{'body'} =~ s{^[Rr]esent-[Tt]o:[ ]*(.+)$}{<<<<: Resent-To: $1}m;
			$_mail->{'body'} =~ s{^[Xx]-[Ee]nvelope-[Tt]o:[ ]*(.+)$}{<<<<: X-Envelope-To: $1}m;

			# Date
			$_mail->{'body'} =~ s{^[Pp]osted:[ ]*(.+)$}{<<<<: Posted: $1}m;
			$_mail->{'body'} =~ s{^[Pp]osted-[Dd]ate:[ ]*(.+)$}{<<<<: Posted-Date: $1}m;
			$_mail->{'body'} =~ s{^[Rr]esent-[Dd]ate:[ ]*(.+)$}{<<<<: Resent-Date: $1}m;
		}

		# Mark required headers
		$_mail->{'body'} =~ s{^[Aa]rrival-[Dd]ate:[ ]*(.+)$}{<<<<: Arrival-Date: $1}m;
		$_mail->{'body'} =~ s{^[Dd]ate:[ ]*(.+)$}{<<<<: Date: $1}gm;
		$_mail->{'body'} =~ s{^[Dd]elivered-[Tt]o:[ ]*(.+)$}{<<<<: Delivered-To: $1}m;
		$_mail->{'body'} =~ s{^[Dd]iagnostic-[Cc]ode:[ ]*(.+)$}{<<<<: Diagnostic-Code: $1}m;
		$_mail->{'body'} =~ s{^[Ee]nvelope-[Ff]rom:[ ]*(.+)$}{<<<<: Envelope-From: $1}m;
		$_mail->{'body'} =~ s{^[Ee]rrors-[Tt]o:[ ]*(.+)([;].+)?$}{<<<<: Errors-To: $1}m;
		$_mail->{'body'} =~ s{^[Ff]inal-[Rr]ecipient:[ ]*[Rr][Ff][Cc]822;[ ]*(.+)$}{<<<<: Final-Recipient: $1}m;
		$_mail->{'body'} =~ s{^[Ff]rom:[ ]*(.+)$}{<<<<: From: $1}gm;
		$_mail->{'body'} =~ s{^[Ff]orward-[Pp]ath:[ ]*(.+)$}{<<<<: Forward-Path: $1}m;
		$_mail->{'body'} =~ s{^[Ll]ast-[Aa]ttempt-[Dd]ate:[ ]*(.+)$}{<<<<: Last-Attempt-Date: $1}m;
		$_mail->{'body'} =~ s{^[Oo]riginal-[Rr]ecipient:[ ]*[Rr][Ff][Cc]822;[ ]*(.+)$}{<<<<: Original-Recipient: $1}m;
		$_mail->{'body'} =~ s{^[Rr]eply-[Tt]o:[ ]*(.+)$}{<<<<: Reply-To: $1}m;
		$_mail->{'body'} =~ s{^[Rr]eturn-[Pp]ath:[ ]*(.+)$}{<<<<: Return-Path: $1}gm;
		$_mail->{'body'} =~ s{^[Rr]everse-[Pp]ath:[ ]*(.+)$}{<<<<: Reverse-Path: $1}m;
		$_mail->{'body'} =~ s{^[Ss]tatus:[ ]*(\d[.]\d[.]\d+).*$}{<<<<: Status: $1}gm;
		$_mail->{'body'} =~ s{^[Tt]o:[ ]*(.+)$}{<<<<: To: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-[Aa]ctual-[Rr]ecipient:[ ]*[Rf][Ff][Cc]822;[ ]*(.+)$}{<<<<: X-Actual-Recipient: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-[Aa]ctual-[Rr]ecipient:[ ]*(.+)$}{<<<<: X-Actual-Recipient: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-[Pp]ostfix-[Ss]ender:[ ]*(.+)$}{<<<<: X-Postfix-Sender: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-[Ee]nvelope-[Ff]rom:[ ]*(.+)$}{<<<<: X-Envelope-From: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-SMTP-Agent:[ ]*(.+)$}{<<<<: X-SMTP-Agent: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-SMTP-Command:[ ]*(.+)$}{<<<<: X-SMTP-Command: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-SMTP-Diagnosis:[ ]*(.+)$}{<<<<: X-SMTP-Diagnosis: $1}m;
		$_mail->{'body'} =~ s{^[Xx]-SMTP-Status:[ ]*(.+)$}{<<<<: X-SMTP-Status: $1}m;

		$_mail->{'body'} =~ s{^\w.+[\r\n]}{}gm;			# Delete non-required headers
		$_mail->{'body'} =~ s{^<<<<:\s}{}gm;			# Delete the mark

		# Remove the string which includes multi-byte character
		$_mail->{'body'} =~ s{^([Dd]iagnostic-[Cc]ode:[ ]X-Notes;).+$}{$1 MULTI-BYTE CHARACTERS HAVE BEEN REMOVED.}m;

		# Missing From: header in the body part, See Kanadzuchi/Mail/Bounced.pm line 139 - 164
		unless( $_mail->{'body'} =~ m{
				^(?:From|Return-Path|Reply-To|Errors-To|Reverse-Path
					|X-Postfix-Sender|Envelope-From|X-Envelope-From
					|Resent-From|Sender|Resent-Reply-To|Apparently-From):[ ]}mx ){

			$_mail->{'body'} .= qq(\n) unless( $_mail->{'body'} =~ m{\n\z}mx );
			$_mail->{'body'} .= 'From: '.$_mail->{'head'}->{'to'}.qq(\n);
		}

		# Missing Date: header in the body part, See Kanadzuchi/Mail/Bounced.pm line 245 - 253
		unless( $_mail->{'body'} =~ m{
				^(?:Arrival-Date|Last-Attempt-Date|Date
					|Posted-Date|Posted|Resent-Date):[ ]}mx ){

			$_mail->{'body'} .= 'Date: '.$_mail->{'head'}->{'date'}.qq(\n);
		}

		push( @{ $self->{'messages'} }, {
				'from' => $_mail->{'from'},
				'head' => $_mail->{'head'},
				'body' => $_mail->{'body'}, } );

		$self->{'nmesgs'}++;

	} # End of while(PARSE_EMAILS)

	$self->{'emails'} = [];
	return $self->{'nmesgs'};
}

1;
__END__
