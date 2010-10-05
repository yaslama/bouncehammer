# $Id: 032_mta-postfix.t,v 1.2 2010/10/05 11:30:56 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::Postfix;
use Test::More ( tests => 11 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::Postfix|,
		'methods' => [ 'xsmtpcommand', 'emailheaders', 'reperit' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Undelivered Mail Returned to Sender',
	'from' => 'MAILER-DAEMON@example.net (Mail Delivery System)',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: ', '->xsmtpcommand() = X-SMTP-Command:' );
	isa_ok( $Test->class->emailheaders(), q|ARRAY|, '->emailheaders = []' );
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
		ok( $el, $el ) if( $el =~ m{Arrival-Date: } );
		ok( $el, $el ) if( $el =~ m{Final-Recipient: } );
		ok( $el, $el ) if( $el =~ m{Status: } );
		ok( $el, $el ) if( $el =~ m{Diagnostic-Code: } );
		ok( $el, $el ) if( $el =~ m{X-Diagnosis: } );
		ok( $el, $el ) if( $el =~ m{From: } );
		ok( $el, $el ) if( $el =~ m{To: } );
	}
}

__DATA__

This is a MIME-encapsulated message.

--FFFFFFFFFFFF.1111111111/example.net
Content-Description: Notification
Content-Type: text/plain; charset=us-ascii

This is the mail system at host example.net.

I'm sorry to have to inform you that your message could not
be delivered to one or more recipients. It's attached below.

For further assistance, please send mail to postmaster.

If you do so, please include this problem report. You can
delete your own text from the attached returned message.

                   The mail system

<user@example.int>: host mta.example.int[192.0.2.1] said: 550
    Unknown user user@example.int (in reply to end of DATA command)

--FFFFFFFFFFFF.1111111111/example.net
Content-Description: Delivery report
Content-Type: message/delivery-status

Reporting-MTA: dns; example.net
X-Postfix-Queue-ID: FFFFFFFFFFFF
X-Postfix-Sender: rfc822; postfix@example.net
Arrival-Date: Thu, 29 Apr 2010 13:17:23 +0900 (JST)

Final-Recipient: rfc822; user@example.int
Original-Recipient: rfc822;user@example.int
Action: failed
Status: 5.0.0
Remote-MTA: dns; mta.example.int
Diagnostic-Code: smtp; 550 Unknown user user@example.int

--FFFFFFFFFFFF.1111111111/example.net
Content-Description: Undelivered Message
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit

Received: from localhost (localhost.localdomain [127.0.0.1])
	by example.net (Postfix) with ESMTP id FFFFFFFFFFFF
	for <user@example.int>; Thu, 29 Apr 2010 13:17:23 +0900 (JST)
Received: from example.net ([127.0.0.1])
	by localhost (example.net [127.0.0.1])
	with ESMTP id xxxxxxxxxxxx for <user@example.int>;
	Thu, 29 Apr 2010 13:17:23 +0900 (JST)
Received: by example.net (Postfix, from userid 250)
	id FFFFFFFFFFFF; Thu, 29 Apr 2010 13:17:23 +0900 (JST)
To: user@example.int
Subject: Bounce
From:who@example.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Apr 2010 13:17:23 +0900 (JST)


