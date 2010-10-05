# $Id: Yahoo.pm,v 1.4 2010/10/05 11:29:47 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Bounced::
                                              
 ##  ##         ##                      ##    
 ##  ##   ####  ##      ####   ####     ##    
  ####       ## #####  ##  ## ##  ##    ##    
   ##     ##### ##  ## ##  ## ##  ##    ##    
   ##    ##  ## ##  ## ##  ## ##  ##          
   ##     ##### ##  ##  ####   ####     ##    

# http://help.yahoo.co.jp/help/jp/mail/in_trouble/in_trouble-27.html
package Kanadzuchi::Mail::Bounced::Yahoo;
use base 'Kanadzuchi::Mail::Bounced';
use strict;
use warnings;

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
	my $stat = $self->{'deliverystatus'} || return(0);
	my $diag = $self->{'diagnosticcode'} || q();
	my $subj = 'filtered';
	my $isfi = 0;
	my $rxfi = qr{554 delivery error: dd Sorry your message to[ ].+[ ]cannot be delivered[.][ ]This account has been disabled or discontinued}o;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$isfi = 1;
		}
		elsif( $diag =~ $rxfi )
		{
			$isfi = 1 if( $self->is_permerror());
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
	my $stat = $self->{'deliverystatus'} || return(0);
	my $diag = $self->{'diagnosticcode'} || return(0);
	my $subj = 'userunknown';
	my $isuu = 0;
	my $rxuu = [
		qr{554[ ]delivery[ ]error[:][ ]dd[ ]This[ ]user[ ]doesn[']?t[ ]have[ ]a[ ]}o,
		qr{550[ ]Requested[ ]action[ ]not[ ]taken[:][ ]mailbox[ ]unavailable}o,
		qr{550[ ].+[ ]User[ ]unknow}o,
	];

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isuu = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$isuu = 1;
		}
		elsif( grep { $diag =~ $_ } @$rxuu )
		{
			# Action: failed
			# Status: 5.0.0
			# Remote-MTA: DNS; mx1.mail.yahoo.co.jp
			# Diagnostic-Code: SMTP; 554 delivery error: dd This user doesn't have a yahoo.co.jp account
			$isuu = 1 if( $self->is_permerror() );
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
	my $stat = $self->{'deliverystatus'} || return(0);
	my $diag = $self->{'diagnosticcode'} || return(0);
	my $subj = 'mailboxfull';
	my $ismf = 0;
	my $rxmf = qr{554 delivery error: dd Sorry, your message to[ ].+[ ]cannot[ ]be[ ]delivered[.][ ]This account is over quota[.]}o;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $subj eq Kanadzuchi::RFC3463->causa($stat) )
		{
			$ismf = 1;
		}
		elsif( $diag =~ $rxmf )
		{
			$ismf = 1;
		}
	}
	return $ismf;
}

1;
__END__
