# $Id: 110_bddr.t,v 1.3 2010/07/07 09:05:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::BdDR;
use JSON::Syck;
use Test::More ( tests => 169 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::BdDR|,
	'methods' => [ 'new', 'setup', 'connect', 'disconnect', 'DESTROY' ],
	'instance' => new Kanadzuchi::BdDR(),
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
		$object = new Kanadzuchi::BdDR();
		$config->{'database'}->{'hostname'} = q(127.0.0.1);
		$config->{'database'}->{'dbname'} = $rdbset->{$d}->{'dbname'} || q(bouncehammer) ;
		$config->{'database'}->{'username'} = q(bouncehammer);
		$config->{'database'}->{'password'} = q(kanadzuchi);
		$config->{'database'}->{'port'} = $rdbset->{$d}->{'port'};
		$config->{'database'}->{'dbtype'} = $d;

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

		next() unless( $d eq 'SQLite' );

		SKIP: {
			my $Skip = 2;
			eval { require DBI; }; skip( 'Because no DBI for testing', $Skip ) if( $@ );
			eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $Skip ) if( $@ );

			CONNECT: {
				my $dbhx = $object->connect();
				isa_ok( $dbhx, q|DBI::db|, q{->connect(SQLite)} );
				my $dbhs = $object->disconnect();
				ok( $dbhs, q{->disconnect(SQLite)} );
			}
		}
	}

	FAIL: {
		foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues}, @{$Kanadzuchi::Test::NegativeValues} )
		{
			my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
			my $dbio = Kanadzuchi::BdDR->new->setup($e);
			is( ref($dbio), $T->class(), q{->setup() = }.$argv );
			is( $dbio->datasn(), undef(), q{->setup->datasn() = ''} );
		}
	}

}

__END__
