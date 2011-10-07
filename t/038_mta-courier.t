# $Id: 038_mta-courier.t,v 1.1.2.1 2011/10/07 06:23:14 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::Courier;
use Test::More ( tests => 12 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::Courier|,
		'methods' => [ 'xsmtpagent', 'xsmtpcommand', 'xsmtpdiagnosis', 'xsmtprecipient',
				'xsmtpstatus', 'emailheaders', 'reperit', 'SMTPCOMMAND' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'NOTICE: mail delivery status.',
	'from' => 'Mail Delivery System <MAILER-DAEMON@example.jp>',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpagent(), 'X-SMTP-Agent: Courier'.qq(\n),
		'->xsmtpagent() = X-SMTP-Agent: Courier' );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: CONN'.qq(\n),
		'->xsmtpcommand() = X-SMTP-Command: CONN' );
	is( $Test->class->xsmtpdiagnosis('Test'), 'X-SMTP-Diagnosis: Test'.qq(\n),
		'->xsmtpdiagnosis() = X-SMTP-Diagnosis: Test' );
	is( $Test->class->xsmtpstatus('5.0.0'), 'X-SMTP-Status: 5.0.0'.qq(\n),
		'->xsmtpstatus() = X-SMTP-Status: 5.0.0' );
	is( $Test->class->xsmtprecipient('user@example.jp'), 'X-SMTP-Recipient: user@example.jp'.qq(\n),
		'->xsmtprecipient() = X-SMTP-Recipient: user@example.jp' );
	isa_ok( $Test->class->emailheaders(), q|ARRAY|, '->emailheaders = []' );
	isa_ok( $Test->class->SMTPCOMMAND(), q|HASH|, '->SMTPCOMMAND = {}' );

}

REPERIT: {
	my $mesgbodypart = q();
	my $pseudoheader = q();

	$mesgbodypart .= $_ while( <DATA> );
	$pseudoheader = $Test->class->reperit( $Head, \$mesgbodypart );
	ok( $pseudoheader );
	
	foreach my $el ( split("\n", $pseudoheader) )
	{
		next() if( $el =~ m{\A\z} );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Command: [A-Z]{4}} );
		ok( $el, $el ) if( $el =~ m{Final-Recipient: } );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Status: } );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Diagnosis: } );
	}
}

__DATA__
Received: from mx.example.org 
	by mx.example.co.jp (8.14.4/8.14.4) with ESMTP id oBB3JxRJ022484
	for <hoge@example.co.jp>; Sat, 11 Dec 2010 12:20:00 +0900 (JST)
X-Virus-Status: Clean
X-Virus-Scanned: clamav-milter 0.96 at example.co.jp
X-SenderID: Sendmail Sender-ID Filter v1.0.0 mx.example.co.jp oBB3JxRJ022484
Authentication-Results: mx.example.co.jp; sender-id=pass header.from=postmaster@example.org
Received: from localhost (localhost [127.0.0.1])
  (ftp://ftp.isi.edu/in-notes/rfc1894.txt)
  by mta1.example.org with dsn; Sat, 11 Dec 2010 12:19:59 +0900
  id 0EFECD52.4D02EDDF.0000C65A
From: postmaster@example.org
To: hoge@example.co.jp
Subject: NOTICE: mail delivery status.
Mime-Version: 1.0
Content-Type: multipart/report; report-type=delivery-status;
    boundary="=_courier_0"
Content-Transfer-Encoding: 7bit
Message-ID: <courier.4D02EDDF.0000C65A@mta1.example.org>
Date: Sat, 11 Dec 2010 12:19:59 +0900

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_courier_0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii


This is a delivery status notification from mta1.example.org,
running the Courier mail server, version 0.65.2.

The original message was received on Sat, 11 Dec 2010 12:19:57 +0900
from [127.0.0.1]

---------------------------------------------------------------------------

                           UNDELIVERABLE MAIL

Your message to the following recipients cannot be delivered:

<userunknown@example.jp>:
    mx.example.jp [192.0.2.3]:
>>> RCPT TO:<userunknown@example.jp>
<<< 550 5.1.1 <userunknown@example.jp>... User Unknown

---------------------------------------------------------------------------

If your message was also sent to additional recipients, their delivery
status is not included in this report.  You may or may not receive
other delivery status notifications for additional recipients.

The original message follows as a separate attachment.


--=_courier_0
Content-Type: message/delivery-status
Content-Transfer-Encoding: 7bit

Reporting-MTA: dns; mta1.example.org
Arrival-Date: Sat, 11 Dec 2010 12:19:57 +0900
Received-From-MTA: dns; [127.0.0.1]

Final-Recipient: rfc822; userunknown@example.jp
Action: failed
Status: 5.0.0
Remote-MTA: dns; mx.example.jp [192.0.2.3]
Diagnostic-Code: smtp; 550 5.1.1 <userunknown@example.jp>... User Unknown

--=_courier_0
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit

Received: from [127.0.0.1] 
  by mta1.example.org with SMTP; Sat, 11 Dec 2010 12:19:17 +0900
  id 0EFECD4E.4D02EDD9.0000C5BA
To: undisclosed-recipients: ;

--=_courier_0--

