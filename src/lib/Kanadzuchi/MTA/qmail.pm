# $Id: qmail.pm,v 1.4 2010/10/05 11:23:48 ak Exp $
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
};

my $RxSMTPError = {
	'greet'   => qr{\A(?:Error:)?Connected to .+ but greeting failed[.]\z},
	'helo'    => qr{\A(?:Error:)?Connected to .+ but my name was rejected[.]\z},
	'mail'    => qr{\A(?:Error:)?Connected to .+ but sender was rejected[.]\z},
	'rcpt'    => qr{\A(?:Error:)?.+ does not like recipient[.]\z},
	'data'    => qr{\A(?:Error:)?.+ failed on DATA command[.]\z},
	'payload' => qr{\A(?:Error:)?.+ failed after I sent the message[.]\z},
};

my $RxOtherMesg = {
	'expired' => [
		qr{this message has been in the queue too long},
	],
	'userunknown' => [
		qr{\AThis address no longer accepts mail},
	],
	'filtered' => [ 
		qr{\AUser unknown},
	],
	'mailboxfull' => [
		qr{disk quota exceeded},
		qr{Mailbox is FULL},
		qr{\Amailbox .+ would be over the allowed quota[.]},
		qr{\AMail quota exceeded},
		qr{\Amaildrop: maildir over quota[.]},
		qr{\AMessage rejected[.] Not enough storage space in user[']s mailbox to accept message},
		qr{Recipient[']s mailbox is full, message returned to sender},
		qr{\AThe users mailfolder is over the allowed quota [(]size[)][.]},
		qr{\AUser has exceeded quota, bouncing mail},
		qr{\A[Uu]ser is over quota},
		qr{\AUser over quota[.] [(][#]5[.]1[.]1[)]\z},	# qmail-toaster
		qr{\AUser over quota},
	],
	'systemfull' => [
		qr{\A\d+ Requested action not taken: mailbox unavailable [(]not enough free space[)]},
	],
	'systemerr' => [
		qr{Unable to chdir to maildir},
		qr{bad interpreter: No such file or directory},
		qr{Unable to switch to /},
		qr{system error},
	],
};

# qmail-ldap-1.03-20040101.patch:19817 - 19866
my $RxLDAPError = [
	qr{\AMailaddress is administrative?le?y disabled},		# 5.2.1
	qr{\A[Ss]orry, no mailbox here by that name},			# 5.1.1
	qr{\AThe message exeeded the maximum size the user accepts},	# 5.2.3
	qr{\ATemporary failure in LDAP lookup},				# 4.4.3
	qr{\AUnable to login into LDAP server, bad credentials},	# 4.4.3
	qr{\ATimeout while performing search on LDAP server},		# 4.4.3
	qr{\AUnable to contact LDAP server},				# 4.4.3
	qr{\AToo many results returned but needs to be unique},		# 5.3.5
	qr{\ALDAP attribute is not given but mandatory},		# 5.3.5
	qr{\AIllegal value in LDAP attribute},				# 5.3.5
	qr{\ATemporary error while executing qmail-forward},		# 4.4.4
	qr{\APermanent error while executing qmail-forward},		# 5.4.4
	qr{\AAutomatic homedir creator crashed},			# 4.3.0
	qr{\ATemporary error in automatic homedir creation},		# 4.3.0 or 5.3.0
];

my $RxConnError = [
	qr{\ASorry, I couldn[']t find any host named },
	qr{\ASorry, I wasn[']t able to establish an SMTP connection},
];

my $RxMXRRError = [
	qr{\ASorry, I couldn[']t find a mail exchanger or IP address},
	qr{\ASorry[.] Although I[']m listed as a best[-]preference MX or A for that host,},
];

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
	return q() unless( lc($mhead->{'subject'}) eq 'failure notice' );
	return q() unless( grep { $_ =~ m{\A[(]qmail[ ]+\d+[ ]+invoked[ ]+for[ ]+bounce[)]} } @{ $mhead->{'received'} } );

	my $xflag = 0;		# (Integer) Flag, 1 = is qmail
	my $pstat = '5.0.0';	# (String) Pseudo status value
	my $phead = q();	# (String) Pseudo email header
	my $pbody = q();	# (String) Pseudo body part
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	my $smtperror = { 'mail' => 0, 'rcpt' => 0, 'data' => 0, 'payload' => 0 };
	my $errortype = { 'smtp' => 0, 'conn' => 0 };
	my $rhostsaid = q();	# (String) Remote host said: ...
	my $sorrythat = q();	# (String) Sorry, ....
	my $rcptintxt = q();	# (String) Recipient address in message body
	my $statintxt = q();	# (String) #n.n.n Status code in message body
	my $altofdiag = q();	# (String) Diagnostic-Code, alternative
	my $altofstat = q();	# (String) #n.n.n. Status code, alternative

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( $xflag == 0 && $el =~ $RxQSBMF->{'begin'} )
		{
			$xflag |= 1;
			next();
		}

		DETECT_AN_ERROR: {
			unless( $errortype->{'smtp'} )
			{
				# The line which begins with the string 'Remote host said:'
				SMTP_ERROR: foreach my $_se ( keys(%$smtperror) )
				{
					if( $el =~ $RxSMTPError->{$_se} )
					{
						$smtperror->{$_se} = 1;
						$errortype->{smtp} = 1;
						$altofdiag = $el;
						$xsmtp = uc $_se;
						last(DETECT_AN_ERROR);
					}
				}

				# Simple error message
				SIMPLE_MESG: foreach my $_er ( keys(%$RxOtherMesg) )
				{
					if( grep { $el =~ $_ } @{ $RxOtherMesg->{$_er} } )
					{
						$altofstat = Kanadzuchi::RFC3463->status($_er,'p','i').qq(\n);
						$errortype->{smtp} = 1;
						$altofdiag = $el;
						$xsmtp = 'DATA';
						last(DETECT_AN_ERROR);
					}
				}

				# qmail-ldap errors
				if( grep { $el =~ $_ } @$RxLDAPError )
				{
					$smtperror->{rcpt} = 1;
					$errortype->{smtp} = 1;
					$altofdiag = $el;
					$xsmtp = 'RCPT';

					# Mailaddress is administrativley disabled. (LDAP-ERR #220)
					if( $el =~ m{[ ][(]LDAP[-]ERR[ ][#]\d+[)]\z} )
					{
						$statintxt = '5.3.5';
					}
					last(DETECT_AN_ERROR);
				}
			}

			if( ! $errortype->{'conn'} && $el =~ $RxQSBMF->{'sorry'} )
			{
				# The line which begins with the string 'Sorry,...'
				if( grep { $el =~ $_ } @$RxConnError, @$RxMXRRError )
				{
					$errortype->{conn} = 1;
					$altofdiag = $el;
					last(DETECT_AN_ERROR)
				}
			}
		}

		# Get a mail address from the recipient paragraph.
		$rcptintxt = $1 if( $rcptintxt eq q() && $el =~ m{\A(?:To[ ]*:)?[<](.+[@].+)[>][:]\z} );
		$statintxt = $1 if( $statintxt eq q() && $el =~ m{[ ][(][#](\d[.]\d[.]\d+)[)]\z} );
		$statintxt ||= $altofstat || q();
		$rhostsaid = $1 if( $errortype->{'smtp'} && $el =~ m{\ARemote host said:[ ]*(.+)\z} );
		$sorrythat = $1 if( $errortype->{'conn'} && $el =~ m{\A(Sorry, .*)\z} );

		last() if( $el =~ $RxQSBMF->{'endof'} );

	} # End of foreach(EACH_LINE)

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
		$phead .= q(X-Diagnosis: ).($rhostsaid || $sorrythat || $altofdiag ).qq(\n);

		if( $errortype->{'smtp'} )
		{
			if( $rhostsaid =~ m{\A\d{3}[-\s](\d[.]\d[.]\d+)[ ]} )
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
				my $causa = q();
				if( $smtperror->{'rcpt'} )
				{
					# RCPT TO: *** does not like recipient
					$causa = 'userunknown';
				}
				elsif( $smtperror->{'data'} || $smtperror->{'payload'} )
				{
					# failed on DATA command
					$causa = 'filtered';
				}
				elsif( $smtperror->{'mail'} || $smtperror->{'greet'} || $smtperror->{'helo'} )
				{
					# Rejected after HELO,EHLO,MAIL command
					$causa = 'rejected';
					$pstat = Kanadzuchi::RFC3463->status('rejected','p','i');
				}
				else
				{
					$causa = 'undefined';
				}

				$pstat  = Kanadzuchi::RFC3463->status( $causa, 'p', 'i' );
				$phead .= q(Status: ).$pstat.qq(\n);
			}
		}
		elsif( $errortype->{'conn'} && $statintxt )
		{
			$phead .= q(Status: ).$statintxt.qq(\n);
		}
	}

	$xsmtp ||= 'CONN';
	$phead  .= __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n) if( $phead );
	return $phead;
}

1;
__END__
