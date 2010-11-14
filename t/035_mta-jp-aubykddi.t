# $Id: 035_mta-jp-aubykddi.t,v 1.3 2010/11/13 19:13:25 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::JP::aubyKDDI;
use Test::More ( tests => 9 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::JP::aubyKDDI|,
		'methods' => [ 'xsmtpagent', 'xsmtpcommand', 'xsmtpdiagnosis',
				'xsmtpstatus', 'emailheaders', 'reperit' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Mail System Error - Returned Mail',
	'from' => '<Postmaster@ezweb.ne.jp>',
	'x-spasign' => 'NG',
	'content-type' => 'text/plain',
	'received' => [
		'from ezweb.ne.jp (wmflb12na02.ezweb.ne.jp [222.15.69.197])'.
			'by mx1.example.jp (R8/cf) with ESMTP id m87Ce7Ih030073',
			'for <user@example.or.jp>; Sun, 7 Sep 2008 21:40:07 +0900',
		'from wfilter115 (wfilter115-a0 [172.26.26.68])'.
			'by wsmtpr24.ezweb.ne.jp (EZweb Mail) with ESMTP id EF283A071'.
			'for <user@example.or.jp>; Sun,  7 Sep 2008 21:40:12 +0900 (JST)',
	],
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpagent(), 'X-SMTP-Agent: JP::aubyKDDI'.qq(\n),
		'->xsmtpagent() = X-SMTP-Agent: JP::aubyKDDI' );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: CONN'.qq(\n),
		'->xsmtpcommand() = X-SMTP-Command: CONN' );
	is( $Test->class->xsmtpdiagnosis('Test'), 'X-SMTP-Diagnosis: Test'.qq(\n),
		'->xsmtpdiagnosis() = X-SMTP-Diagnosis: Test' );
	is( $Test->class->xsmtpstatus('5.1.1'), 'X-SMTP-Status: 5.1.1'.qq(\n),
		'->xsmtpstatus() = X-SMTP-Status: 5.1.1' );
	isa_ok( $Test->class->emailheaders(), q|ARRAY|, '->emailheaders = []' );
	is( $Test->class->emailheaders()->[0], 'X-SPASIGN', 'X-SPASIGN' );
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

<this-message-rejected-by-the-domain-filter@ezweb.ne.jp>

Each of the following recipients was rejected by a remote mail server.
---------------------------------------------------
Received: from mta-022.smtp.outgoing.example.co.jp (host [192.0.2.22])
        by lsean.ezweb.ne.jp (EZweb Mail) with SMTP id 12ABCD8
        for <this-message-rejected-by-the-domain-filter@ezweb.ne.jp>; Sun,  7 Sep 2008 21:40:11 +0900 (JST)
From: user@example.or.jp
To: this-message-rejected-by-the-domain-filter@ezweb.ne.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Subject: TEST
Message-Id: <20080907124011.12ABCD8@lsean.ezweb.ne.jp>
Date: Sun,  7 Sep 2008 21:40:11 +0900 (JST)


