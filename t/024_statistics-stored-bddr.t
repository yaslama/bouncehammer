# $Id: 024_statistics-stored-bddr.t,v 1.2 2010/07/02 00:06:48 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Statistics::Stored::BdDR;
use List::Util;
use Test::More ( tests => 598 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Statistics::Stored::BdDR|,
	'methods' => [
		'new', 'is_number', 'round', 'size',
		'mean', 'variance', 'stddev', 'max',
		'min', 'quartile', 'median', 'range',
		'aggregate', 'congregat' ],
	'instance' => new Kanadzuchi::Statistics::Stored::BdDR(), );


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

SKIP: {
	my $howmanyskips = 593;
	eval { require DBI; }; skip( 'Because no DBI for testing', $howmanyskips ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $howmanyskips ) if( $@ );

	require Kanadzuchi::BdDR;
	require Kanadzuchi::BdDR::Cache;
	require Kanadzuchi::BdDR::BounceLogs;
	require Kanadzuchi::BdDR::BounceLogs::Masters;
	require Kanadzuchi::Test::DBI;
	require Kanadzuchi::Mail::Stored::YAML;

	my $BdDR = undef();
	my $Btab = undef();
	my $Mtab = undef();
	my $Cdat = undef();
	my $File = './examples/hammer.1970-01-01.ffffffff.000000.tmp';
	my $Yaml = undef();
	my $Rval = 0;

	CONNECT: {
		$BdDR = Kanadzuchi::BdDR->new();
		$BdDR->setup( { 'dbname' => ':memory:', 'dbtype' => 'SQLite' } );
		$BdDR->printerror(1);
		$BdDR->connect();

		isa_ok( $BdDR, q|Kanadzuchi::BdDR| );
		isa_ok( $BdDR->handle(), q|DBI::db| );
	}

	BUILD_DATABASE: {
		ok( Kanadzuchi::Test::DBI->buildtable($BdDR->handle()), '->DBI->buildtable()' );
	}

	TABLE_OBJECTS: {
		$Btab = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $BdDR->handle() );
		$Mtab = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($BdDR->handle());
		$Cdat = Kanadzuchi::BdDR::Cache->new();

		isa_ok( $Btab, q|Kanadzuchi::BdDR::BounceLogs::Table| );
		isa_ok( $Cdat, q|Kanadzuchi::BdDR::Cache| );

		foreach my $_mt ( keys(%$Mtab) )
		{
			isa_ok( $Mtab->{$_mt}, q|Kanadzuchi::BdDR::BounceLogs::Masters::Table| );
		}
	}

	INSERT: {
		$Yaml = Kanadzuchi::Mail::Stored::YAML->loadandnew($File);
		isa_ok( $Yaml, q|Kanadzuchi::Iterator| );
		while( my $_y = $Yaml->next() )
		{
			$Rval = $_y->insert( $Btab, $Mtab, $Cdat );
			$Rval = $_y->update( $Btab, $Cdat ) unless( $Rval );
			if( $_y->senderdomain eq 'example.org' )
			{
				is( $Rval, 0, '->insert() or ->update() = 0; test data = '.$_y->recipient->address() );
			}
			else
			{
				ok( $Rval, '->insert() or ->update() test data = '.$_y->recipient->address() );
			}
		}
	}

	AGGREAGATE: {
		my $Stat = new Kanadzuchi::Statistics::Stored::BdDR( 'handle' => $BdDR->handle() );
		my $Aggr = [];

		isa_ok( $Stat, $T->class() );
		isa_ok( $Stat->handle(), q|DBI::db| );
		isa_ok( $Stat->cache(), q|ARRAY| );

		foreach my $c ( @{ $Btab->fields->{'join'} }, 'hostgroup', 'reason' )
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

		foreach my $c ( @{ $Btab->fields->{'join'} }, 'hostgroup', 'reason' )
		{
			next() if( $c eq 'addresser' );
			$Aggr = $Stat->aggregate($c);

			isa_ok( $Aggr, q|ARRAY|, 'aggregate '.$c );
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


}




