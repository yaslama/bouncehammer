# $Id: NTTDoCoMo.pm,v 1.4 2010/10/05 11:29:51 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Bounced::
                                                                  
 ##  ## ###### ###### ####           ####         ##  ##          
 ### ##   ##     ##   ## ##   ####  ##  ##  ####  ######   ####   
 ######   ##     ##   ##  ## ##  ## ##     ##  ## ######  ##  ##  
 ## ###   ##     ##   ##  ## ##  ## ##     ##  ## ##  ##  ##  ##  
 ##  ##   ##     ##   ## ##  ##  ## ##  ## ##  ## ##  ##  ##  ##  
 ##  ##   ##     ##   ####    ####   ####   ####  ##  ##   ####   
package Kanadzuchi::Mail::Bounced::JP::NTTDoCoMo;
use base 'Kanadzuchi::Mail::Bounced';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ 
# ||T |||o |||D |||o |||s ||
# ||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|
#
# 1. Remote Protocol Error
#	Status: 5.5.4
#	Diagnostic-Code: SMTP; 504 Command parameter not implemented 

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
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
			# NTT DoCoMo,
			#  Status: 5.2.0, 5.2.1?
			#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
			$isfi = 1;
		}
		else
		{
			eval { 
				require Kanadzuchi::Mail::Why::Filtered; 
				require Kanadzuchi::Mail::Why::UserUnknown; 
			};
			my $flib = q|Kanadzuchi::Mail::Why::Filtered|;
			my $ulib = q|Kanadzuchi::Mail::Why::UserUnknown|;
			my $diag = $self->{'diagnosticcode'};

			if( $self->{'smtpcommand'} eq 'DATA' 
				&& ( $flib->textumhabet($diag) || $ulib->textumhabet($diag) ) ){

				$isfi = 1;
			}
		}
	}

	return $isfi;
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
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# NTT DoCoMo
			#  Status: 5.1.1
			#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
			$isuu = 1;
		}
		else
		{
			eval { require Kanadzuchi::Mail::Why::UserUnknown; };
			my $ulib = q|Kanadzuchi::Mail::Why::UserUnknown|;
			my $diag = $self->{'diagnosticcode'};

			if( $self->{'smtpcommand'} eq 'RCPT' && $ulib->textumhabet($diag) )
			{
				$isuu = 1;
			}
		}
	}
	return $isuu;
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
	my $diag = $self->{'diagnosticcode'} || return 0;
	my $subj = 'mailboxfull';
	my $ismf = 0;
	my $rxmf = qr{[Tt]oo much mail data}o;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $diag =~ $rxmf && $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$ismf = 1;
		}
	}
	return $ismf;
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
	my $diag = $self->{'diagnosticcode'} || return 0;
	my $subj = 'mesgtoobig';
	my $istb = 0;
	my $rxtb = qr{552[ ]Message[ ]size[ ]exceeds[ ]maximum[ ]value}o;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$istb = 1 if( $self->{'reason'} eq $rxtb );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			# Action: failed
			# Status: 5.3.4
			# Diagnostic-Code: SMTP; 552 Message size exceeds maximum value
			$istb = 1;
		}
		elsif( $diag =~ $rxtb )
		{
			if( $subj eq Kanadzuchi::RFC3463->causa($stat) || $self->is_permerror() )
			{
				$istb = 1;
			}
		}
	}
	return $istb;
}

1;
__END__
