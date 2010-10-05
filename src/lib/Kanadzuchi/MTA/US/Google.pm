# $Id: Google.pm,v 1.1 2010/10/05 11:22:36 ak Exp $
# -Id: Google.pm,v 1.2 2010/07/04 23:45:49 ak Exp -
# -Id: Google.pm,v 1.1 2009/08/29 08:50:36 ak Exp -
# -Id: Google.pm,v 1.1 2009/07/31 09:04:38 ak Exp -
# Kanadzuchi::MTA::US::

  ####                        ###          
 ##  ##  ####   ####   #####   ##   ####   
 ##     ##  ## ##  ## ##  ##   ##  ##  ##  
 ## ### ##  ## ##  ## ##  ##   ##  ######  
 ##  ## ##  ## ##  ##  #####   ##  ##      
  ####   ####   ####      ##  ####  ####   
                      #####                
package Kanadzuchi::MTA::US::Google;
use strict;
use warnings;
use base 'Kanadzuchi::MTA';

my $RxPermGmail = qr{Delivery to the following recipient failed permanently:};
my $RxTempGmail = qr{Delivery to the following recipient has been delayed:};
my $RxFromGmail = {
	'begin' => qr{Technical details of permanent failure:},
	'state' => qr{The error that the other server returned was:},
	'endof' => qr{\A----- Original message -----\z},
};

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

	my $xflag = 0;		# (Integer) Flag, is Gmail or not.
	my $state = 0;		# (Integer) (state xx).
	my $phead = q();	# (String) Pusedo header
	my $pbody = q();	# (String) Boby part for rewriting
	my $pstat = q();	# (String) Pseudo D.S.N.
	my $frcpt = q();	# (String) X-Final-Recipients: header or email address in the body.
	my $dcode = q();	# (String) Diagnostic-Code: header or error text.
	my $error = 'onhold';	# (String) Error reason: userunknown, filtered, mailboxfull...
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	$frcpt  = $1 if( lc($mhead->{'x-failed-recipients'}) =~ m{\A[ ]?(.+[@].+)[ ]*\z} );

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		next() if( $el =~ m{\A\z} );

		if( $xflag == 0 && ( $el =~ $RxPermGmail || $el =~ $RxTempGmail ) )
		{
			# The line match with 'Delivery to the following...'
			$xflag |= 1;
			next();
		}
		next() unless( $xflag );

		# ^Irecipient-address-here@example.jp
		if( ( $xflag & 1 ) && $el =~ m{\A\s+([^\s]+[@][^\s]+)\z} )
		{
			my $_rcpt = $1;
			my $_2822 = q|Kanadzuchi::RFC2822|;
			my $_addr = q|Kanadzuchi::Address|;

			$frcpt ||= $_rcpt if $_2822->is_emailaddress($_addr->canonify($_rcpt));
			next();
		}

		last() if( $el =~ $RxFromGmail->{'endof'} );
		$el =~ s{=\z}{}g;
		$pbody .= $el if( $el =~ m{\A[^\s]+} );
		last() if( $el =~ m{[(]state[ ]\d+[)][.]} || $pbody =~ m{[(]state[ ]\d+[)][.]} );
	}


	$pbody  =~ s/\A.*$RxFromGmail->{'begin'}.+$RxFromGmail->{'state'} //;
	$dcode   = $pbody;
	$state   = $1 if( $pbody =~ m{[(]state[ ](\d+)[)][.]} );
	$pstat ||= $1 if( $pbody =~ m{[(][#](\d[.]\d[.]\d+)[)]} );
	$pstat ||= $1 if( $dcode =~ m{\d{3}[ ]\d{3}[ ](\d[.]\d[.]\d+)} );

	if( $dcode =~ m{\d{3}[ ]\d{3}[ ](\d[.]\d[.]\d+)[ ][<](.+?)[>]:?.+\z} )
	{
		# There is D.S.N. code in the body part.
		# 550 550 5.1.1 <userunknown@example.jp>... User Unknown (state 14).
		# 450 450 4.2.2 <mailboxfull@example.jp>... Mailbox Full (state 14).
		$pstat ||= $1;
		$frcpt ||= $2;
	}

	if( ! $pstat || $pstat =~ m{\A[45][.]0[.]0\z} )
	{
		# There is NO D.S.N. code in the body part or D.S.N. is 5.0.0,4.0.0.
		$pstat = q();
		if( $state == 14 )
		{
			# Technical details of permanent failure: 
			# Google tried to deliver your message, but it was rejected by the recipient domain. 
			# We recommend contacting the other email provider for further information about the
			# cause of this error. The error that the other server returned was:
			# 550 550 5.2.2 <*****@****.**>... Mailbox Full (state 14).
			#
			# -- OR --
			#
			# Technical details of permanent failure: 
			# Google tried to deliver your message, but it was rejected by the recipient domain.
			# We recommend contacting the other email provider for further information about the
			# cause of this error. The error that the other server returned was:
			# 550 550 5.1.1 <******@*********.**>... User Unknown (state 14).
			# 
			$xsmtp = 'RCPT';
			$error = 'onhold';	# ...
		}
		elsif( $state == 13 )
		{
			# Technical details of permanent failure: 
			# Google tried to deliver your message, but it was rejected by the recipient domain.
			# We recommend contacting the other email provider for further information about the
			# cause of this error. The error that the other server returned was: 
			# 550 550 5.7.1 <****@gmail.com>... Access denied (state 13).
			$xsmtp = 'MAIL';
			$error = 'rejected';
		}
		elsif( $state == 18 )
		{
			# Technical details of permanent failure: 
			# Google tried to deliver your message, but it was rejected by the recipient domain.
			# We recommend contacting the other email provider for further information about the
			# cause of this error. The error that the other server returned was:
			# 550 550 Unknown user *****@***.**.*** (state 18).
			$xsmtp = 'DATA';
			$error = 'filtered';
		}
		elsif( $state )
		{
			# There is the code (state xx) that Kanadzuchi does not know.
			# state 6(TLS?), 8(AUTH?), 9, 12, 15, 17,
			#
			# Technical details of permanent failure:
			# Google tried to deliver your message, but it was rejected by the recipient domain.
			# We recommend contacting the other email provider for further information about the
			# cause of this error. The error that the other server returned was:
			# 550 550 5.7.1 SPF unauthorized mail is prohibited. (state 15).
			#
			$error = 'onhold';
		}
		else
		{
			# Unsupported error message in body part.
			$error = 'undefined';
		}

	}

	return q() unless( $frcpt );
	$pstat ||= Kanadzuchi::RFC3463->status($error,'p','i');
	$xsmtp ||= 'CONN';
	$phead .= __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n);

	$phead .=  q(X-Diagnosis: SMTP; ).qq($dcode\n);
	$phead .=  q(Status: ).$pstat.qq(\n);
	$phead .=  q(Final-Recipient: rfc822; ).qq($frcpt\n);
	$phead .=  q(To: ).qq($frcpt\n);

	return $phead;
}

1;
__END__
