# $Id: Courier.pm,v 1.3 2010/12/13 04:14:48 ak Exp $
# Kanadzuchi::MTA::
                                                 
  ####                        ##                 
 ##  ##  ####  ##  ## #####        ####  #####   
 ##     ##  ## ##  ## ##  ## ###  ##  ## ##  ##  
 ##     ##  ## ##  ## ##      ##  ###### ##      
 ##  ## ##  ## ##  ## ##      ##  ##     ##      
  ####   ####   ##### ##     ####  ####  ##      
package Kanadzuchi::MTA::Courier;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# http://www.courier-mta.org/courierdsn.html
# courier/module.dsn/dsn*.txt
my $RxCourier = {
	#'from' => qr{Courier mail server at },
	'hline' => qr{\A[-]{75}\z},
	'begin'	=> [
		qr{DELAYS IN DELIVERING YOUR MESSAGE},
		qr{UNDELIVERABLE MAIL},
	],
	'endof' => qr{\AThe original message follows as a separate attachment[.]},
	'subject' => [
		qr{NOTICE: mail delivery status[.]},
		qr{WARNING: delayed mail[.]},
	],
	# 'message-id' => qr{\A[<]courier[.]},
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub xsmtpagent { 'X-SMTP-Agent: Courier'.qq(\n); }
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from Courier
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	return q() unless( grep { $mhead->{'subject'} =~ $_ } @{ $RxCourier->{'subject'} } );
	# return q() unless( defined $mhead->{'message-id'} );
	# return q() unless( $mhead->{'message-id'} =~ $RxCourier->{'message-id'} );

	my $phead = q();	# (String) Pseudo email header
	my $pstat = q();	# (String) Stauts code
	my $xsmtp = q();	# (String) SMTP Command for X-SMTP-Command:
	my $causa = q();	# (String) Error reason
	my $ucode = Kanadzuchi::RFC3463->status('undefined','p','i');

	my $statintxt = q();	# (String) #n.n.n
	my $rhostsaid = q();	# (String) Diagnostic-Code:
	my $esmtpcomm = {};	# (Ref->Hash) SMTP Command names

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( (grep { $el =~ $_ } @{ $RxCourier->{'begin'} }) .. ($el =~ $RxCourier->{'endof'}) )
		{
			if( $el =~ m{\A[>]{3}[ ]([A-Z]{4})[ ]?} )
			{
				# The original message was received on Wed, 29 Apr 2009 12:38:28 +0900
				# from example.org (localhost [127.0.0.1])
				#
				# ---------------------------------------------------------------------------
				#
				#                          UNDELIVERABLE MAIL
				#
				# Your message to the following recipients cannot be delivered:
				#
				# <userunknown@example.jp>:
				#    mx.example.jp [192.0.2.5]:
				# >>> RCPT TO:<userunknown@example.jp>
				# <<< 550 5.1.1 <userunknown@example.jp>... User Unknown
				#
				# ---------------------------------------------------------------------------
				#
				# If your message was also sent to additional recipients, their delivery
				# status is not included in this report.  You may or may not receive
				# other delivery status notifications for additional recipients.
				$xsmtp ||= $1;
				next();
			}

			if( $el =~ m{\A[<]{3}[ ](.+)\z} )
			{
				$rhostsaid = $1;
				next();
			}

			if( $rhostsaid )
			{
				last() if( $el =~ m{\A\z} || $el =~ $RxCourier->{'hline'} );
				$rhostsaid .= ' '.$el;
			}
		}
	}

	return q() unless $rhostsaid;
	$rhostsaid =~ s{\A }{}g;
	$rhostsaid =~ s{ \z}{}g;
	$rhostsaid =~ y{ }{ }s;

	if( $rhostsaid =~ m{\b([45][.][0-9][.][0-9]+)\b} )
	{
		$pstat = $1;
	}
	elsif( $causa )
	{
		$pstat = Kanadzuchi::RFC3463->status( $causa, 'p', 'i' );
	}
	else
	{
		$pstat = $ucode if $rhostsaid;
	}

	if( ! $xsmtp || $xsmtp eq 'CONN' )
	{
		$esmtpcomm = __PACKAGE__->SMTPCOMMAND();
		foreach my $cmd ( keys %$esmtpcomm )
		{
			if( $rhostsaid =~ $esmtpcomm->{ $cmd } )
			{
				$xsmtp = uc $cmd;
				last();
			}
		}
	}

	$phead .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
	$phead .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead .= __PACKAGE__->xsmtpstatus($pstat);
	$phead .= __PACKAGE__->xsmtpagent();
	return $phead;
}

1;
__END__
