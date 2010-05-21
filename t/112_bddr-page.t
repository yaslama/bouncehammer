# $Id: 112_bddr-page.t,v 1.2 2010/05/19 18:25:14 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::BdDR::Page;
use Test::More ( tests => 89 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::BdDR::Page|,
	'methods' => [ 'new', 'set', 'skip', 'reset', 'count', 'hasnext', 
			'next', 'prev', 'to_hashref', 'to_sql' ],
	'instance' => new Kanadzuchi::BdDR::Page(),
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
	my $string = q();
	my $pcount = 1;
	my $offset = 0;
	my $values = [
		'currentpagenum',	# (Integer) Current page number
		'resultsperpage',	# (Integer) The number of results a page
		'colnameorderby',	# (String) Column name used 'ORDER BY'
		'descendorderby',	# (Integer) 1 = DESC, 0 = Not descending
		'numofrecordsin',	# (Integer) The number of records in the DB
		'lastpagenumber',	# (Integer) Last page number
		'offsetposition',	# (Integer) OFFSET position number
	];

	CONSTRUCTOR: {
		is( $object->currentpagenum(), 1,   '->currentpagenum() = 1' );
		is( $object->resultsperpage(), 10,  '->resultsperpage() = 10');
		is( $object->colnameorderby(), 'id','->colnameorderby() = id');
		is( $object->descendorderby(), 0,   '->descendorderby() = 0' );
		is( $object->numofrecordsin(), 0,   '->numofrecordsin() = 0' );
		is( $object->lastpagenumber(), 0,   '->lastpagenumber() = 0' );
		is( $object->offsetposition(), 0,   '->offsetposition() = 0' );
	}

	PAGINATION: {
		$object->set(100);
		is( $object->lastpagenumber(), 10, '->set->lastpagenumber = 10' );
		is( $object->currentpagenum(), $pcount, '->currentpagenum() = '.$pcount );

		COUNT: {
			is( $object->count(), 100, '->count() = 100');
		}

		NEXT: while(1)
		{
			$offset = ( $pcount - 1 ) * $object->resultsperpage();

			is( $object->currentpagenum(), $pcount, '->next->currentpagenum() = '.$pcount );
			is( $object->offsetposition(), $offset, '->next->offsetposition() = '.$offset );
			ok( $object->hasnext(), '->hasnext()' ) if( $pcount < $object->lastpagenumber() );

			last() unless($object->next());
			$pcount++;
		}

		PREV: while(1)
		{
			$offset = ( $pcount - 1 ) * $object->resultsperpage();

			is( $object->currentpagenum(), $pcount, '->prev->currentpagenum() = '.$pcount );
			is( $object->offsetposition(), $offset, '->prev->offsetposition() = '.$offset );
			ok( $object->hasnext(), '->hasnext()' ) if( $pcount < $object->lastpagenumber() );

			last() unless($object->prev());
			$pcount--;
		}

		SKIP: foreach my $_p ( 2, 4, 6, 8, 10 )
		{
			$object->skip($_p);
			$offset = ( $_p - 1 ) * $object->resultsperpage();

			is( $object->currentpagenum(), $_p, '->currentpagenum() = '.$_p);
			is( $object->offsetposition(), $offset, '->offsetposition() = '.$offset );
		}

		TO_X: {
			$string = $object->to_hashref();
			isa_ok( $string, q|HASH|, '->to_hashref() = HASH' );

			$string = $object->to_sql();
			ok( length($string), '->to_sql() = '.$string );
		}

		RESET: {
			$object->reset();
			is( $object->currentpagenum(), 1,   '->reset->currentpagenum() = 1' );
			is( $object->resultsperpage(), 10,  '->reset->resultsperpage() = 10');
			is( $object->colnameorderby(), 'id','->reset->colnameorderby() = id');
			is( $object->descendorderby(), 0,   '->reset->descendorderby() = 0' );
			is( $object->numofrecordsin(), 0,   '->reset->numofrecordsin() = 0' );
			is( $object->lastpagenumber(), 0,   '->reest->lastpagenumber() = 0' );
			is( $object->offsetposition(), 0,   '->reset->offsetposition() = 0' );
		}
	}


}

__END__
