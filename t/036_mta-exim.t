# $Id: 036_mta-exim.t,v 1.1 2010/10/05 11:30:56 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::Exim;
use Test::More ( tests => 8 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::Exim|,
		'methods' => [ 'xsmtpcommand', 'emailheaders', 'reperit' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Mail delivery failed: returning message to sender',
	'from' => 'Mail Delivery System <MAILER-DAEMON@example.jp>',
	'x-failed-recipients' => 'useruknown@example.jp',
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
		ok( $el, $el ) if( $el =~ m{X-Diagnosis: } );
	}
}

__DATA__
This message was created automatically by mail delivery software.

A message that you sent could not be delivered to one or more of its
recipients. This is a permanent error. The following address(es) failed:

  userunknown@example.jp
    SMTP error from remote mail server after RCPT TO:<userunknown@example.jp>:
    host mx.example.jp [192.0.2.22]: 550 5.1.1 <userunknown@example.jp>... User Unknown

------ This is a copy of the message, including all the headers. ------

Return-path: <hoge@example.org>
Received: from localhost ([127.0.0.1])
	by fuga.example.org with smtp (Exim 4.72)
	(envelope-from <hoge@example.org>)
	id 1P1YNN-0003AD-Ga
	for userunknown@example.jp; Fri, 01 Oct 2010 14:42:09 +0900
Date: Fri, 01 Oct 2010 14:42:07 +0900
Message-Id: <E1P1YNN-0003AD-Ga@fuga.example.org>
Sujbect: test2
From: fuga@example.org
To: userunknown@example.jp

test2

