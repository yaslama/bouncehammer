# $Id: 023_statistics-stored.t,v 1.1 2010/06/25 19:29:20 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Statistics::Stored;
use Path::Class::File;
use Test::More ( tests => 6 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Statistics::Stored|,
	'methods' => [
		'new', 'is_number', 'round', 'size',
		'mean', 'variance', 'stddev', 'max',
		'min', 'quartile', 'median', 'range',
		'congregat', 'aggregate',  ],
	'instance' => new Kanadzuchi::Statistics::Stored(), );


#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class );
	can_ok( $T->class(), @{$T->methods} );

	isa_ok( $T->instance->sample, q|ARRAY|, $T->class.q{->sample()} );
	isa_ok( $T->instance->cache, q|ARRAY|, $T->class.q{->cache()} );
	is( $T->instance->unbiased(), 1, $T->class.q{->unbiased()} );
	is( $T->instance->rounding(), 4, $T->class.q{->rounding()} );
}

