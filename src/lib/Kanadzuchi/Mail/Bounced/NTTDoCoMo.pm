# $Id: NTTDoCoMo.pm,v 1.3 2010/04/01 08:03:34 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Bounced::
                                                                  
 ##  ## ###### ###### ####           ####         ##  ##          
 ### ##   ##     ##   ## ##   ####  ##  ##  ####  ######   ####   
 ######   ##     ##   ##  ## ##  ## ##     ##  ## ######  ##  ##  
 ## ###   ##     ##   ##  ## ##  ## ##     ##  ## ##  ##  ##  ##  
 ##  ##   ##     ##   ## ##  ##  ## ##  ## ##  ## ##  ##  ##  ##  
 ##  ##   ##     ##   ####    ####   ####   ####  ##  ##   ####   
package Kanadzuchi::Mail::Bounced::NTTDoCoMo;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
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

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||P |||u |||b |||l |||i |||c |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
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
	my $stat = $self->{'deliverystatus'} || return(0);
	my $subj = 'filtered';
	my $isfi = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == 521 || $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# NTT DoCoMo,
			#  Status: 5.2.0, 5.2.1?
			#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
			$isfi = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isfi = 1;
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
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# NTT DoCoMo
			#  Status: 5.1.1
			#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
			$isuu = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
			$isuu = 1;
		}
	}
	return($isuu);
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
	my $diag = $self->{'diagnosticcode'} || return(0);
	my $subj = 'mailboxfull';
	my $ismf = 0;
	my $rxmf = qr{[Tt]oo much mail data}o;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $diag =~ $rxmf && ( $stat == Kanadzuchi::RFC1893->standardcode($subj)
			|| $stat == Kanadzuchi::RFC1893->internalcode($subj) ) ){

			$ismf = 1;
		}
	}
	return($ismf);
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
	my $diag = $self->{'diagnosticcode'} || return(0);
	my $subj = 'mesgtoobig';
	my $istb = 0;
	my $rxtb = qr{552[ ]Message[ ]size[ ]exceeds[ ]maximum[ ]value}o;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$istb = 1 if( $self->{'reason'} eq $rxtb );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# Action: failed
			# Status: 5.3.4
			# Diagnostic-Code: SMTP; 552 Message size exceeds maximum value
			$istb = 1;
		}
		elsif( $diag =~ $rxtb )
		{
			if( $stat == Kanadzuchi::RFC1893->internalcode($subj) || int($stat/100) == 5 )
			{
				$istb = 1;
			}
		}
	}
	return($istb);
}

1;
__END__
