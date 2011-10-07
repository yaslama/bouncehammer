# $Id: Bounced.pm,v 1.30.2.3 2011/10/07 06:23:15 ak Exp $
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
use Kanadzuchi::RFC2822;
use Kanadzuchi::RFC3463;
use Kanadzuchi::Iterator;
use Kanadzuchi::MIME::Parser;
use Kanadzuchi::Time;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'smtpcommand',		# (String) SMTP Command which returns error
);

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
	# @Param <ref>	(Kanadzuchi::Mbox) Parsed mailbox object
	# @Param <ref>	(Ref->Hash) Configuration
	# @Param <ref>	(Ref->Code) Callback code for each loop
	# @Return	(Ref->Array) K::M::Bounced::* objects
	my $class = shift();
	my $mailx = shift() || return Kanadzuchi::Iterator->new();
	my $confx = shift() || { 'verbose' => 0 };
	my $callb = shift() || sub { };
	my $count = 0;

	my $mimeparser;			# (Kanadzuchi::MIME::Parser) Parser object
	my $thisobject;			# (K::M::Returned::*) Instance
	my $mesgpieces = [];		# (Ref->Array) hold $thisobjects
	my $bouncemesg = {};		# (Ref->Hash) Pre-Construct headers

	return Kanadzuchi::Iterator->new() unless( ref($mailx) eq q|Kanadzuchi::Mbox| );
	$mimeparser = new Kanadzuchi::MIME::Parser();

	MIMEPARSER: while( my $_entity = shift @{$mailx->messages} )
	{
		my $tempheader = {};		# (Ref->Hash) Temporary headers
		my $tempemails = [];		# (Ref->Array) e-Mail addresses
		my $tempstring = q();		# (String) Temporary variable for parsing
		my $tempoffset = 0;		# Timezone offset

		# Initialize for this loop
		$mimeparser->parseit( \$_entity->{'body'} );
		next() unless $mimeparser->count();
		$bouncemesg = {};
		$callb->();

		#  ____  _____ ____ ___ ____ ___ _____ _   _ _____ 
		# |  _ \| ____/ ___|_ _|  _ \_ _| ____| \ | |_   _|
		# | |_) |  _|| |    | || |_) | ||  _| |  \| | | |  
		# |  _ <| |__| |___ | ||  __/| || |___| |\  | | |  
		# |_| \_\_____\____|___|_|  |___|_____|_| \_| |_|  
		# 
		unless( $bouncemesg->{'recipient'} )
		{
			# Directly access to the values, more faster
			#  Final-Recipient: RFC822; @example.jp ... local-part?
			@$tempemails = grep( m{\A[^@].*[@].+\z},
						$mimeparser->getit('X-SMTP-Recipient'),
						$mimeparser->getit('X-Actual-Recipient'),
						$mimeparser->getit('Final-Recipient'),
						$mimeparser->getit('Original-Recipient') );
			@$tempemails = grep( m{\A[^@].*[@].+\z}, 
					$mimeparser->getit('To'),
					$mimeparser->getit('Delivered-To'),
					$mimeparser->getit('Forward-Path') ) unless( @$tempemails );

			if( $mailx->greed() && ! @$tempemails )
			{
				# Greedily find a recipient address
				@$tempemails = grep( m{\A[^@].*[@].+\z}, $mimeparser->getit('Envelope-To')
							 || $mimeparser->getit('X-Envelope-To')
							 || $mimeparser->getit('Resent-To')
							 || $mimeparser->getit('Apparently-To') );
			}

			# There is no recipient address, skip.
			next(MIMEPARSER) unless @$tempemails;
			map { $_ = Kanadzuchi::Address->canonify($_) } @$tempemails;

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
			next(MIMEPARSER) unless $tempheader->{'recipient'};
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
			@$tempemails = grep( m{\A[^@].*[@].+\z}, 
						$mimeparser->getit('From'),
						$mimeparser->getit('Return-Path'),
						$mimeparser->getit('Reply-To') );
			unless( @$tempemails )
			{
				# There is neither From: nor Reply-To: header.
				@$tempemails = grep( m{\A[^@].*[@].+\z}, 
							$mimeparser->getit('Errors-To'),
							$mimeparser->getit('Reverse-Path'),
							$mimeparser->getit('X-Postfix-Sender'),
							$mimeparser->getit('Envelope-From'),
							$mimeparser->getit('X-Envelope-From') );

				# Greedily find an addresser.
				@$tempemails = grep( m{\A[^@].*[@].+\z}, $mimeparser->getit('Resent-From')
							 || $mimeparser->getit('Sender')
							 || $mimeparser->getit('Resent-Reply-To')
							 || $mimeparser->getit('Apparently-From')
						) if( ! @$tempemails && $mailx->greed() );
			}

			next(MIMEPARSER) unless @$tempemails;
			map { $_ = Kanadzuchi::Address->canonify($_) } @$tempemails;

			ADDRESSER: foreach my $_e ( @{ Kanadzuchi::Address->parse($tempemails) } )
			{
				if( Kanadzuchi::RFC2822->is_emailaddress($_e->address()) )
				{
					# Skip if the addresser equals the recipient
					#next() if( $_e->address() eq $bouncemesg->{'recipient'}->address() );
					next() if( Kanadzuchi::RFC2822->is_mailerdaemon($_e->address()) );

					if( Kanadzuchi::RFC2822->is_subaddress($_e->address()) )
					{
						$tempheader->{'subaddress'} = $_e;
						next();
					}

					$tempheader->{'addresser'} = $_e;
					last();
				}
			}

			$tempheader->{'addresser'} ||= $tempheader->{'subaddress'};
			$tempheader->{'expanded'} = Kanadzuchi::RFC2822->expand_subaddress($tempheader->{'subaddress'});
			next(MIMEPARSER) unless $tempheader->{'addresser'};
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
			my $_status = {
				'alt' => $mimeparser->getit('X-SMTP-Status') || q(),
				'org' => $mimeparser->getit('Status') || q() };

			next() if( ! $_status->{'org'} && ! $_status->{'alt'} );

			if( $_status->{'alt'} eq Kanadzuchi::RFC3463->status('undefined','p','i') )
			{
				$tempheader->{'deliverystatus'} = $_status->{'org'} || $_status->{'alt'};
			}
			elsif( $_status->{'alt'} eq q() )
			{
				$tempheader->{'deliverystatus'} = $_status->{'org'};
			}
			else
			{
				if( $_status->{'org'} =~ m{\A[45][.]0[.]0} )
				{
					$tempheader->{'deliverystatus'} = $_status->{'alt'} || $_status->{'org'};
				}
				else
				{
					$tempheader->{'deliverystatus'} = $_status->{'org'} || $_status->{'alt'};
				}
			}

			$tempheader->{'deliverystatus'} =~ s{\A\s*([45][.]\d[.]\d+).*\z}{$1};
			next() unless( $tempheader->{'deliverystatus'} );
			$bouncemesg->{'deliverystatus'} = $tempheader->{'deliverystatus'};
		}

		#  ____ ___    _    ____ _   _  ___  ____ _____ ___ ____ 
		# |  _ \_ _|  / \  / ___| \ | |/ _ \/ ___|_   _|_ _/ ___|
		# | | | | |  / _ \| |  _|  \| | | | \___ \ | |  | | |    
		# | |_| | | / ___ \ |_| | |\  | |_| |___) || |  | | |___ 
		# |____/___/_/   \_\____|_| \_|\___/|____/ |_| |___\____|
		#
		unless( $bouncemesg->{'diagnosticcode'} )
		{
			$tempheader->{'diagnosticcode'} =  $mimeparser->getit('Diagnostic-Code')
							|| $mimeparser->getit('X-SMTP-Diagnosis') || q();
			$tempheader->{'diagnosticcode'} =~ y{`"'\r\n}{}d;	# Drop quotation marks and CR/LF
			$tempheader->{'diagnosticcode'} =~ y{ }{}s;		# Squeeze spaces

			chomp $tempheader->{'diagnosticcode'};
			$bouncemesg->{'diagnosticcode'} = $tempheader->{'diagnosticcode'};
		}

		# __  __    ____  __  __ _____ ____            
		# \ \/ /   / ___||  \/  |_   _|  _ \     __/\__
		#  \  /____\___ \| |\/| | | | | |_) |____\    /
		#  /  \_____|__) | |  | | | | |  __/_____/_  _\
		# /_/\_\   |____/|_|  |_| |_| |_|          \/  
		#                                              
		$bouncemesg->{'smtpcommand'} = 
			($mimeparser->getit('X-SMTP-Command') || q()) unless( $bouncemesg->{'smtpcommand'} );
		$bouncemesg->{'smtpagent'} = 
			($mimeparser->getit('X-SMTP-Agent') || q()) unless( $bouncemesg->{'smtpagent'} );

		#  ____    _  _____ _____ 
		# |  _ \  / \|_   _| ____|
		# | | | |/ _ \ | | |  _|  
		# | |_| / ___ \| | | |___ 
		# |____/_/   \_\_| |_____|
		#
		# Arrival-Date, Last-Attempt-Date, and Date
		unless( $bouncemesg->{'arrivaldate'} )
		{
			 $tempheader->{'arrivaldate'} = $mimeparser->getit('Arrival-Date')
							|| $mimeparser->getit('Last-Attempt-Date')
							|| $mimeparser->getit('Date')
							|| $mimeparser->getit('Posted-Date')
							|| $mimeparser->getit('Posted')
							|| $mimeparser->getit('Resent-Date')
							|| q();
			next() unless $tempheader->{'arrivaldate'};
			chomp $tempheader->{'arrivaldate'};

			$bouncemesg->{'arrivaldate'} = Kanadzuchi::Time->canonify( $tempheader->{'arrivaldate'} );
			if( $bouncemesg->{'arrivaldate'} =~ m{\A(.+)\s+([-+]\d{4})\z} )
			{
				$bouncemesg->{'arrivaldate'} = $1;
				$bouncemesg->{'timezoneoffset'} = $2;
				$tempoffset = Kanadzuchi::Time->tz2second($2);
			}
			else
			{
				next();
			}
		}

		#   ___  ____      _ _____ ____ _____ 
		#  / _ \| __ )    | | ____/ ___|_   _|
		# | | | |  _ \ _  | |  _|| |     | |  
		# | |_| | |_) | |_| | |__| |___  | |  
		#  \___/|____/ \___/|_____\____| |_|  
		#
		# Set hash values to the object.
		# Keys: rcpt,send,date, and stat are required to processing.
		next() if( $bouncemesg->{'addresser'}->address =~ m{[@]localhost[.]localdomain\z} );

		eval{ $tempstring = Time::Piece->strptime( $bouncemesg->{'arrivaldate'}, q{%a, %d %b %Y %T} ); };
		# bouncehammer stops with the following message if the time format is invalid
		# Error parsing time at /usr/local/lib/perl5/5.10.0/darwin-thread-multi-2level/Time/Piece.pm line 471.
		# $tempstring = Time::Piece->new() unless( ref($tempstring) eq q|Time::Piece| );
		next() if( $@ && ref $tempstring ne q|Time::Piece| );

		$thisobject = __PACKAGE__->new(
				'addresser' => $bouncemesg->{'addresser'},
				'recipient' => $bouncemesg->{'recipient'},
				'smtpagent' => $bouncemesg->{'smtpagent'},
				'smtpcommand' => $bouncemesg->{'smtpcommand'},
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

	} # End of while(MIMEPARSER)

	return Kanadzuchi::Iterator->new($mesgpieces);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
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
	elsif( $self->is_rejected()      ){ $rwhy = 'rejected'; }
	elsif( $self->is_hostunknown()   ){ $rwhy = 'hostunknown'; }
	elsif( $self->is_mailboxfull()   ){ $rwhy = 'mailboxfull'; }
	elsif( $self->is_toobigmesg()    ){ $rwhy = 'mesgtoobig'; }
	elsif( $self->is_exceedlimit()   ){ $rwhy = 'exceedlimit'; }
	elsif( $self->is_onhold()        ){ $rwhy = 'onhold'; }
	else{  $rwhy = $self->is_somethingelse() ? $self->{'reason'} : 'undefined'; }
	return $rwhy;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'userunknown';
	my $isuu = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isuu = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		my $uclass = q|Kanadzuchi::Mail::Why::UserUnknown|;
		my $rclass = q|Kanadzuchi::Mail::Why::RelayingDenied|;
		my $nclass = q|Kanadzuchi::Mail::Why::NotAccept|;
		my $dicode = $self->{'diagnosticcode'};

		eval {
			require Kanadzuchi::Mail::Why::UserUnknown; 
			require Kanadzuchi::Mail::Why::RelayingDenied; 
			require Kanadzuchi::Mail::Why::NotAccept; 
		};

		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# *.1.1 = 'Bad destination mailbox address'
			#   Status: 5.1.1
			#   Diagnostic-Code: SMTP; 550 5.1.1 <***@example.jp>:
			#     Recipient address rejected: User unknown in local recipient table
			if( $rclass->textumhabet($dicode) || $nclass->textumhabet($dicode) )
			{
				$isuu = 0;
			}
			else
			{
				$isuu = 1;
			}
		}
		else
		{
			if( $self->{'smtpcommand'} eq 'RCPT' )
			{
				if( substr($stat,0,1) == 5 )
				{
					$isuu = 1 if( $uclass->textumhabet($dicode) );
				}
				elsif( substr($stat,0,1) == 4 )
				{
					# Postfix Virtual Mail box
					# Status: 4.4.7
					# Diagnostic-Code: SMTP; 450 4.1.1 <***@example.jp>:
					#   Recipient address rejected: User unknown in virtual mailbox table
					$isuu = 1 if( $uclass->textumhabet($dicode) );
				}
			}
		}
	}

	return $isuu;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'hostunknown';
	my $ishu = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$ishu = 1 if( $self->{reason} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# Status: 5.1.2
			# Diagnostic-Code: SMTP; 550 Host unknown
			$ishu = 1;
		}
		else
		{
			my $hclass = q|Kanadzuchi::Mail::Why::HostUnknown|;
			my $dicode = $self->{'diagnosticcode'};

			eval { require Kanadzuchi::Mail::Why::HostUnknown; };
			$ishu = 1 if( $hclass->textumhabet($dicode) );
		}
	}
	return $ishu;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'filtered';
	my $isfi = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$isfi = 1;
		}
		else
		{
			if( $self->{'smtpcommand'} eq 'DATA' )
			{
				my $uclass = q|Kanadzuchi::Mail::Why::UserUnknown|;
				my $fclass = q|Kanadzuchi::Mail::Why::Filtered|;
				eval { 
					require Kanadzuchi::Mail::Why::UserUnknown;
					require Kanadzuchi::Mail::Why::Filtered;
				};
				$isfi = 1 if( $fclass->textumhabet($self->{'diagnosticcode'})
						|| $uclass->textumhabet($self->{'diagnosticcode'}) );
			}
		}
	}

	return $isfi;
}

sub is_rejected
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|r|e|j|e|c|t|e|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Bounced by sender address
	# @Param	<None>
	# @Return	(Integer) 1 = is rejected
	#		(Integer) 0 = is not rejected by sender.
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'rejected';
	my $isrj = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isrj = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$isrj = 1;
		}
		else
		{
			if( $self->{'smtpcommand'} eq 'MAIL' )
			{
				eval { require Kanadzuchi::Mail::Why::Rejected; };
				my $rlib = q|Kanadzuchi::Mail::Why::Rejected|;

				$isrj = 1 if $rlib->textumhabet($self->{'diagnosticcode'});
			}
		}
	}

	return $isrj;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'mailboxfull';
	my $ismf = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# Status: 4.2.2
			# Diagnostic-Code: SMTP; 450 4.2.2 <***@example.jp>... Mailbox Full
			$ismf = 1;
		}
		else
		{
			my $mclass = q|Kanadzuchi::Mail::Why::MailboxFull|;
			my $dicode = $self->{'diagnosticcode'};
			eval { require Kanadzuchi::Mail::Why::MailboxFull; };

			$ismf = 1 if( $mclass->textumhabet($dicode) );
		}
	}
	return $ismf;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'exceedlimit';
	my $isxl = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isxl = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# Status: 5.2.3
			# Diagnostic-Code: SMTP; 552 5.2.3 Message size exceeds fixed maximum message size
			$isxl = 1;
		}
		else
		{
			my $bclass = q|Kanadzuchi::Mail::Why::ExceedLimit|;
			my $dicode = $self->{'diagnosticcode'};
			eval { require Kanadzuchi::Mail::Why::ExceedLimit; };

			$isxl = 1 if( $bclass->textumhabet($dicode) );
		}
	}
	return $isxl;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'mesgtoobig';
	my $istb = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$istb = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# Status: 5.3.4
			# Diagnostic-Code: SMTP; 552 5.3.4 Error: message file too big
			$istb = 1;
		}
		else
		{
			my $bclass = q|Kanadzuchi::Mail::Why::MesgTooBig|;
			my $dicode = $self->{'diagnosticcode'};
			eval { require Kanadzuchi::Mail::Why::MesgTooBig; };

			$istb = 1 if( $bclass->textumhabet($dicode) );
		}
	}
	return $istb;
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

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		return 0 if( $self->{'reason'} !~ m{\A(?:securityerr|systemerror|undefined)\z} );
	}

	my $rclass = q|Kanadzuchi::Mail::Why::RelayingDenied|;
	my $dicode = $self->{'diagnosticcode'};

	eval { use Kanadzuchi::Mail::Why::RelayingDenied; };

	$isnr = 1 if( $rclass->textumhabet($dicode) );
	return $isnr;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $else = q();
	my $code = q();
	return 1 if( $self->{'reason'} );

	foreach my $c ( 'temporary', 'permanent' )
	{
		$else = Kanadzuchi::RFC3463->causa($stat) || q();
		last() if $else;
	}

	if( $else eq 'undefined' || $else eq 'userunknown' || ! $else )
	{
		eval { 
			use Kanadzuchi::Mail::Why::ContentError;
			use Kanadzuchi::Mail::Why::SecurityError;
			use Kanadzuchi::Mail::Why::Expired;
			use Kanadzuchi::Mail::Why::SystemError;
			use Kanadzuchi::Mail::Why::NotAccept;
			use Kanadzuchi::Mail::Why::MailerError;
		};

		my $dicode = $self->{'diagnosticcode'};
		my $eclass = q();
		my $wclass = { 
			'securityerr' => 'SecurityError', 
			'systemerror' => 'SystemError', 
			'expired' => 'Expired', 
			'contenterr' => 'ContentError', 
			'notaccept' => 'NotAccept',
			'mailererror' => 'MailerError', };

		foreach my $w ( keys %$wclass )
		{
			$eclass = q|Kanadzuchi::Mail::Why::|.$wclass->{ $w };
			if( $eclass->textumhabet( $dicode ) )
			{
				$else = $w;
				last();
			}
		}

		unless( $else )
		{
			# The error 'Relaying denied' is classfied into the rason 'systemerror'
			eval { use Kanadzuchi::Mail::Why::RelayingDenied; };
			$eclass = q|Kanadzuchi::Mail::Why::RelayingDenied|;
			$else = 'systemerror' if( $eclass->textumhabet( $dicode ) );
		}

		unless( $else )
		{
			$code = substr($stat,0,3);
			$else = $code eq '5.6' ? 'contenterr' : $code eq '5.7' ? 'securityerr' : q();
		}
	}

	$self->{'reason'} ||= $else;
	return 1 if( $self->{'reason'} );
	return 0;
}

sub is_onhold
{
	# +-+-+-+-+-+-+-+-+-+
	# |i|s|_|o|n|h|o|l|d|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Status: 5.0.999 is on hold
	# @Param	<None>
	# @Return	(Integer) 1 = The reason is on hold
	#		(Integer) 0 = is not
	my $self = shift();
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'onhold';

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		return 1 if( $self->{'reason'} eq $subj );
	}

	return 1 if( $subj eq Kanadzuchi::RFC3463->causa($stat) );
	return 0;
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
	return 0 if( ! defined($self->{'deliverystatus'}) );
	return 1 if( substr($self->{'deliverystatus'},0,1) == 5 );
	return 0;
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
	return 0 if( ! defined($self->{'deliverystatus'}) );
	return 1 if( substr($self->{'deliverystatus'},0,1) == 4 );
	return 0;
}

1;
__END__
