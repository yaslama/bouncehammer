# $Id: Google.pm,v 1.1 2010/07/01 12:53:45 ak Exp $
# -Id: Google.pm,v 1.1 2009/08/29 08:50:36 ak Exp -
# -Id: Google.pm,v 1.1 2009/07/31 09:04:38 ak Exp -
# Kanadzuchi::MTA::

  ####                        ###          
 ##  ##  ####   ####   #####   ##   ####   
 ##     ##  ## ##  ## ##  ##   ##  ##  ##  
 ## ### ##  ## ##  ## ##  ##   ##  ######  
 ##  ## ##  ## ##  ##  #####   ##  ##      
  ####   ####   ####      ##  ####  ####   
                      #####                
package Kanadzuchi::MTA::Google;
use base 'Kanadzuchi::MTA';
use Kanadzuchi::RFC1893;
use Kanadzuchi::RFC2822;

my $RxPermGmail = qr{Delivery to the following recipient failed permanently:};
my $RxTempGmail = qr{Delivery to the following recipient has been delayed:};
my $RxErrorHead = qr{The error that the other server returned was:};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub emailheaders
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |e|m|a|i|l|h|e|a|d|e|r|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Required email headers
	# @Param 	<None>
	# @Return	(Ref->Array) Header names
	my $class = shift();
	return [ 'X-Failed-Recipients' ];
}

sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error via Google(Gmail)
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();
	my $phead = q();

	#   ____                 _ _ 
	#  / ___|_ __ ___   __ _(_) |
	# | |  _| '_ ` _ \ / _` | | |
	# | |_| | | | | | | (_| | | |
	#  \____|_| |_| |_|\__,_|_|_|
	#                            
	# Google Mail: GMail
	# From: Mail Delivery Subsystem <mailer-daemon@googlemail.com>
	# Received: from vw-in-f109.1e100.net [74.125.113.109] by ...
	#
	# * Check the body part
	#	This is an automatically generated Delivery Status Notification
	#	Delivery to the following recipient failed permanently:
	#
	#		recipient-address-here@example.jp
	#
	#	Technical details of permanent failure: 
	#	Google tried to deliver your message, but it was rejected by the
	#	recipient domain. We recommend contacting the other email provider
	#	for further information about the cause of this error. The error
	#	that the other server returned was: 
	#	550 550 <recipient-address-heare@example.jp>: User unknown (state 14).
	#
	return q() unless( $mhead->{'from'} =~ m{[@]googlemail[.]com[>]?\z} );
	return q() unless( $mhead->{'subject'} =~ m{Delivery[ ]Status[ ]Notification} );

	my $gmail = 0;		# Flag, is Gmail or not.
	my $state = 0;		# (state xx).
	my $frcpt = q();	# X-Final-Recipients: header or email address in the body.
	my $dcode = q();	# Diagnostic-Code: header or error text.
	my $bodyb = q();	# Boby part for rewriting
	my $error = 'onhold';	# Error reason: userunknown, filtered, mailboxfull...
	my $dstat = q();	# Pseudo D.S.N.

	$phead .= sprintf("Date: %s\n", $mhead->{'date'} );
	$phead .= sprintf("From: %s\n", $mhead->{'to'} );
	$frcpt  = $1 if( lc($mhead->{'x-failed-recipients'}) =~ m{\A[ ]?(.+[@].+)[ ]*\z} );

	EACH_LINE: foreach my $_gl ( split( qq{\n}, $$mbody ) )
	{
		next() if( $_gl =~ m{\A\z} );

		if( ! $gmail && ( $_gl =~ $RxPermGmail || $_gl =~ $RxTempGmail ) )
		{
			# The line match with 'Delivery to the following...'
			$gmail = 1;
			next();
		}
		next() unless( $gmail );

		# ^Irecipient-address-here@example.jp
		if( $gmail && $_gl =~ m{\A\s+([^\s]+[@][^\s]+)\z} )
		{
			my $_rcpt = $1;
			my $_2822 = q|Kanadzuchi::RFC2822|;

			$frcpt ||= $_rcpt if( $_2822->is_emailaddress($_2822->cleanup($_rcpt)) );
			next();
		}

		$_gl =~ s{=\z}{}g;
		$bodyb .= $_gl if( $_gl =~ m{\A\w} );

		last() if( $_gl =~ m{[(]state[ ]\d+[)][.]} );
		last() if( $_gl =~ m{\A\s*[-][-]+} || $_gl =~ m{\A[.]\z} );
	}

	$bodyb =~ s{\A.+$RxErrorHead }{};
	$state =  $1 if( $bodyb =~ m{[(]state[ ](\d+)[)][.]} );
	$dstat =  $1 if( $bodyb =~ m{[(][#](\d[.]\d[.]\d)[)]} );

	if( $bodyb =~ m{\d{3}[ ]\d{3}[ ](\d[.]\d[.]\d)[ ][<](.+?)[>]:?(.+)\z} )
	{
		# There is D.S.N. code in the body part.
		# 550 550 5.1.1 <userunknown@example.jp>... User Unknown (state 14).
		# 450 450 4.2.2 <mailboxfull@example.jp>... Mailbox Full (state 14).
		$dstat ||= $1;
		$frcpt ||= $2;
		$dcode = $3;
	}
	else
	{
		# There is NO D.S.N. code in the body part.
		if( $state == 14 )
		{
			$error = 'userunknown';
		}
		elsif( $state == 18 )
		{
			$error = 'filtered';
		}


		if( $bodyb =~ m{\d{3}[ ]\d{3}[ ][<](.+?)[>]:[ ](User unknown.+)\z} )
		{
			# 550 550 <userunknown@example.com>: User unknown (state 14).
			$frcpt ||= $1;
			$dcode = $2;
		}
		elsif( $bodyb =~ m{\d{3}[ ]\d{3}[ ](.+)[ ]([^\s]+[@][^\s]+)[ ](.+)\z} )
		{
			# 550 550 Unknown user is-user-unknown@example.ne.jp (state 14).
			# 550 550 Unknown user filtered-address@example.ne.jp (state 18).
			$frcpt ||= $2;
			$dcode = $1.' '.$3;
		}
		else
		{
			# Unsupported error message in body part.
			;
		}

	}

	return q() unless( $frcpt );
	$dstat ||= Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode($error));
	$phead .= q(Diagnostic-Code: SMTP; ).qq($dcode\n);
	$phead .= q(Status: ).qq($dstat\n);
	$phead .= q(Final-Recipient: rfc822; ).qq($frcpt\n);
	$phead .= q(To: ).qq($frcpt\n);
	return $phead;
}

1;
__END__
