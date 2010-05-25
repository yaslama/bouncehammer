# $Id: qmail.pm,v 1.5 2010/05/25 07:40:19 ak Exp $
# Kanadzuchi::Mbox::
                         ##  ###    
  #####  ##  ##  ####         ##    
 ##  ##  ######     ##  ###   ##    
 ##  ##  ######  #####   ##   ##    
  #####  ##  ## ##  ##   ##   ##    
     ##  ##  ##  #####  #### ####   
     ##                             

# qmail: the Internet's MTA of choice - http://cr.yp.to/qmail.html
# The qmail-send Bounce Message Format (QSBMF) http://cr.yp.to/proto/qsbmf.txt
# QSBMF IS NOT COMPATIBLE WITH RFC 1894 http://www.ietf.org/rfc/rfc1894.txt
package Kanadzuchi::Mbox::qmail;
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
	'mailfrom' => qr{\AConnected[ ]to[ ].+[ ]but[ ]sender[ ]was[ ]rejected[.]\z}o,
	'rcptto' => qr{\A.+[ ]does[ ]not[ ]like[ ]recipient[.]\z}o,
	'data' => qr{\A.+[ ]failed[ ]on[ ]DATA[ ]command[.]\z}o,
	'payload' => qr{\A.+[ ]failed[ ]after[ ]I[ ]sent[ ]the[ ]message[.]\z}o,
};

my $RxConnError = {
	'nohost' => qr{\ASorry[,][ ]I[ ]couldn[']t[ ]find[ ]any[ ]host[ ]named[ ]}o,
	# 'nomxrr' => qr{\ASorry[,][ ]I[ ]couldn[']t[ ]find[ ]a[ ]mail[ ]exchanger[ ]or[ ]IP[ ]address}o,
	# 'ambimx' => qr{\ASorry[.][ ]Although I[']m listed as a best[-]preference MX or A for that host[,]}o,
};

#   ____ ____ ____ ____ ____ ____ ____ 
#  ||M |||e |||t |||h |||o |||d |||s ||
#  ||__|||__|||__|||__|||__|||__|||__||
#  |/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
sub detectus
{
	# +-+-+-+-+-+-+-+-+
	# |d|e|t|e|c|t|u|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from qmail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();

	my $se5xx = { 'mailfrom' => 0, 'rcptto' => 0, 'data' => 0, 'payload' => 0, };
	my $ce5xx = { 'nohost' => 0, };
	my $error = { 'conn' => 0, 'smtp' => 0, };

	my $phead = q();
	my $pstat = 500;
	my $qmail = 0;		# qmail ?

	my $rhostsaid = q();	# Remote host said: ...
	my $sorrythat = q();	# Sorry, ....
	my $rcptintxt = q();	# Recipient address in message body
	my $statintxt = q();	# #n.n.n Status code in message body

	EACH_LINE: foreach my $_qb ( split( qq{\n}, $$mbody ) )
	{
		if( ! $qmail && $_qb =~ $RxQSBMF->{'begin'} )
		{
			$qmail = 1;
			next();
		}

		# The line which begins with the string 'Remote host said:'
		unless( $error->{'smtp'} )
		{
			SMTP_ERROR: foreach my $_se ( keys(%$se5xx) )
			{
				if( $_qb =~ $RxSMTPError->{$_se} )
				{
					$se5xx->{$_se} = 1;
					$error->{smtp} = 1;
					last();
				}
			}
		}

		# The line which begins with the string 'Sorry,...'
		if( ! $error->{'conn'} && $_qb =~ $RxQSBMF->{'sorry'} )
		{
			CONN_ERROR: foreach my $_ce ( keys(%$ce5xx) )
			{
				if( $_qb =~ $RxConnError->{$_ce} )
				{
					$error->{$_ce} = 1;
					$error->{conn} = 1;
					last()
				}
			}
		}

		# Get a mail address from the recipient paragraph.
		$rcptintxt = $1 if( $rcptintxt eq q() && $_qb =~ m{\A[<](.+[@].+)[>][:]\z} );
		$statintxt = $1 if( $statintxt eq q() && $_qb =~ m{[ ][(][#](\d[.]\d[.]\d)[)]\z} );
		$rhostsaid = $1 if( $error->{'smtp'} && $_qb =~ m{\ARemote[ ]host[ ]said:[ ]*(.+)\z} );
		$sorrythat = $1 if( $error->{'conn'} && $_qb =~ m{\A(Sorry[,][ ].*)\z} );
	}

	# Return if it does not include the line begins with 'Hi. This is the qmail...'
	return(q{}) unless( $qmail );


	if( $error->{'smtp'} || $error->{'conn'} )
	{
		# Add the pseudo Content-Type header if it does not exist.
		$mhead->{'content-type'} ||= q(message/delivery-status);

		if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) )
		{
			$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n);
		}

		# Add the text that 'Remote host said' or 'Sorry,...' into Diagnostic-Code header.
		$phead .= q(Diagnostic-Code: ).($rhostsaid || $sorrythat).qq(\n);

		if( $error->{'smtp'} && $rhostsaid )
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
				if( $se5xx->{'rcptto'} )
				{
					# RCPT TO: <who@example.jp> ... REJECTED
					$pstat = Kanadzuchi::RFC1893->internalcode('userunknown');
				}
				elsif( $se5xx->{'payload'} )
				{
					# Rejected after DATA command
					$pstat = Kanadzuchi::RFC1893->internalcode('filtered');
				}

				$phead .= q(Status: ).Kanadzuchi::RFC1893->int2code($pstat).qq(\n);
			}
		}
		elsif( $error->{'conn'} && $statintxt )
		{
			$phead .= q(Status: ).$statintxt.qq(\n);
		}
	}

	return( $phead );
}

1;
__END__
