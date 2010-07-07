# $Id: 033_mta-qmail.t,v 1.1 2010/07/07 04:42:44 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::qmail;
use Test::More ( tests => 8 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::qmail|,
		'methods' => [ 'xsmtpcommand', 'emailheaders', 'reperit' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'failure notice',
	'from' => 'MAILER-DAEMON@example.jp',
	'received' => [
		'(qmail 3622 invoked for bounce); 29 Apr 2010 08:18:21 -0000',
	],
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
		ok( $el, $el ) if( $el =~ m{Final-Recipient: } );
		ok( $el, $el ) if( $el =~ m{Status: } );
		ok( $el, $el ) if( $el =~ m{Diagnostic-Code: } );
	}
}

__DATA__
Hi. This is the qmail-send program at mx.example.jp.
I'm afraid I wasn't able to deliver your message to the following addresses.
This is a permanent error; I've given up. Sorry it didn't work out.

<userunknown@example.org>:
192.0.2.35 does not like recipient.
Remote host said: 550 5.1.1 <userunknown@example.org>... User Unknown
Giving up on 192.0.2.35

--- Below this line is a copy of the message.

Return-Path: <root@mx.example.jp>
Received: (qmail 3620 invoked by uid 0); 29 Apr 2010 08:18:19 -0000
Date: 29 Apr 2010 08:18:19 -0000
Message-ID: <20090429081819.3619.qmail@mx.example.jp>
From: root@mx.example.jp
to: userunknown@example.org

