# $Id: 025_statistics-stored-yaml.t,v 1.5 2010/10/24 06:42:01 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Statistics::Stored::YAML;
use Path::Class::File;
use Test::More ( tests => 922 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Statistics::Stored::YAML|,
	'methods' => [
		'new', 'is_number', 'round', 'size', 'load',
		'mean', 'variance', 'stddev', 'max',
		'min', 'quartile', 'median', 'range',
		'aggregate', 'congregat', ],
	'instance' => new Kanadzuchi::Statistics::Stored::YAML(), );


#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class );
	can_ok( $T->class(), @{$T->methods} );

	isa_ok( $T->instance->sample, q|ARRAY|, $T->class.q{->sample()} );
	is( $T->instance->unbiased(), 1, $T->class.q{->unbiased()} );
	is( $T->instance->rounding(), 4, $T->class.q{->rounding()} );
}
# 5 tests

my $File = './examples/hammer.1970-01-01.ffffffff.000000.tmp';
my $Yaml = undef();
my $Stat = undef();
my $Aggr = [];

CONSTRUCTOR: {
	# file = String
	$Stat = new Kanadzuchi::Statistics::Stored::YAML( 'file' => $File );
	isa_ok( $Stat, $T->class() );
	isa_ok( $Stat->data(), q|ARRAY| );
	isa_ok( $Stat->cache(), q|ARRAY| );
	ok( scalar @{ $Stat->data() }, 'data size = '.scalar(@{ $Stat->data() }) );

	# file = String in array reference
	$Stat = new Kanadzuchi::Statistics::Stored::YAML( 'file' => [$File] );
	isa_ok( $Stat, $T->class() );
	isa_ok( $Stat->data(), q|ARRAY| );
	isa_ok( $Stat->cache(), q|ARRAY| );
	ok( scalar @{ $Stat->data() }, 'data size = '.scalar(@{ $Stat->data() }) );

	$Yaml = new Path::Class::File( $File );
	isa_ok( $Yaml, q|Path::Class::File| );

	# file = Path::Class::File object
	$Stat = new Kanadzuchi::Statistics::Stored::YAML( 'file' => $Yaml );
	isa_ok( $Stat, $T->class() );
	isa_ok( $Stat->data(), q|ARRAY| );
	isa_ok( $Stat->cache(), q|ARRAY| );
	ok( scalar @{ $Stat->data() }, 'data size = '.scalar(@{ $Stat->data() }) );

	# Set the file after new()
	$Stat = new Kanadzuchi::Statistics::Stored::YAML();
	isa_ok( $Stat, $T->class() );
	isa_ok( $Stat->data(), q|ARRAY| );
	isa_ok( $Stat->cache(), q|ARRAY| );
	$Stat->file( $File );
	$Stat->load();
	ok( scalar @{ $Stat->data() }, 'data size = '.scalar(@{ $Stat->data() }) );

	# Set the file as an array reference after new()
	$Stat = new Kanadzuchi::Statistics::Stored::YAML();
	isa_ok( $Stat, $T->class() );
	isa_ok( $Stat->data(), q|ARRAY| );
	isa_ok( $Stat->cache(), q|ARRAY| );
	$Stat->file( [$File,$File] );
	$Stat->load();
	ok( scalar @{ $Stat->data() }, 'data size = '.scalar(@{ $Stat->data() }) );

	foreach my $e ( @{ $Stat->data() } )
	{
		foreach my $x ( qw{senderdomain destination hostgroup provider reason frequency} )
		{
			ok( $e->{ $x }, $x.' = '.$e->{ $x } );
		}
	}
}

AGGREAGATE: {

	foreach my $c ( qw{senderdomain destination hostgroup provider reason} )
	{
		$Aggr = $Stat->congregat($c);

		isa_ok( $Aggr, q|ARRAY|, '->congregat '.$c );
		foreach my $e ( @$Aggr )
		{
			like( $e->{'name'}, qr{\A[a-z]}, '->congregat('.$c.')->name = '.$e->{'name'} );
			ok( ( $e->{'size'} > -1 ), '->congregat('.$c.')->size = '.$e->{'size'} );
			ok( ( $e->{'freq'} > -1 ), '->congregat('.$c.')->freq = '.$e->{'freq'} );
		}
	}

	foreach my $c ( qw{senderdomain destination hostgroup provider reason} )
	{
		$Aggr = $Stat->aggregate($c);

		isa_ok( $Aggr, q|ARRAY|, 'aggregate = '.$c );
		foreach my $e ( @$Aggr )
		{
			like( $e->{'name'}, qr{\A[a-z]}, '->aggregate('.$c.')->name = '.$e->{'name'} );
			ok( ( $e->{'size'} > -1 ), '->aggregate('.$c.')->size = '.$e->{'size'} );
			ok( ( $e->{'freq'} > -1 ), '->aggregate('.$c.')->freq = '.$e->{'freq'} );
		}
	}

	foreach my $k ( 'size', 'freq' )
	{
		$Stat->sample( [ map { $_->{ $k } } @{ $Stat->cache } ] );
		ok( $Stat->size(), '->size = '.$Stat->size() );
		ok( $Stat->mean(), '->mean = '.$Stat->mean() );
		ok( $Stat->var(), '->var= '.$Stat->var() );
		ok( $Stat->stddev(), '->stddev= '.$Stat->stddev() );
		ok( $Stat->range(), '->range = '.$Stat->range() );
	}
}

