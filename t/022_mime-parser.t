# $Id: 022_mime-parser.t,v 1.3 2010/07/07 09:05:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MIME::Parser;
use Test::More ( tests => 99 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::MIME::Parser|,
	'methods' => [ 'new', 'parseit', 'flush', 'count', 'getit' ],
	'instance' => new Kanadzuchi::MIME::Parser(),
);


#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class() );
	can_ok( $T->class(), @{$T->methods()} );
}

CONSTRUCTOR: {
	my $object = new Kanadzuchi::MIME::Parser();
	isa_ok( $object, $T->class );
	isa_ok( $object->data, q|HASH| );
}

METHODS: {
	my $htext = << 'EOH';
Final-Recipient: user01@example.org
From: sender@example.jp
Return-Path: <>
Received: host1 
Received: host2
Received: host3
To: user01@example.org, user02@example.org
Status: 5.1.1
X-Test: 
EOH
	my $object = new Kanadzuchi::MIME::Parser();

	REGULAR_CASES: {
		$object->parseit( \$htext );

		is( $object->count(), 6, '->count() = 6' );

		is( $object->getit('Final-Recipient'), 'user01@example.org', 'Final-Recipient: user01@example.org' );
		is( $object->getit('From'), 'sender@example.jp', 'From: sender@example.jp' );
		is( $object->getit('Return-Path'), '<>', 'Return-Path: <>' );
		is( $object->getit('Received'), 'host1', 'Received: host1' );
		is( $object->getit('To'), 'user01@example.org, user02@example.org', 'To: user01@example.org, user02@example.org' );
		is( $object->getit('Status'), '5.1.1', 'Status: 5.1.1' );
		is( $object->getit('X-Test'), q(), 'X-Test: ' );

		my @return = ();
		foreach my $h ( qw(Final-Recipient From Return-Path Received To Status X-Test) )
		{
			@return = $object->getit($h);
			ok( scalar @return, $h.' = '.scalar(@return).' entities');

			while( my $e = shift(@return) )
			{
				ok( $e, $h.' = '.$e );
			}
		}

		$object->flush();
		is( $object->count(), 0, '->flush->count() = 0' );
	}

	IRREGULAR_CASES: {
		FALSE: foreach my $f ( @{$Kanadzuchi::Test::FalseValues}, @{$Kanadzuchi::Test::ZeroValues} )
		{
			my $argv = defined($f) ? sprintf("%#x",ord($f)) : 'undef()';
			$object->parseit( \$f );
			is( $object->count(), 0, q{->parseit(}.$argv.q{)->count = }.0 );
			$object->flush();
		}

		NEGATIVE: foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			$object->parseit( \$n );
			is( $object->count(), 0, q{->parseit(}.$n.q{)->count = }.0 );
			$object->flush();
		}

		CONTORL: foreach my $c ( @{$Kanadzuchi::Test::EscapeCharacters}, @{$Kanadzuchi::Test::ControlCharacters} )
		{
			my $argv = defined($c) ? sprintf("%#x",ord($c)) : 'undef()';
			$object->parseit( \$c );
			is( $object->count(), 0, q{->parseit(}.$argv.q{)->count = }.0 );
			$object->flush();
		}
	}
}

__END__

