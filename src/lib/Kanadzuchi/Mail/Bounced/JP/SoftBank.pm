# $Id: SoftBank.pm,v 1.5 2010/07/07 06:15:30 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Bounced::JP::
                                                        
  #####           ### ##   #####                ##      
 ###      ####   ## ###### ##  ##  ####  #####  ##      
  ###    ##  ## ##### ##   #####      ## ##  ## ## ##   
   ###   ##  ##  ##   ##   ##  ##  ##### ##  ## ####    
    ###  ##  ##  ##   ##   ##  ## ##  ## ##  ## ## ##   
 #####    ####   ##    ### #####   ##### ##  ## ##  ##  
package Kanadzuchi::Mail::Bounced::JP::SoftBank;
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
	my $stat = $self->{'deliverystatus'} || return 0;
	my $subj = 'filtered';
	my $isfi = 0;

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isfi = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# SoftBank Mobile
			#   Status: 5.2.0
			#   Diagnostic-Code: <None>
			$isfi = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) )
		{
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
				&& ( $flib->habettextu($diag) || $ulib->habettextu($diag) ) ){

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
	my $diag = $self->{'diagnosticcode'} || q();
	my $subj = 'userunknown';
	my $isuu = 0;
	my $rxuu = qr{550[ ]Invalid[ ]recipient[:][ ][<].+[>]};

	if( defined $self->{'reason'} && length($self->{'reason'}) )
	{
		$isuu = 1 if( $self->{'reason'} eq $subj );
	}
	else
	{
		if( $stat == Kanadzuchi::RFC1893->standardcode($subj) )
		{
			# Softbank Mobile
			#   Status: 5.1.1
			#   Diagnostic-Code: SMTP; 550 Invalid recipient: <***@d.vodafone.ne.jp>
			$isuu = 1;
		}
		elsif( $stat == Kanadzuchi::RFC1893->internalcode($subj) && $diag =~ $rxuu )
		{
			$isuu = 1;
		}
		else
		{
			eval { require Kanadzuchi::Mail::Why::UserUnknown; };
			my $ulib = q|Kanadzuchi::Mail::Why::UserUnknown|;

			if( $self->{'smtpcommand'} eq 'RCPT' &&
					( $diag =~ $rxuu || $ulib->habettextu($diag) ) ){

				$isuu = 1;
			}
		}
	}
	return $isuu;
}

1;
__END__
