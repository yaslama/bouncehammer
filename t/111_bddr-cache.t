# $Id: 111_bddr-cache.t,v 1.2 2010/06/21 09:52:59 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::BdDR::Cache;
use Digest::MD5;
use Test::More ( tests => 928 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::BdDR::Cache|,
	'methods' => [ 'new', 'cache', 'count', 'getit', 'setit', 'purgeit' ],
	'instance' => new Kanadzuchi::BdDR::Cache(),
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

METHODS: {
	my $object = $T->instance();
	my $tables = [ qw(t_bouncelogs t_addressers t_senderdomains t_hostgroups 
			t_reasons t_destinations t_providers) ];
	my $kvpair = { map { Digest::MD5->new->add($_)->hexdigest() => time() } 'a'..'z' };
	my $cached = undef();
	my $cachek = q();
	my $cachev = q();

	CONSTRUCTOR: {
		isa_ok( $object->cache(), q|HASH|, '->cache() is HASH reference' );
		isa_ok( $object->count(), q|HASH|, '->count() is HASH reference' );
	}

	GETIT: {
		foreach my $_t ( @$tables )
		{
			is( $object->getit($_t, 'x'), undef(), '->getit(x) = undef' );
			is( $object->count->{'x'}, undef(), '->count(x) = undef' );
		}
	}

	SETIT: {
		foreach my $_t ( @$tables )
		{
			foreach my $_k ( keys(%$kvpair) )
			{
				$object->setit( $_t, $_k, $kvpair->{$_k} );
			}
		}
	}

	GETIT_AGAIN: {
		foreach my $_t ( @$tables )
		{
			foreach my $_k ( keys(%$kvpair) )
			{
				$cachev = $object->getit( $_t, $_k );
				is( $cachev, $kvpair->{$_k}, '->getit('.$_k.') = '.$cachev );
				ok( $object->count->{$_t}, '->count('.$_t.') = '.$object->count->{$_t} );
			}
		}
	}

	PURGEIT: {
		foreach my $_t ( @$tables )
		{
			foreach my $_k ( keys(%$kvpair) )
			{
				$cached = $object->purgeit( $_t, $_k );
				isa_ok( $cached, $T->class() );
				$cachev = $object->getit( $_t, $_k );
				is( $cachev, undef(), 'purgeit->getit('.$_k.') = undef' );
				ok( ( $object->count->{$_t} > -1 ), '->count('.$_t.') = '.$object->count->{$_t} );
			}
		}
	}

}

__END__
