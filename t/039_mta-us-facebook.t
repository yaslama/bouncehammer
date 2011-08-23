# $Id: 039_mta-us-facebook.t,v 1.1.2.1 2011/08/23 12:35:44 ak Exp $
# -Id: 034_mta-google.t,v 1.2 2010/10/05 11:30:56 ak Exp -
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::US::Facebook;
use Test::More ( tests => 13 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::US::Facebook|,
		'methods' => [ 'xsmtpagent', 'xsmtpcommand', 'xsmtpdiagnosis',
				'xsmtpstatus', 'emailheaders', 'reperit', 'SMTPCOMMAND' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Sorry, your message could not be delivered',
	'from' => 'Facebook <mailer-daemon@mx.facebook.com>',
	'date' => 'Fri, 17 Jul 2009 07:24:12 -0700 (PDT)',
	'to' => 'postmaster@example.com',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpagent(), 'X-SMTP-Agent: US::Facebook'.qq(\n),
		'->xsmtpagent() = X-SMTP-Agent: US::Facebook' );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: CONN'.qq(\n),
		'->xsmtpcommand() = X-SMTP-Command: CONN' );
	is( $Test->class->xsmtpdiagnosis('Test'), 'X-SMTP-Diagnosis: Test'.qq(\n), 
		'->xsmtpdiagnosis() = X-SMTP-Diagnosis: Test' );
	is( $Test->class->xsmtpstatus('5.1.1'), 'X-SMTP-Status: 5.1.1'.qq(\n),
		'->xsmtpstatus() = X-SMTP-Status: 5.1.1' );
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
		ok( $el, $el ) if( $el =~ m{X-SMTP-Agent: } );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Command: [A-Z]{4}} );
		ok( $el, $el ) if( $el =~ m{Arrival-Date: } );
		ok( $el, $el ) if( $el =~ m{Final-Recipient: } );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Status: } );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Diagnosis: } );
		ok( $el, $el ) if( $el =~ m{To: } );
	}
}

__DATA__

--sn/yogdleEAO11VkUgc2e3qqW/xjCUPJ2jX2rQ==
Content-Type: text/plain; charset=UTF-8

This message was created automatically by Facebook.

Based on the email preferences of the person you're trying to email, this message could not be delivered.

--sn/yogdleEAO11VkUgc2e3qqW/xjCUPJ2jX2rQ==
Content-Type: message/delivery-status

Reporting-MTA: dns; 10.138.205.200
Arrival-Date: Thu, 23 Jun 2011 02:29:43 -0700

Diagnostic-Code: smtp; 550 5.1.1 RCP-P2 http://postmaster.facebook.com/response_codes?ip=125.174.90.135#rcp Refused due to recipient preferences
Status: 5.1.1
Final-Recipient: rfc822; username@facebook.com
Last-Attempt-Date: Thu, 23 Jun 2011 02:30:13 -0700
Action: failed

--sn/yogdleEAO11VkUgc2e3qqW/xjCUPJ2jX2rQ==
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

TEST FOR FACEBOOK BLOCK
--sn/yogdleEAO11VkUgc2e3qqW/xjCUPJ2jX2rQ==--

