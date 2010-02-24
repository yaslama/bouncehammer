# $Id: 017_rfc2606.t,v 1.1 2010/02/22 20:10:21 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RFC2606;
use Test::More ( tests => 65 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RFC2606|,
	'methods' => [ 'is_rfc2606', 'is_reserved', ],
	'instance' => undef(), );

my $ok = {
	'rfc2606' => [ 'example.com', 'example.net', 'example.org', 'a.invalid', 'b.localhost', 'c.test' ],
	'reserved' => [ 'example.jp', 'example.ac.jp', 'example.ad.jp', 'example.co.jp', 'example.ed.jp',
			'example.go.jp', 'example.gr.jp', 'example.lg.jp', 'example.ne.jp', 'example.ne.jp' ],
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $T->class(), @{$T->methods()} );
}

CLASS_METHODS: {
	my $class = $T->class();

	foreach my $d ( @{$ok->{'rfc2606'}} )
	{
		VALID_RFC2606: {
			ok( $class->is_rfc2606($d), q{->is_rfc2606(}.$d.q{)} );
			ok( $class->is_reserved($d), q{->is_reserved(}.$d.q{)} );
		}

		INVALID_RFC2606: {
			$d .= 'x';
			is( $class->is_rfc2606($d),0, q{->is_rfc2606(}.$d.q{)} );
			is( $class->is_reserved($d),0, q{->is_reserved(}.$d.q{)} );
		}
	}

	foreach my $d ( @{$ok->{'reserved'}} )
	{
		VALID_RFC2606: {
			is( $class->is_rfc2606($d), 0, q{->is_rfc2606(}.$d.q{)} );
			ok( $class->is_reserved($d), q{->is_reserved(}.$d.q{)} );
		}

		INVALID_RFC2606: {
			$d .= 'x';
			is( $class->is_rfc2606($d),0, q{->is_rfc2606(}.$d.q{)} );
			is( $class->is_reserved($d),0, q{->is_reserved(}.$d.q{)} );
		}
	}
}

__END__
