# $Id: 100_rdb.t,v 1.6 2010/04/23 19:45:04 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RDB;
use Kanadzuchi::RDB::Schema;
use JSON::Syck;
use Test::More ( tests => 259 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RDB|,
	'methods' => [ 'new', 'setup', 'makecache' ],
	'instance' => new Kanadzuchi::RDB(),
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
	my $object = undef();
	my $config = JSON::Syck::LoadFile( q{./src/etc/prove.cf} );
	my $therdb = q(:memory:);
	my $datasn = q();
	my $rdbset = {
		'PostgreSQL' => { 'driver' => 'Pg', 'port' => 5432, 'short' => 'p', },
		'MySQL' => { 'driver' => 'mysql', 'port' => 3306, 'short' => 'm', },
		'SQLite' => { 'driver' => 'SQLite', 'port' => undef(), 'short' => 's', 'dbname' => $therdb },
	};

	foreach my $d ( keys(%$rdbset) )
	{
		$object = new Kanadzuchi::RDB();
		$config->{'database'}->{'hostname'} = q(127.0.0.1);
		$config->{'database'}->{'dbname'} = $rdbset->{$d}->{'dbname'} || q(bouncehammer) ;
		$config->{'database'}->{'username'} = q(bouncehammer);
		$config->{'database'}->{'password'} = q(kanadzuchi);
		$config->{'database'}->{'port'} = $rdbset->{$d}->{'port'};
		$config->{'database'}->{'dbtype'} = $d;

		CONSTRUCTOR: {
			isa_ok( $object->records(), q|ARRAY|, q{->records()} );
			isa_ok( $object->cache(), q|HASH|, q{->cache()} );
			is( $object->count(), 0, q{->count() = 0} );
		}

		SETUP: {
			ok( $object->setup( $config->{'database'}, q{->setup()} ) );

			is( $object->hostname(), q(127.0.0.1), q{->hostname() = 127.0.0.1} );
			is( $object->port(), $rdbset->{$d}->{'port'}, q{->port() = }.$object->port() ) if( defined($object->port) );
			is( $object->dbtype(), $d, q{->dbtype() = }.$d );
			is( $object->dbname(), $config->{'database'}->{'dbname'}, q{->dbname() = }.$config->{'database'}->{'dbname'} );
			is( $object->username(), q(bouncehammer), q{->username() = bouncehammer} );
			is( $object->password(), q(kanadzuchi), q{->password() = kanadzuchi} );
			ok( length($object->datasn()), q{->datasn() = }.$object->datasn() );
		}

		CONNECT: {
			$object->handle( 
				Kanadzuchi::RDB::Schema->connect(
					$object->datasn(), $object->username(), $object->password() )
			);
			isa_ok( $object->handle(), q|Kanadzuchi::RDB::Schema|, q{->handle() = }.$object->handle() );


			foreach my $sn ( $object->handle->sources() )
			{
				use_ok( 'Kanadzuchi::RDB::Schema::'.$sn );
			}
		}

		MAKECACHE: {
			# FFR: 
			;
		}

		FAIL: {
			foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
			{
				my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
				is( $object->setup( $e ), 0, q{->setup() = }.$argv );
			}
		}
	}

}

__END__
