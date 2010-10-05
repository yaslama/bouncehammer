# $Id: 029_mda.t,v 1.1 2010/10/05 13:36:22 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MDA;
use Test::More ( tests => 5 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MDA|,
		'methods' => [ 'parse' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Returned mail: see transcript for details',
	'from' => 'MAILER-DAEMON',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
}

PARSE: {
	my $mesgbodypart = q();
	my $pseudoheader = q();

	$mesgbodypart .= $_ while( <DATA> );
	$pseudoheader = $Test->class->parse( $Head, \$mesgbodypart );

	isa_ok( $pseudoheader, q|HASH| );
	is( $pseudoheader->{'mda'}, 'maildrop', 'mda = maildrop' );
	is( $pseudoheader->{'reason'}, 'mailboxfull', 'reason = mailboxfull' );
	ok( $pseudoheader->{'message'}, 'error message = '.$pseudoheader->{'message'} );
}

__DATA__
maildrop: maildir over quota.
