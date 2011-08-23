# $Id: qmail.pm,v 1.7.2.3 2011/08/23 21:28:27 ak Exp $
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
	'begin'	=> qr{\AHi[.] This is the qmail},
	'endof' => qr{\A--- Below this line is a copy of the message[.]\z},
	'sorry' => qr{\A[Ss]orry[,.][ ]},
	'subject' => qr{\Afailure notice},
	'received' => qr{\A[(]qmail[ ]+\d+[ ]+invoked[ ]+for[ ]+bounce[)]},
};

my $RxSMTPError = {
	'conn'	=> [
		qr{(?:Error:)?Connected to .+ but greeting failed[.]}
	],
	'mail'	=> [
		qr{(?:Error:)?Connected to .+ but my name was rejected[.]},	# HELO,EHLO
		qr{(?:Error:)?Connected to .+ but sender was rejected[.]},	# MAIL FROM
	],
	'rcpt'	=> [
		qr{(?:Error:)?.+ does not like recipient[.]},			# RCPT TO
	],
	'data'	=> [
		qr{(?:Error:)?.+ failed on DATA command[.]},			# DATA
		qr{(?:Error:)?.+ failed after I sent the message[.]},		# . ?
	],
};

my $RxqmailError = {
	'userunknown' => [
		qr{no mailbox here by that name[.]},
	],
	'mailboxfull' => [
		qr{disk quota exceeded},
	],
	'expired' => [
		qr{this message has been in the queue too long},
	],
	'hostunknown' => [
		qr{\ASorry, I couldn[']t find any host named },
	],
	'systemerror' => [
		qr{bad interpreter: No such file or directory},
		qr{Sorry, I wasn[']t able to establish an SMTP connection},
		qr{Sorry, I couldn[']t find a mail exchanger or IP address},
		qr{Sorry[.] Although I[']m listed as a best[-]preference MX or A for that host,},
		qr{system error},
		qr{Unable to\b},
	],
	'systemfull' => [
		qr{Requested action not taken: mailbox unavailable [(]not enough free space[)]},
	],
	'ldaperror' => [
		# qmail-ldap-1.03-20040101.patch:19817 - 19866
		qr{Mailaddress is administrative?le?y disabled},		# 5.2.1
		qr{[Ss]orry, no mailbox here by that name},			# 5.1.1
		qr{The message exeeded the maximum size the user accepts},	# 5.2.3
		qr{Temporary failure in LDAP lookup},				# 4.4.3
		qr{Unable to login into LDAP server, bad credentials},		# 4.4.3
		qr{Timeout while performing search on LDAP server},		# 4.4.3
		qr{Unable to contact LDAP server},				# 4.4.3
		qr{Too many results returned but needs to be unique},		# 5.3.5
		qr{LDAP attribute is not given but mandatory},			# 5.3.5
		qr{Illegal value in LDAP attribute},				# 5.3.5
		qr{Temporary error while executing qmail-forward},		# 4.4.4
		qr{Permanent error while executing qmail-forward},		# 5.4.4
		qr{Automatic homedir creator crashed},				# 4.3.0
		qr{Temporary error in automatic homedir creation},		# 4.3.0 or 5.3.0
	],
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub version { '2.1.3' };
sub description { 'qmail' };
sub xsmtpagent { 'X-SMTP-Agent: qmail'.qq(\n); }
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
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

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
	return q() unless( lc($mhead->{'subject'}) =~ $RxQSBMF->{'subject'} );
	return q() unless( grep { $_ =~ $RxQSBMF->{'received'} } @{ $mhead->{'received'} } );

	my $pstat = q();	# (String) Pseudo status value
	my $phead = q();	# (String) Pseudo email header
	my $pbody = q();	# (String) Pseudo body part
	my $xsmtp = q();	# (String) SMTP Command in transcript of session
	my $causa = q();	# (String) Error reason
	my $endof = 0;		# (Integer) The line matched 'endof' regexp.

	my $rhostsaid = q();	# (String) Remote host said: ...
	my $rcptintxt = q();	# (String) Recipient address in message body
	my $statintxt = q();	# (String) #n.n.n Status code in message body
	my $esmtpcomm = {};	# (Ref->Hash) SMTP Command names

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		$endof = 1 if( $endof == 0 && $el =~ $RxQSBMF->{'endof'} );
		next() if( $endof || $el =~ m{\A\z} );

		if( ($el =~ $RxQSBMF->{'begin'}) .. ($el =~ $RxQSBMF->{'endof'}) )
		{
			if( ! $rcptintxt && $el =~ m{\A(?:To[ ]*:)?[<](.+[@].+)[>]:\z} )
			{
				# Get a mail address from the recipient paragraph.
				$rcptintxt = $1;
				next();
			}

			if( $rcptintxt )
			{
				# The line which begins with the string 'Remote host said:'
				$rhostsaid .= $el.' ';
				next();
			}
		}

	} # End of foreach(EACH_LINE)

	return q() unless $rcptintxt;
	return q() unless $rhostsaid;
	$rhostsaid =~ y{ }{}s;
	$rhostsaid =~ s{\A }{}g;
	$rhostsaid =~ s{ \z}{}g;

	if( $rhostsaid =~ $RxQSBMF->{'sorry'} )
	{
		# The line which begins with the string 'Sorry,...'
		$xsmtp = 'CONN';
	}
	else
	{
		DETECT:
		{
			SMTP_ERROR: foreach my $e ( keys(%{ $RxSMTPError }) )
			{
				if( grep { $rhostsaid =~ $_ } @{ $RxSMTPError->{$e} } )
				{
					$xsmtp = uc $e;
					last();
				}
			}

			QMAIL_ERROR: foreach my $q ( keys(%{ $RxqmailError }) )
			{
				if( grep { $rhostsaid =~ $_ } @{ $RxqmailError->{$q} } )
				{
					$causa = $q;
					$xsmtp ||= 'DATA';

					if( $q eq 'ldaperror' )
					{
						# qmail-ldap errors
						# $xsmtp ||= 'RCPT';

						# Mailaddress is administrativley disabled. (LDAP-ERR #220)
						if( $rhostsaid =~ m{[ ][(]LDAP[-]ERR[ ][#]\d+[)]\z} )
						{
							$causa = 'systemerror';
						}
					}
					last(DETECT);
				}
				else
				{
					$causa ||= 'undefined';
					$xsmtp ||= 'DATA';
				}
			}
		}
	}

	if( $rhostsaid =~ m{[ ][(][#]([[45][.]\d[.]\d+)[)]\z} ||
		$rhostsaid =~ m{\b\d{3}[-\s]([45][.]\d[.]\d+)\b} ){

		# Remote host said: 550-5.1.1 The email account ...
		# Remote host said: 550 5.7.1 <user@example.jp>... Access denied
		$statintxt = $1;
	}
	else
	{
		$pstat = Kanadzuchi::RFC3463->status( ( $causa || 'undefined' ), 'p', 'i' );
	}

	# Add the pseudo Content-Type header if it does not exist.
	$mhead->{'content-type'} ||= q(message/delivery-status);

	if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) )
	{
		$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n);
	}
	else
	{
		$rcptintxt = Kanadzuchi::Address->canonify($rhostsaid);
		$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n) 
				if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) );
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

	# Add the text that 'Remote host said' or 'Sorry,...' into X-SMTP-Diagnosis header.
	$phead .= __PACKAGE__->xsmtpdiagnosis( $rhostsaid );
	$phead .= __PACKAGE__->xsmtpstatus( ($statintxt || $pstat) );
	$phead .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead .= __PACKAGE__->xsmtpagent();

	return $phead;
}

1;
__END__
