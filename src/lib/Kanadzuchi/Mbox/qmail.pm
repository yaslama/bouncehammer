# $Id: qmail.pm,v 1.1 2010/04/01 08:04:50 ak Exp $
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
};

my $RxRemoteError = {
	'greet' => qr{\AConnected[ ]to[ ].+[ ]but[ ]greeting[ ]failed[.]\z}o,
	'helo' => qr{\AConnected[ ]to[ ].+[ ]but[ ]my[ ]name[ ]was[ ]rejected[.]\z}o,
	'mailfrom' => qr{\AConnected[ ]to[ ].+[ ]but[ ]sender[ ]was[ ]rejected[.]\z}o,
	'rcptto' => qr{\A.+[ ]does[ ]not[ ]like[ ]recipient[.]\z}o,
	'data' => qr{\A.+[ ]failed[ ]on[ ]DATA[ ]command[.]\z}o,
	'payload' => qr{\A.+[ ]failed[ ]after[ ]I[ ]sent[ ]the[ ]message[.]\z}o,
};

my $RxLocalError = {};

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
	# @Param <ref>	(Ref->MIME::Head) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();

	my $re5xx = { 'mailfrom' => 0, 'rcptto' => 0, 'data' => 0, 'payload' => 0, };
	my $error = { 'remote' => 0, 'local' => 0, };

	my $phead = q();
	my $pstat = 500;
	my $qmail = 0;		# qmail ?

	my $rhostsaid = q();	# Remote host said: ...
	my $rcptintxt = q();	# Recipient address in message body

	EACH_LINE: foreach my $_qb ( split( qq{\n}, $$mbody ) )
	{
		$qmail = 1 if( $_qb =~ $RxQSBMF->{'begin'} );

		# The line which begins with the string 'Remote host said:'
		REMOTE_ERROR: foreach my $_ek ( keys(%$re5xx) )
		{
			if( $_qb =~ $RxRemoteError->{$_ek} )
			{
				$re5xx->{$_ek} = 1;
				$error->{'remote'} = 1;
				last();
			}
		}

		# Get a mail address from the recipient paragraph.
		$rcptintxt = $1 if( $_qb =~ m{\A[<](.+[@].+)[>][:]\z} );
		$rhostsaid = $1 if( $_qb =~ m{\ARemote[ ]host[ ]said:[ ]*(.+)\z} );
	}

	# Return if it does not include the line begins with 'Hi. This is the qmail...'
	return(q{}) unless( $qmail );


	if( $error->{'remote'} || $error->{'local'} )
	{
		# Add the pseudo Content-Type header if it does not exist.
		$mhead->{'content-type'} ||= q(message/delivery-status);

		if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) )
		{
			$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n);
		}

		if( $error->{'remote'} && $rhostsaid )
		{
			$phead .= q(Diagnostic-Code: ).$rhostsaid.qq(\n);

			if( $rhostsaid =~ m{\A\d{3}[-\s](\d[.]\d[.]\d)[ ]} )
			{
				# Remote host said: 550-5.1.1 The email account ...
				$phead .= q(Status: ).$1.qq(\n);
			}
			else
			{
				if( $re5xx->{'rcptto'} )
				{
					# RCPT TO: <who@example.jp> ... REJECTED
					$pstat = Kanadzuchi::RFC1893->internalcode('userunknown');
				}
				elsif( $re5xx->{'payload'} )
				{
					$pstat = Kanadzuchi::RFC1893->internalcode('filtered');
				}

				$phead .= qq(Status: ).Kanadzuchi::RFC1893->int2code($pstat).qq(\n);
			}
		}
		elsif( $error->{'local'} )
		{

		}

	}

	return( $phead );
}

1;
__END__
