# $Id: 015_metadata.t,v 1.9 2010/10/05 14:04:22 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Metadata;
use Test::More ( tests => 178 );
use Path::Class::File;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $J = <DATA>;
my $Y = undef();
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Metadata|,
	'methods' => [ 'to_string','to_object', 'mergesort' ],
	'instance' => undef(), );
my $F = new Path::Class::File($T->tempdir->stringify().q{/sample-json-datum.tmp});

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	$F->dir->mkpath() unless( -d $F->dir );
	unlink( $F->stringify() ) if( -e $F->stringify() );
	$F->touch();
	printf( {$F->openw()} "%s", $J );
	$Y = JSON::Syck::LoadFile( $F->stringify() );

	can_ok( $T->class(), @{$T->methods()} );
	ok( -f $F->stringify(), q{Sample data: }.$F->stringify() );
	isa_ok( $Y, q|HASH|, q{Load file again} );
}

TO_STRING: {
	my $string = q();
	my $jsonhr = JSON::Syck::Load($J);
	my $loaded = undef();

	foreach my $j ( $Y, $jsonhr )
	{
		foreach my $f ( 0, 1 )
		{
			FROM_HASHREF: {
				$string = $T->class->to_string( $j, $f );
				$loaded = JSON::Syck::Load($$string);

				ok( length($$string), q{->to_string()} );
				isa_ok( $loaded, q|HASH|, q{Load again by JSON::Syck::Load()} );
				is( $loaded->{'addresser'}, 'postmaster@example.jp' );
			}

			FROM_ARRAYREF: {
				$string = $T->class->to_string( [$j], $f );
				$loaded = JSON::Syck::Load($$string);

				ok( length($$string), q{->to_string([])} );
				isa_ok( $loaded, q|ARRAY|, q{Load again by JSON::Syck::Load()} );
				is( $loaded->[0]->{'addresser'}, 'postmaster@example.jp' );
			}
		}
	}

	IRREGULAR_CASES: {
		is( $T->class->to_string(), q(), q{->to_string(null) is ' '} );
		is( $T->class->to_string(1), 1, q{->to_string(1) } );
		is( $T->class->to_string('string'), q(string), q{->to_string('string') } );
	}
}

TO_OBJECT: {
	my $string = q();
	my $object = undef();

	foreach my $d ( $F->stringify(), $F, \$J )
	{
		$object = $T->class->to_object($d);
		isa_ok( $object, q|ARRAY|, q{->to_object(something)} );
		is( $object->[0]->{'addresser'}, q(postmaster@example.jp) );
	}

	IRREGULAR_CASE: {
		foreach my $v ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($v) ? sprintf("%#x",ord($v)) : 'undef()';
			$object = $T->class->to_object($v);
			is( ref $object, q|ARRAY|, '->to_object('.$argv.')' );
			is( scalar @$object, 0, q{Empty Array} );
		}

		foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			$object = $T->class->to_object($n);
			is( ref $object, q|ARRAY|, '->to_object('.$n.')' );
			is( scalar @$object, 0, q{Empty Array} );
		}
	}
}

__DATA__
{ "bounced": 166222661, "addresser": "postmaster@example.jp", "recipient": "very-very-big-message-to-you@gmail.com", "senderdomain": "example.jp", "destination": "gmail.com", "reason": "mesgtoobig", "hostgroup": "webmail", "description": { "deliverystatus": "5.3.4", "timezoneoffset": "+0900", "diagnosticcode": "Test record" }, "token": "aeaaeb939a918caaef3be00f19b66506" }
