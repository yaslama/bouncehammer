# $Id: Bounced.pm,v 1.11 2010/04/15 08:40:16 ak Exp $
# -Id: Returned.pm,v 1.10 2010/02/17 15:32:18 ak Exp -
# -Id: Returned.pm,v 1.2 2009/08/29 19:01:18 ak Exp -
# -Id: Returned.pm,v 1.15 2009/08/21 02:44:15 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::
                                                 
 #####                                       ##  
 ##  ##  ####  ##  ## #####   #### ####      ##  
 #####  ##  ## ##  ## ##  ## ##   ##  ##  #####  
 ##  ## ##  ## ##  ## ##  ## ##   ###### ##  ##  
 ##  ## ##  ## ##  ## ##  ## ##   ##     ##  ##  
 #####   ####   ##### ##  ##  #### ####   #####  
package Kanadzuchi::Mail::Bounced;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail';
use strict;
use warnings;
use Kanadzuchi::Address;
use Kanadzuchi::RFC1893;
use Kanadzuchi::RFC2822;
use Kanadzuchi::Time;
use Time::Piece;
use MIME::Parser;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# __PACKAGE__->mk_accessors();

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub eatit
{
	# +-+-+-+-+-+
	# |e|a|t|i|t|
	# +-+-+-+-+-+
	#
	# @Description	Parse the Mailbox and find error messages
	# @Param <ref>	(Ref->H::Parser) Parsed mailbox object
	# @Param <ref>	(Ref->Hash) Configuration
	# @Return	(Ref->Array) K::M::Bounced::* objects
	my $class = shift();
	my $mailx = shift() || return([]);
	my $confx = shift();
	my $count = 0;

	my $mimeparser;			# (MIME::Parser) Parser object
	my $mimeentity;			# (MIME::Head) Header object
	my $thisobject;			# (K::M::Returned::*) Instance
	my $vmprogress;			# (Term::ProgressBar)
	my $mesgpieces = [];		# (Ref->Array) hold $thisobjects
	my $bouncemesg = {};		# (Ref->Hash) Pre-Construct headers
	my $tempheader = {};		# (Ref->Hash) Temporary headers
	my $tempstring = q();		# (String) Temporary variable for parsing
	my $tempoffset = 0;		# Timezone offset
	my $tempemails = [];		# (Ref->Array) e-Mail addresses

	# Create and configure MIME::Parser opject
	# See http://search.cpan.org/~doneill/MIME-tools-5.427/lib/MIME/Parser.pm
	$mimeparser = new MIME::Parser();
	$mimeparser->output_dir( $confx->{'cache'} || q{/tmp} );
	$mimeparser->tmp_to_core(0);
	$mimeparser->output_to_core( $confx->{'fast'} || 0 );
	$mimeparser->decode_headers(0);
	$mimeparser->extract_uuencode(0);
	$mimeparser->extract_nested_messages(0);

	# Verbose mode
	if( $confx->{'verbose'} > 0 )
	{
		eval{	require Term::ProgressBar; 
			$vmprogress = Term::ProgressBar->new({ 'fh' => \*STDERR, 
					'ETA' => q(linear), 'name' => q(Parse mailbox),
					'count' => $$mailx->nmesgs() });
		};
	}

	BUILD: foreach my $_entity ( @{$$mailx->messages} )
	{
		# Initialize for this loop
		$mimeentity = $mimeparser->parse_data( $_entity->{'body'} );
		$bouncemesg = {};
		$tempheader = {};
		$tempemails = [];
		$tempoffset = 0;
		$tempstring = q();

		# Put progress bar ...
		$vmprogress->update() if( $vmprogress );

		#  ____  _____ ____ ___ ____ ___ _____ _   _ _____ 
		# |  _ \| ____/ ___|_ _|  _ \_ _| ____| \ | |_   _|
		# | |_) |  _|| |    | || |_) | ||  _| |  \| | | |  
		# |  _ <| |__| |___ | ||  __/| || |___| |\  | | |  
		# |_| \_\_____\____|___|_|  |___|_____|_| \_| |_|  
		# 
		unless( $bouncemesg->{'recipient'} )
		{
			# Directly access to the values, more faster
			@$tempemails = grep( m{[@]},
						$mimeentity->get('X-Actual-Recipient'),
						$mimeentity->get('Final-Recipient'),
						$mimeentity->get('Original-Recipient') );
			@$tempemails = grep( m{[@]}, 
					$mimeentity->get('To'),
					$mimeentity->get('Delivered-To') ) unless( @$tempemails );

			if( $$mailx->greed() && ! @$tempemails )
			{
				# Greedily find a recipient address
				@$tempemails = grep( m{[@]}, $mimeentity->get('Envelope-To')
							 || $mimeentity->get('X-Envelope-To')
							 || $mimeentity->get('Resent-To')
							 || $mimeentity->get('Apparently-To') );
			}

			# There is no recipient address, skip.
			next(BUILD) unless( @$tempemails );
			map { $_ =~ y{[`'"()<>\r\n$]}{}d; $_ =~ s{\s}{,}g; $_ =~ s{;.+\z}{}g; } @$tempemails;

			RECIPIENTS: foreach my $_e ( @{ Kanadzuchi::Address->parse($tempemails) } )
			{
				if( Kanadzuchi::RFC2822->is_emailaddress($_e->address()) )
				{
					$tempheader->{'recipient'} = $_e;
					last();
				}
			}

			$tempheader->{'recipient'} ||= $tempheader->{'expanded'} 
							? Kanadzuchi::Address->new($tempheader->{'expanded'})
							: q();
			next(BUILD) unless( $tempheader->{'recipient'} );
			$bouncemesg->{'recipient'} = $tempheader->{'recipient'};
		}

		#     _    ____  ____  ____  _____ ____ ____  _____ ____  
		#    / \  |  _ \|  _ \|  _ \| ____/ ___/ ___|| ____|  _ \ 
		#   / _ \ | | | | | | | |_) |  _| \___ \___ \|  _| | |_) |
		#  / ___ \| |_| | |_| |  _ <| |___ ___) |__) | |___|  _ < 
		# /_/   \_\____/|____/|_| \_\_____|____/____/|_____|_| \_\
		# 
		# From, Reply-To, Return-Path, and Sender
		unless( $bouncemesg->{'addresser'} )
		{
			my( $_a, $_e, $_m );

			# Directly access to the values, more faster
			@$tempemails = grep( m{[@]}, 
						$mimeentity->get('From'),
						$mimeentity->get('Return-Path'),
						$mimeentity->get('Reply-To') );
			unless( @$tempemails )
			{
				# There is neither From: nor Reply-To: header.
				@$tempemails = grep( m{[@]}, 
							$mimeentity->get('Errors-To'),
							$mimeentity->get('X-Postfix-Sender'),
							$mimeentity->get('Envelope-From'),
							$mimeentity->get('X-Envelope-From') );

				# Greedily find an addresser.
				@$tempemails = grep( m{[@]}, $mimeentity->get('Resent-From')
							 || $mimeentity->get('Sender')
							 || $mimeentity->get('Resent-Reply-To')
							 || $mimeentity->get('Apparently-From')
						) if( ! @$tempemails && $$mailx->greed() );
			}

			next(BUILD) unless( @$tempemails );
			map { $_ =~ y{[`'"()<>\r\n$]}{}d; $_ =~ s{\s}{,}g; $_ =~ s{;.+\z}{}g; } @$tempemails;


			ADDRESSER: foreach my $_e ( @{ Kanadzuchi::Address->parse($tempemails) } )
			{
				if( Kanadzuchi::RFC2822->is_emailaddress($_e->address()) )
				{
					next() if( $_e->address() eq $bouncemesg->{'recipient'}->address() );
					next() if( Kanadzuchi::RFC2822->is_mailerdaemon($_e->address()) );

					if( Kanadzuchi::RFC2822->is_subaddress($_e->address()) )
					{
						$tempheader->{'subaddress'} = $_e;
						next();
					}

					$tempheader->{'addresser'} = $_e;
				}
			}

			$tempheader->{'addresser'} ||= $tempheader->{'subaddress'};
			$tempheader->{'expanded'} = Kanadzuchi::RFC2822->expand_subaddress($tempheader->{'subaddress'});
			next(BUILD) unless( $tempheader->{'addresser'} );
			$bouncemesg->{'addresser'} = $tempheader->{'addresser'};
		}

		#  ____ _____  _  _____ _   _ ____  
		# / ___|_   _|/ \|_   _| | | / ___| 
		# \___ \ | | / _ \ | | | | | \___ \ 
		#  ___) || |/ ___ \| | | |_| |___) |
		# |____/ |_/_/   \_\_|  \___/|____/ 
		#
		unless( $bouncemesg->{'deliverystatus'} )
		{
			$tempheader->{'deliverystatus'} = $mimeentity->get('Status') || next();

			# Convert from (string)'5.1.2' to (int)512;
			$tempheader->{'deliverystatus'} =~ y{[0-9]}{}dc;
			next() unless( $tempheader->{'deliverystatus'} );
			$bouncemesg->{'deliverystatus'} = int($tempheader->{'deliverystatus'});
		}


		#  ____ ___    _    ____ _   _  ___  ____ _____ ___ ____ 
		# |  _ \_ _|  / \  / ___| \ | |/ _ \/ ___|_   _|_ _/ ___|
		# | | | | |  / _ \| |  _|  \| | | | \___ \ | |  | | |    
		# | |_| | | / ___ \ |_| | |\  | |_| |___) || |  | | |___ 
		# |____/___/_/   \_\____|_| \_|\___/|____/ |_| |___\____|
		#
		unless( $bouncemesg->{'diagnosticcode'} )
		{
			# Access via MIME::Parser->head->get()
			$tempheader->{'diagnosticcode'} =  $mimeentity->get('Diagnostic-Code') || q{};
			$tempheader->{'diagnosticcode'} =~ y{[`"'\r\n]}{}d;	# Drop quotation marks and CR/LF
			$tempheader->{'diagnosticcode'} =~ y{[ ]}{}s;		# Squeeze spaces
			chomp($tempheader->{'diagnosticcode'});

			$bouncemesg->{'diagnosticcode'} = $tempheader->{'diagnosticcode'};
		}

		#  ____    _  _____ _____ 
		# |  _ \  / \|_   _| ____|
		# | | | |/ _ \ | | |  _|  
		# | |_| / ___ \| | | |___ 
		# |____/_/   \_\_| |_____|
		#
		# Arrival-Date, Last-Attempt-Date, and Date
		unless( $bouncemesg->{'arrivaldate'} )
		{
			# Access via MIME::Parser->head->get()
			 $tempheader->{'arrivaldate'} = $mimeentity->get('Arrival-Date')
							|| $mimeentity->get('Last-Attempt-Date')
							|| $mimeentity->get('Date')
							|| $mimeentity->get('Posted-Date')
							|| $mimeentity->get('Posted')
							|| $mimeentity->get('Resent-Date')
							|| q();
			next() unless( $tempheader->{'arrivaldate'} );
			chomp($tempheader->{'arrivaldate'});

			# Check strange Date header
			if( $tempheader->{'arrivaldate'} =~ m{\A\s*(\d{2}\s*[A-Z][a-z]{2}\s*\d{4}\s*.+\z)} )
			{
				# qmail's Date header, 'Date: 29 Apr 2009 01:39:00 -0000'
				$tempheader->{'arrivaldate'} = q(Thu, ).$tempheader->{'arrivaldate'};
			}

			if( $tempheader->{'arrivaldate'} =~ m{\A\s*(.+)\s*([-+]\d{4}).*\z} )
			{
				# Convert from the time zone offset to the second
				#   - Date: Tue, 21 Apr 2009 10:01:06 +0900
				#   - Date: Mon, 13 Apr 2009 18:06:03 -0400
				#   - Date: Tue, 28 Apr 2009 00:18:18 -0700 (PDT)
				#
				$bouncemesg->{'arrivaldate'} = $1;	# Tue, 28 Apr 2009 00:18:18
				$bouncemesg->{'timezoneoffset'} = $2;
				$tempoffset = Kanadzuchi::Time->tz2second($bouncemesg->{'timezoneoffset'});
				$bouncemesg->{'arrivaldate'} =~ s{[ ]+\z}{}g;
				chomp($bouncemesg->{'arrivaldate'});
			}
			else
			{
				next(BUILD);	# Invalid Date format
			}
		}

		#     _    ____ _____ ___ ___  _   _ 
		#    / \  / ___|_   _|_ _/ _ \| \ | |
		#   / _ \| |     | |  | | | | |  \| |
		#  / ___ \ |___  | |  | | |_| | |\  |
		# /_/   \_\____| |_| |___\___/|_| \_|
		#
		unless( $bouncemesg->{'action'} )
		{
			$tempstring = $mimeentity->get('Action') || q{Failed};
			chomp($tempstring);
			next(BUILD) unless( lc($tempstring) eq q{failed} );
		}

		#   ___  ____      _ _____ ____ _____ 
		#  / _ \| __ )    | | ____/ ___|_   _|
		# | | | |  _ \ _  | |  _|| |     | |  
		# | |_| | |_) | |_| | |__| |___  | |  
		#  \___/|____/ \___/|_____\____| |_|  
		#
		# Set hash values to the object.
		# Keys: rcpt,send,date, and stat are required to processing.
		next() if( $bouncemesg->{'addresser'}->address =~ m{[@]localhost.localdomain\z} );
		eval{ $tempstring = Time::Piece->strptime( $bouncemesg->{'arrivaldate'}, q{%a, %d %b %Y %T} ); };

		$thisobject = __PACKAGE__->new(
				'addresser' => $bouncemesg->{'addresser'},
				'recipient' => $bouncemesg->{'recipient'},
				'deliverystatus' => $bouncemesg->{'deliverystatus'},
				'diagnosticcode' => $bouncemesg->{'diagnosticcode'},
				'timezoneoffset' => $bouncemesg->{'timezoneoffset'},
				'bounced' => int( $tempstring->epoch() - $tempoffset ),
			);

		$thisobject->{'reason'} = $thisobject->tellmewhy();

		if( grep( { $_ == 1 } values( %{$confx->{'skip'}} ) ) )
		{
			next() if( $confx->{'skip'}->{ $thisobject->{'reason'} } );
			next() if( $confx->{'skip'}->{'norelaying' } && ( $thisobject->is_norelaying() ) );
			next() if( $confx->{'skip'}->{'temperror' } && ( $thisobject->is_temperror() ) );
		}

		push( @$mesgpieces, $thisobject );

	}
	continue
	{
		# Flush the message entity
		$$mailx->messages->[ $count++ ] = {};

	} # End of foreach() BUILD 

	return($mesgpieces);
}

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||P |||u |||b |||l |||i |||c |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub tellmewhy
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|e|l|l|m|e|w|h|y|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get a reason string
	# @Param	<None>
	# @Return	(String) Reason
	# @See		t_reasons table
	my $self = shift();
	my $rwhy = undef();

	if(    $self->is_userunknown()   ){ $rwhy = 'userunknown'; }
	elsif( $self->is_filtered()      ){ $rwhy = 'filtered'; }
	elsif( $self->is_hostunknown()   ){ $rwhy = 'hostunknown'; }
	elsif( $self->is_mailboxfull()   ){ $rwhy = 'mailboxfull'; }
	elsif( $self->is_toobigmesg()    ){ $rwhy = 'mesgtoobig'; }
	elsif( $self->is_exceedlimit()   ){ $rwhy = 'exceedlimit'; }
	elsif( $self->is_securityerror() ){ $rwhy = 'securityerr'; }
	elsif( $self->is_mailererror()   ){ $rwhy = 'mailererror'; }
	elsif( $self->is_onhold()        ){ $rwhy = 'onhold'; }
	else{ $rwhy = $self->is_somethingelse() ? $self->{'reason'} : 'undefined'; }
	return($rwhy);
}

sub is_filtered
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|f|i|l|t|e|r|e|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Bounced by domain(addr) filter?
	# @Param	<None>
	# @Return	(Integer) 1 = is filtered recipient
	#		(Integer) 0 = is not filtered recipient.
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'filtered';
	my $isfi = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			$isfi = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isfi = 1;
		}
		else
		{
			eval { use Kanadzuchi::Mail::Why::Filtered; };
			my $flib = q|Kanadzuchi::Mail::Why::Filtered|;

			if( $stat == 513 || $flib->is_included($self->{diagnosticcode}) )
			{
				# PC/spam filter
				#   Status: 5.1.3
				#   Diagnostic-Code: SMTP; 553 sorry, that domain isn't in my list of allowed rcpthosts (#5.7.1)
				#   Diagnostic-Code: SMTP; 553 sorry, your don't authenticate or 
				#                    the domain isn't in my list of allowed rcpthosts(#5.7.1)
				$isfi = 1;
			}
		}
	}
	return($isfi);
}

sub is_userunknown
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|u|s|e|r|u|n|k|n|o|w|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether addr is unknown or not
	# @Param	<None>
	# @Return	(Integer) 1 = is unknown user
	#		(Integer) 0 = is not unknown user.
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'userunknown';
	my $isuu = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isuu = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		my $uclass = q|Kanadzuchi::Mail::Why::UserUnknown|;
		my $rclass = q|Kanadzuchi::Mail::Why::RelayingDenied|;
		my $dicode = $self->{'diagnosticcode'};

		eval {
			use Kanadzuchi::Mail::Why::UserUnknown; 
			use Kanadzuchi::Mail::Why::RelayingDenied; 
		};

		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# *.1.1 = 'Bad destination mailbox address'
			#   Status: 5.1.1
			#   Diagnostic-Code: SMTP; 550 5.1.1 <***@example.jp>:
			#     Recipient address rejected: User unknown in local recipient table
			$isuu = 1 unless( $rclass->is_included($dicode) );
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isuu = 1 unless( $rclass->is_included($dicode) );
		}
		else
		{
			if( int( $stat / 100 ) == 5 )
			{
				$isuu = 1 if( $uclass->is_included($dicode) );
			}
			elsif( int( $stat / 100 ) == 4 )
			{
				# Postfix Virtual Mail box
				# Status: 4.4.7
				# Diagnostic-Code: SMTP; 450 4.1.1 <***@example.jp>:
				#   Recipient address rejected: User unknown in virtual mailbox table
				$isuu = 1 if( $uclass->is_included($dicode) );
			}
		}
	}
	return($isuu);
}

sub is_hostunknown
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|h|o|s|t|u|n|k|n|o|w|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether the host is unknown or not
	# @Param	<None>
	# @Return	(Integer) 1 = is unknown host 
	#		(Integer) 0 = is not unknown host.
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'hostunknown';
	my $ishu = 0;

	if( defined($self->{reason}) && length($self->{reason}) )
	{
		$ishu = 1 if( $self->{reason} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# Status: 5.1.2
			# Diagnostic-Code: SMTP; 550 Host unknown
			$ishu = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$ishu = 1;
		}
		else
		{
			my $hclass = q|Kanadzuchi::Mail::Why::HostUnknown|;
			my $dicode = $self->{'diagnosticcode'};

			eval { use Kanadzuchi::Mail::Why::HostUnknown; };
			$ishu = 1 if( $hclass->is_included($dicode) );
		}
	}
	return($ishu);
}

sub is_mailboxfull
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|m|a|i|l|b|o|x|f|u|l|l|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether mailbox is full or not
	# @Param	<None>
	# @Return	(Integer) 1 = User's mailbox is full
	#		(Integer) 0 = Mailbox is not full
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'mailboxfull';
	my $ismf = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		foreach my $c ( 'temporary', 'permanent' )
		{
			if( $stat == Kanadzuchi::RFC1893->standardcode($subj,$c) )
			{
				# Status: 4.2.2
				# Diagnostic-Code: SMTP; 450 4.2.2 <***@example.jp>... Mailbox Full
				$ismf = 1;
				last();
			}
			elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj,$c) )
			{
				$ismf = 1;
				last();
			}
		}

		if( $ismf == 0 )
		{
			my $mclass = q|Kanadzuchi::Mail::Why::MailboxFull|;
			my $dicode = $self->{'diagnosticcode'};
			eval { use Kanadzuchi::Mail::Why::MailboxFull; };

			$ismf = 1 if( $mclass->is_included($dicode) );
		}
	}
	return($ismf);
}

sub is_exceedlimit
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|e|x|c|e|e|d|l|i|m|i|t|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	exceed limit or not
	# @Param	<None>
	# @Return	(Integer) 1 = The message size exceeds limit
	#		(Integer) 0 = is not
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'exceedlimit';
	my $isxl = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isxl = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# Status: 5.2.3
			# Diagnostic-Code: SMTP; 552 5.2.3 Message size exceeds fixed maximum message size
			$isxl = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isxl = 1;
		}
		else
		{
			my $bclass = q|Kanadzuchi::Mail::Why::ExceedLimit|;
			my $dicode = $self->{'diagnosticcode'};
			eval { use Kanadzuchi::Mail::Why::ExceedLimit; };

			$isxl = 1 if( $bclass->is_included($dicode) );
		}
	}
	return($isxl);
}

sub is_toobigmesg
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|t|o|o|b|i|g|m|e|s|g|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether the message is too big or not
	# @Param	<None>
	# @Return	(Integer) 1 = Message is too big
	#		(Integer) 0 = is not
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'mesgtoobig';
	my $istb = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$istb = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# Status: 5.3.4
			# Diagnostic-Code: SMTP; 552 5.3.4 Error: message file too big
			$istb = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$istb = 1;
		}
		else
		{
			my $bclass = q|Kanadzuchi::Mail::Why::TooBig|;
			my $dicode = $self->{'diagnosticcode'};
			eval { use Kanadzuchi::Mail::Why::TooBig; };

			$istb = 1 if( $bclass->is_included($dicode) );
		}
	}
	return($istb);
}

sub is_norelaying
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|n|o|r|e|l|a|y|i|n|g|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether the message is rejected by 'Relaying denied'
	# @Param	<None>
	# @Return	(Integer) 1 = Relaying denied
	#		(Integer) 0 = is not
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $isnr = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		return(0) if( $self->{'reason'} ne 'securityerr' && $self->{'reason'} ne 'undefined' );
	}

	my $rclass = q|Kanadzuchi::Mail::Why::RelayingDenied|;
	my $dicode = $self->{'diagnosticcode'};

	eval { use Kanadzuchi::Mail::Why::RelayingDenied; };

	$isnr = 1 if( $rclass->is_included($dicode) );
	return($isnr);
}

sub is_securityerror
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|s|e|c|u|r|i|t|y|e|r|r|o|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether the message is returned by security error
	# @Param	<None>
	# @Return	(Integer) 1 = Is returned by security error
	#		(Integer) 0 = is not
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'securityerr';
	my $isse = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isse = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( (int($stat/10) * 10) == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			$isse = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isse = 1;
		}
	}
	return($isse);
}

sub is_mailererror
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|m|a|i|l|e|r|e|r|r|o|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether the message is returned by unknown mailer error
	# @Param	<None>
	# @Return	(Integer) 1 = Is returned by unknown mailer error
	#		(Integer) 0 = is not
	# @See		http://www.ietf.org/rfc/rfc2822.txt
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $diag = $self->{'diagnosticcode'} || q();
	my $subj = 'mailererror';
	my $isme = 0;
	my $rxme = qr{x[-]unix[;][ ]\d{1,3}};

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isme = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) && lc($diag) =~ $rxme )
		{
			$isme = 1;
		}
	}
	return($isme);
}

sub is_somethingelse
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|s|o|m|e|t|h|i|n|g|e|l|s|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Reason is something else?
	# @Param	<None>
	# @Return	(Integer) 1 = Something else
	#		(Integer) 0 = Unknown reason...
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $diag = q();
	my $else = q();
	return(1) if( $self->{'reason'} );

	foreach my $c ( 'temporary', 'permanent' )
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode('hasmoved',$c) ||
			$stat == Kanadzuchi::RFC1893->internalcode('hasmoved',$c) ){

			$else = 'hasmoved';
			$diag = 'Mailbox has moved';
			last();
		}
		elsif( $stat == Kanadzuchi::RFC1893->standardcode('systemfull',$c) ||
			$stat == Kanadzuchi::RFC1893->internalcode('systemfull',$c) ){

			$else = 'systemfull';
			$diag = 'Mail system full';
			last();
		}
	}

	unless($else)
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode('notaccept') ||
			$stat == Kanadzuchi::RFC1893->internalcode('notaccept') ){

			$else = 'notaccept';
			$diag = 'System not accepting network messages';
		}
		elsif( $stat == 547 || $stat == 447 )
		{
			$diag = 'Delivery time expired';
		}
	}

	$self->{'reason'} ||= $else;
	$self->{'description'}->{'diagnosticcode'} ||= $diag;

	return(1) if( $self->{'reason'} );
	return(0);
}

sub is_onhold
{
	# +-+-+-+-+-+-+-+-+-+
	# |i|s|_|o|n|h|o|l|d|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Status: 5.9.9 is on hold
	# @Param	<None>
	# @Return	(Integer) 1 = The reason is on hold
	#		(Integer) 0 = is not
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'onhold';

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		return(1) if( $self->{'reason'} eq $subj );
	}

	return(1) if( $stat == Kanadzuchi::RFC1893->standardcode($subj) );
	return(0);
}

sub is_permerror
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|p|e|r|m|e|r|r|o|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether it is permanent error or not
	# @Param	<None>
	# @Returns	(Integer) 1 = is permanent error message
	#		(Integer) 0 = is NOT permanent error message
	my $self = shift();
	return(0) if( ! defined($self->{'deliverystatus'}) );
	return(1) if( int($self->{'deliverystatus'} / 100 ) == 5 );
	return(0);
}

sub is_temperror
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|t|e|m|p|e|r|r|o|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	 Whether it is temporary error or not
	# @Param	<None>
	# @Returns	(Integer) 1 = is Temporary error message
	#		(Integer) 0 = is NOT temp error message
	my $self = shift();
	return(0) if( ! defined($self->{'deliverystatus'}) );
	return(1) if( int($self->{'deliverystatus'} / 100 ) == 4 );
	return(0);
}

1;
__END__
