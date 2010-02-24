# $Id: 101_rdb-table.t,v 1.2 2009/12/17 20:45:05 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RDB::Table;
use Test::More ( tests => 71 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RDB::Table|,
	'methods' => [ '_is_validid', '_is_validcolumn', 'new', 
			'getidbyname', 'getnamebyid', 'getthenextid',
			'select', 'insert', 'update', 'remove' ],
	'instance' => new Kanadzuchi::RDB::Table(),
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

	CONSTRUCTOR: {
		is( $object->table(), q(), q{->table() } );
		is( $object->field(), q(), q{->field() } );
	}

	FAILURE: {
		foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
			is( $object->_is_validcolumn( $e ), 0, q{->_is_validcolumn() = }.$argv );
		}
	}
}
__END__

