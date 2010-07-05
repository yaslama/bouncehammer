# $Id: qmail.pm,v 1.2 2010/07/04 23:45:50 ak Exp $
# Kanadzuchi::MTA::
                         ##  ###    
  #####  ##  ##  ####         ##    
 ##  ##  ######     ##  ###   ##    
 ##  ##  ######  #####   ##   ##    
  #####  ##  ## ##  ##   ##   ##    
     ##  ##  ##  #####  #### ####   
     ##                             
package Kanadzuchi::MTA::qmail;

# qmail: the Internet's MTA of choice - http://cr.yp.to/qmail.html
# The qmail-send Bounce Message Format (QSBMF) http://cr.yp.to/proto/qsbmf.txt
# QSBMF IS NOT COMPATIBLE WITH RFC 1894 http://www.ietf.org/rfc/rfc1894.txt
use base 'Kanadzuchi::MTA';
use strict;
use warnings;
use Kanadzuchi::RFC1893;
use Kanadzuchi::RFC2822;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Error text regular expressions which defined in qmail-remote.c
#  qmail-remote.c:238|  if (code >= 500) quit("DConnected to "," but sender was rejected");
#  qmail-remote.c:248|    if (code >= 500) {
#  qmail-remote.c:249|      out("h"); outhost(); out(" does not like recipient.\n");
#  qmail-remote.c:265|  if (code >= 500) quit("D"," failed on DATA command");
#  qmail-remote.c:271|  if (code >= 500) quit("D"," failed after I sent the message");
#
# Characters: K,Z,D in qmail-qmqpc.c, qmail-send.c, qmail-rspawn.c
#  K = success, Z = temporary error, D = permanent error
#
my $RxQSBMF = {
	'begin'	=> qr{\AHi[.][ ]This[ ]is[ ]the[ ]}o,
	'sorry' => qr{\ASorry[,][ ]}o,
};

my $RxSMTPError = {
	'greet' => qr{\AConnected[ ]to[ ].+[ ]but[ ]greeting[ ]failed[.]\z}o,
	'helo' => qr{\AConnected[ ]to[ ].+[ ]but[ ]my[ ]name[ ]was[ ]rejected[.]\z}o,
	'mail' => qr{\AConnected[ ]to[ ].+[ ]but[ ]sender[ ]was[ ]rejected[.]\z}o,
	'rcpt' => qr{\A.+[ ]does[ ]not[ ]like[ ]recipient[.]\z}o,
	'data' => qr{\A.+[ ]failed[ ]on[ ]DATA[ ]command[.]\z}o,
	'payload' => qr{\A.+[ ]failed[ ]after[ ]I[ ]sent[ ]the[ ]message[.]\z}o,
};

my $RxConnError = {
	'conn' => qr{\ASorry[,][ ]I[ ]couldn[']t[ ]find[ ]any[ ]host[ ]named[ ]}o,
	# 'nomxrr' => qr{\ASorry[,][ ]I[ ]couldn[']t[ ]find[ ]a[ ]mail[ ]exchanger[ ]or[ ]IP[ ]address}o,
	# 'ambimx' => qr{\ASorry[.][ ]Although I[']m listed as a best[-]preference MX or A for that host[,]}o,
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from qmail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return();
	my $mbody = shift() || return();

	#                        _ _ 
	#   __ _ _ __ ___   __ _(_) |
	#  / _` | '_ ` _ \ / _` | | |
	# | (_| | | | | | | (_| | | |
	#  \__, |_| |_| |_|\__,_|_|_|
	#     |_|                    
	# Pre-Process eMail headers and body part of message which generated
	# by qmail, see http://cr.yp.to/qmail.html
	#   e.g.) Received: (qmail 12345 invoked for bounce); 29 Apr 2009 12:34:56 -0000
	#         Subject: failure notice
	return q() unless( lc($mhead->{'subject'}) eq 'failure notice' );
	return q() unless( grep { $_ =~ m{\A[(]qmail[ ]+\d+[ ]+invoked[ ]+for[ ]+bounce[)]} } @{ $mhead->{'received'} } );

	my $xflag = 0;		# (Integer) Flag, 1 = is qmail
	my $pstat = 500;	# (Integer) Pseudo status value
	my $phead = q();	# (String) Pseudo email header
	my $pbody = q();	# (String) Pseudo body part
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	my $smtperror = { 'mail' => 0, 'rcpt' => 0, 'data' => 0, 'payload' => 0 };
	my $connerror = { 'conn' => 0 };
	my $errortype = { 'smtp' => 0, 'conn' => 0 };
	my $rhostsaid = q();	# Remote host said: ...
	my $sorrythat = q();	# Sorry, ....
	my $rcptintxt = q();	# Recipient address in message body
	my $statintxt = q();	# #n.n.n Status code in message body

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( $xflag == 0 && $el =~ $RxQSBMF->{'begin'} )
		{
			$xflag |= 1;
			next();
		}

		# The line which begins with the string 'Remote host said:'
		unless( $errortype->{'smtp'} )
		{
			SMTP_ERROR: foreach my $_se ( keys(%$smtperror) )
			{
				if( $el =~ $RxSMTPError->{$_se} )
				{
					$smtperror->{$_se} = 1;
					$errortype->{smtp} = 1;
					$xsmtp = uc $_se;
					last();
				}
			}
		}

		# The line which begins with the string 'Sorry,...'
		if( ! $errortype->{'conn'} && $el =~ $RxQSBMF->{'sorry'} )
		{
			CONN_ERROR: foreach my $_ce ( keys(%$connerror) )
			{
				if( $el =~ $RxConnError->{$_ce} )
				{
					$connerror->{$_ce} = 1;
					$errortype->{conn} = 1;
					$xsmtp = uc $_ce;
					last()
				}
			}
		}

		# Get a mail address from the recipient paragraph.
		$rcptintxt = $1 if( $rcptintxt eq q() && $el =~ m{\A[<](.+[@].+)[>][:]\z} );
		$statintxt = $1 if( $statintxt eq q() && $el =~ m{[ ][(][#](\d[.]\d[.]\d)[)]\z} );
		$rhostsaid = $1 if( $errortype->{'smtp'} && $el =~ m{\ARemote[ ]host[ ]said:[ ]*(.+)\z} );
		$sorrythat = $1 if( $errortype->{'conn'} && $el =~ m{\A(Sorry[,][ ].*)\z} );
	}

	# Return if it does not include the line begins with 'Hi. This is the qmail...'
	return q() unless( $xflag );


	if( $errortype->{'smtp'} || $errortype->{'conn'} )
	{
		# Add the pseudo Content-Type header if it does not exist.
		$mhead->{'content-type'} ||= q(message/delivery-status);

		if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) )
		{
			$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n);
		}

		# Add the text that 'Remote host said' or 'Sorry,...' into Diagnostic-Code header.
		$phead .= q(Diagnostic-Code: ).($rhostsaid || $sorrythat).qq(\n);

		if( $errortype->{'smtp'} && $rhostsaid )
		{
			if( $rhostsaid =~ m{\A\d{3}[-\s](\d[.]\d[.]\d)[ ]} )
			{
				# Remote host said: 550-5.1.1 The email account ...
				$phead .= q(Status: ).$1.qq(\n);
			}
			elsif( $statintxt ne q() )
			{
				# Status code in text/message body
				$phead .= q(Status: ).$statintxt.qq(\n);
			}
			else
			{
				if( $smtperror->{'rcptto'} )
				{
					# RCPT TO: <who@example.jp> ... REJECTED
					$pstat = Kanadzuchi::RFC1893->internalcode('userunknown');
				}
				elsif( $smtperror->{'payload'} )
				{
					# Rejected after DATA command
					$pstat = Kanadzuchi::RFC1893->internalcode('filtered');
				}

				$phead .= q(Status: ).Kanadzuchi::RFC1893->int2code($pstat).qq(\n);
			}
		}
		elsif( $errortype->{'conn'} && $statintxt )
		{
			$phead .= q(Status: ).$statintxt.qq(\n);
		}
	}

	$xsmtp ||= 'CONN';
	$phead  .= __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n);
	return $phead;
}

1;
__END__
