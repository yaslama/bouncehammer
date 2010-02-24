# $Id: NTTDoCoMo.pm,v 1.2 2010/02/21 20:27:31 ak Exp $
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
	my $isfi = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq 'filtered' );
	}
	else
	{
		# NTT DoCoMo,
		#  Status: 5.2.0, 5.2.1?
		#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
		$isfi = 1 if( $stat == 520 || $stat == 521 );
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
	my $isuu = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$isuu = 1 if( $self->{'reason'} eq 'userunknown' );
	}
	else
	{
		# NTT DoCoMo
		#  Status: 5.1.1
		#  Diagnostic-Code: SMTP; 550 Unknown user ***@docomo.ne.jp
		$isuu = 1 if( $stat == 511 );
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
	my $ismf = 0;

	if( defined($self->{'reason'}) && length($self->{'reason'}) )
	{
		$ismf = 1 if( $self->{'reason'} eq 'mailboxfull' );
	}
	else
	{
		$ismf = 1 if( $stat == 522 && $diag =~ m{too much mail data} );
	}
	return($ismf);
}

1;
__END__
