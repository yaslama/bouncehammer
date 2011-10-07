# $Id: 040_mta-jp-biglobe.t,v 1.1.2.2 2011/10/07 06:23:14 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::JP::Biglobe;
use Test::More ( tests => 12 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::JP::Biglobe|,
		'methods' => [ 'xsmtpagent', 'xsmtpcommand', 'xsmtpdiagnosis', 'xsmtprecipient',
				'xsmtpstatus', 'emailheaders', 'reperit', 'SMTPCOMMAND' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Returned mail: Service unavailable',
	'from' => 'postmaster@biglobe.ne.jp',
	'content-type' => 'text/plain',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpagent(), 'X-SMTP-Agent: JP::Biglobe'.qq(\n),
		'->xsmtpagent() = X-SMTP-Agent: JP::Biglobe' );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: CONN'.qq(\n),
		'->xsmtpcommand() = X-SMTP-Command: CONN' );
	is( $Test->class->xsmtpdiagnosis('Test'), 'X-SMTP-Diagnosis: Test'.qq(\n),
		'->xsmtpdiagnosis() = X-SMTP-Diagnosis: Test' );
	is( $Test->class->xsmtpstatus('5.1.1'), 'X-SMTP-Status: 5.1.1'.qq(\n),
		'->xsmtpstatus() = X-SMTP-Status: 5.1.1' );
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

This is a MIME-encapsulated message.

----_Biglobe000000/00000.biglobe.ne.jp
Content-Type: text/plain; charset="iso-2022-jp"

   ----- The following addresses had delivery problems -----
user@aaa.biglobe.ne.jp

   ----- Non-delivered information -----
The number of messages in recipient's mailbox exceeded the local limit.

----_Biglobe000000/00000.biglobe.ne.jp
Content-Type: message/rfc822

Received: from rcpt-impgw.biglobe.ne.jp by biglobe.ne.jp (RCPT_GW)
	id MAA30594; Mon, 07 Jan 2008 12:44:53 +0900 (JST)
Message-ID: <44444441111111114ddddddddiiiix@aaaaa.bbbbb>
From: "bounce@example.net" <bounce@example.net>
To: "satb" <user@aaa.biglobe.ne.jp>
Subject: TEST
Date: Mon, 17 Jul 2010 08:39:46 +0400
MIME-Version: 1.0
X-Priority: 3


mesg
