# $Id: 102_rdb-table-mastertables.t,v 1.7 2010/03/04 08:37:01 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RDB::MasterTable;
use Kanadzuchi::RDB::Table::Addressers;
use Kanadzuchi::RDB::Table::SenderDomains;
use Kanadzuchi::RDB::Table::Destinations;
use Kanadzuchi::RDB::Table::HostGroups;
use Kanadzuchi::RDB::Table::Providers;
use Kanadzuchi::RDB::Table::Reasons;
use Test::More ( tests => 10579 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Methods = [ '_is_validid', '_is_validcolumn', 'getidbyname',
	'getnamebyid', 'getentbyid', 'getthenextid', 'select',
	'insert', 'update', 'remove' ];

my $MTA = new Kanadzuchi::Test(
	'class' => q|Addressers|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::Addressers(),
);

my $MTS = new Kanadzuchi::Test(
	'class' => q|SenderDomains|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::SenderDomains(),
);

my $MTD = new Kanadzuchi::Test(
	'class' => q|Destinations|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::Destinations(),
);

my $MTC = new Kanadzuchi::Test(
	'class' => q|HostGroups|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::HostGroups(),
);

my $MTP = new Kanadzuchi::Test(
	'class' => q|Providers|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::Providers(),
);

my $MTR = new Kanadzuchi::Test(
	'class' => q|Reasons|,
	'methods' => [ @$Methods ],
	'instance' => new Kanadzuchi::RDB::Table::Reasons(),
);

my $MTM = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RDB::MasterTable|,
	'methods' => [ 'newtable' ],
	'instance' => undef(),
);

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
MASTERTABLE: {
	can_ok( $MTM->class(), @{$MTM->methods()} );
}

EACH_TABLE: {
	use Kanadzuchi;
	use Kanadzuchi::Test::CLI;
	use Kanadzuchi::RDB;
	use Kanadzuchi::RDB::Schema;
	use Kanadzuchi::RFC2822;
	use Kanadzuchi::Time;
	use JSON::Syck;
	use File::Copy;

	my $object = undef();
	my $master = undef();
	my $tclass = q();
	my $tabset = {
		'Addressers' => { 'column' => 'email', 'has' => 'nobody@example.com', 'new' => 'vicepresident@example.gov' },
		'SenderDomains' => {'column' => 'domainname', 'has' => 'example.jp', 'new' => 'example.gov' },
		'Destinations' => {'column' => 'domainname', 'has' => 'gmail.com', 'new' => 'example.kyoto.lg.jp' },
		'HostGroups' => { 'column' => 'name', 'has' => 'cellphone', 'new' => 'uucp' },
		'Providers' => { 'column' => 'name', 'has' => 'local', 'new' => 'google' },
		'Reasons' => { 'column' => 'why', 'has' => 'userunknown', 'new' => 'closed' },
	};

	my $K = new Kanadzuchi();
	my $E = new Kanadzuchi::Test::CLI(
			'command' => q(/bin/sh),
			'config' => q(./src/etc/prove.cf),
			'input' => $MTM->example->stringify().q(/17-messages.eml),
			'output' => $MTM->example->stringify().q(/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => $MTM->tempdir->stringify().q{/test.db},
			'tempdir' => $MTM->tempdir->stringify(),
	);
	my $R = 39;

	SKIP: {
		my $D = new Kanadzuchi::RDB( 'dbtype' => q|SQLite| );
		my $S = 10578;	# Skip

		eval { require DBI; }; skip( 'Because no DBI for testing', $S ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $S ) if( $@ );
		skip( 'Because no sqlite3 command', $S ) unless( -x $E->sqlite3() );

		PREPARE_LOGFILE : {
			File::Copy::copy( $E->output(), $E->tempdir().q{/}.File::Basename::basename($E->output()) );
		}

		PREPARE_DATABSE: {

			CREATE: {
				ok( $E->environment(), q{->environment()} );
				ok( $E->initdb(), q{->initdb()} );
				ok( -s $E->database(), q{Create database: }.$E->database() );

				ok( $E->senderdomain(), q{(tablectl) INSERT senderdomains} );
				ok( $E->bouncelog(), q{(databasectl) INSERT records} );
			}

			SETUP: {

				ok( $K->load( $E->config() ), q{Load configuration file} );
				ok( $D->setup($K->config->{'database'}), q{Setting up database} );

				$D->handle( Kanadzuchi::RDB::Schema->connect( 
						$D->datasn(), $D->username(), $D->password() ));

				is( $D->dbname(), $K->config->{'database'}->{'dbname'}, q{Database name} );
				is( $D->datasn(), qq{dbi:SQLite:dbname=}.$D->dbname(), q{Data source name = }.$D->datasn() );
				like( $D->handle(), qr(\AKanadzuchi::RDB::Schema=HASH), q{Database connection} );
			}
		}

		foreach my $tableobject ( $MTA, $MTS, $MTD, $MTC, $MTR )
		{
			my $thisid = 0;
			my $nextid = 0;
			my $previd = 0;
			my $myname = q();
			my $entity = {};
			my $dbdata = [];
			my $sorted = [];
			my $record = 0;
			my $status = 0;

			PREPROCESS: {
				$object = $tableobject->instance();
				$tclass = $tableobject->class();
				$nextid = 0;
				$thisid = 0;
				$myname = q();
				$entity = {};
				$dbdata = [];
				$sorted = [];
				$record = 0;
				$status = 0;
				$master = Kanadzuchi::RDB::MasterTable->newtable( $tclass );

				isa_ok( $object, q|Kanadzuchi::RDB::Table::|.$tclass );
				isa_ok( $master, q|Kanadzuchi::RDB::Table::|.$tclass );
				can_ok( $object, @{$tableobject->methods()} );
				can_ok( $master, @{$tableobject->methods()} );

			}

			CONSTRUCTOR: {
				is( $object->table(), $tclass, q{object->table() = }.$tclass );
				is( $master->table(), $tclass, q{master->table() = }.$tclass );
				is( $object->field(), $tabset->{$tclass}->{'column'}, q{object->field() = }.$tabset->{$tclass}->{'column'});
				is( $master->field(), $tabset->{$tclass}->{'column'}, q{master->field() = }.$tabset->{$tclass}->{'column'});
			}

			EACH_METHOD: {

				GETTHENEXTID: {
					$nextid = $object->getthenextid($D);
					ok( $nextid, q{->getthenextid() = }.$nextid );
					is( $master->getthenextid(), 0, q{Due to the no DB object, getthenextid() failed} );
				}

				GETIDBYNAME: {
					EXISTS: {
						$object->name( $tabset->{$tclass}->{'has'} );
						$thisid = $object->getidbyname($D);

						ok( $thisid, q{->getidbyname() = }.$thisid.q{ by }.$object->name() );
					}

					FAILS: {
						$master->name( $tabset->{$tclass}->{'new'} );
						is( $master->getidbyname(), 0, q{Due to no DB object, getidbyname() failed} );
						is( $master->getidbyname($D), 0, q{The ID by }.$tabset->{$tclass}->{'new'}.q{ does not exist} );

						$master->name( q() );
						is( $master->getidbyname($D), 0, q{Due to the name is empty, getidbyname() failed} );

						foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
						{
							my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
							$master->name( $e );
							is( $master->getidbyname($D), 0,
								'Due to invalid name: '.$argv.', getidbyname() failed' );
						}
					}
				}

				GETNAMEBYID: {
					EXISTS: {
						$object->id( $thisid );
						$myname = $object->getnamebyid($D);
						is( $myname, $object->name(), q{->getnamebyid() = }.$myname.q{ by ID }.$thisid );
					}

					FAILS: {
						$master->id( $nextid );
						is( $master->getnamebyid(), q(), q{Due to no DB object, getnamebyid() failed} );
						is( $master->getnamebyid($D), q(), q{The name by ID }.$nextid.q{ does not exist} );

						$master->id( q() );
						is( $master->getnamebyid($D), q(), q{Due to the ID is empty, getnamebyid() failed} );

						foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
						{
							my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
							$master->id( $e );
							is( $master->getnamebyid($D), q(),
								'Due to invalid ID: '.$argv.', getnamebyid() failed' );
						}
					}
				}

				GETENTBYID: {
					EXISTS: {
						$object->id( $thisid );
						$entity = $object->getentbyid($D);
						isa_ok( $entity, q|HASH|, q{->getentbyid() returns entity by ID }.$thisid );
						is( $entity->{'id'}, $thisid, q{entity->id = }.$entity->{'id'} );
						is( $entity->{'name'}, $tabset->{$tclass}->{'has'}, q{entity->name = }.$entity->{'name'} );
						ok( exists($entity->{'description'}), q{entity->description = }.$entity->{'description'} ) if( defined($entity->{'description'}) );
						ok( exists($entity->{'disabled'}), q{entity->disabled = }.$entity->{'disabled'} ) if( defined($entity->{'disabled'}) );

					}

					FAILS: {
						$master->id( $nextid );
						$entity = $master->getentbyid();
						is( exists($entity->{'name'}), q(),
							q{Due to no DB object, getentbyid() returns empty hash reference} );

						$entity = $master->getentbyid($D);
						is( exists($entity->{'name'}), q(),
							q{The entity by ID }.$nextid.q{ returns empty hash reference} );

						$master->id( q() );
						$entity = $master->getentbyid($D);
						is( exists($entity->{'name'}), q(),
							q{Due to the ID is empty, getentbyid() returns empty hash reference} );

						foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
						{
							my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
							$master->id( $e );
							$entity = $master->getentbyid($D);
							is( exists($entity->{'name'}), q(), 
								'Due to invalid ID: '.$argv.', getentbyid() returns empty hash reference' );
						}
					}
				}

				SELECT: {
					$dbdata = $object->select($D);
					$record = $#{$dbdata} + 1;

					isa_ok( $dbdata, q|ARRAY|, q{->select() returns array reference} );
					ok( $record, q{->select() return }.$record.q{ records} );

					foreach my $d ( @$dbdata )
					{
						isa_ok( $d, q|HASH|, q{each entity is hash reference} );
						ok( $d->{'id'}, qq|->select(): ID = $d->{id}, name = $d->{name}| );
					}

					ORDER_BY_COLUMN: {

						foreach my $o ( 'id', $tabset->{$tclass}->{'column'}, 'description', 'disabled' )
						{
							$previd = 0;
							$sorted = $object->select( $D, $o );
							isa_ok( $sorted, q|ARRAY|, q{->select() ORDER BY }.$o.q{ returns array reference} );
							is( ( $#{$sorted} + 1 ), $record, q{->select() ORDER BY returns }.$record.q{ records} );

							next() unless( $o eq 'id' );
							ok( eq_set( $sorted, $dbdata ), q{->select() ORDER BY is equals to the array by ->select()} );

							foreach my $oo ( @$sorted )
							{
								ok( ( $oo->{'id'} > $previd ), q{The ID }.$oo->{'id'}.q{ is greater than }.$previd );
							}
							continue
							{
								$previd = $oo->{'id'};
							}
						}
					}

					ORDER_BY_EXCEPTIONAL: {

						foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
						{
							my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';

							$previd = 0;
							$sorted = $object->select( $D, $e );
							isa_ok( $sorted, q|ARRAY|, q{->select() ORDER BY }.$argv.q{ returns array reference} );
							is( ( $#{$sorted} + 1 ), $record, 
								'->select() ORDER BY exceptional value: '.$argv.' return '.$record.q{ records} );
							ok( eq_set( $sorted, $dbdata ), q{->select() ORDER BY is equals to the array by ->select()} );

							foreach my $ee ( @$sorted )
							{
								ok( ( $ee->{'id'} > $previd ), q{The ID }.$ee->{'id'}.q{ is greater than }.$previd );
								$previd = $ee->{'id'};
							}
						}
					}

					$dbdata = $master->select();
					isa_ok( $dbdata, q|ARRAY| );
					is( $#{$dbdata}, -1, q{Due to no db object, ->select() returns empty array} );
				}

				INSERT: {
					$object->name( $tabset->{$tclass}->{'new'} );
					$object->description( $object->name() );
					$object->disabled(0);
					$object->id( $object->insert($D) );

					ok( $object->id(), q{->insert() new record: ID = }.$object->id().q{, name = }.$object->name() );
					is( $object->name(), $object->description(), q{->object->name() == ->object->description() } );
					is( $object->disabled(), 0, q{->disabled() = 0} );
					is( $object->getnamebyid($D), $object->name(), q{SELECT(getnamebyid()) again = }.$object->name() );

					foreach my $e ( @{$Kanadzuchi::Test::EscapeCharacters}, @{$Kanadzuchi::Test::ControlCharacters} )
					{
						my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
						$master->name( $e );
						$master->id( $master->insert($D) );
						is( $master->id(), 0, q{->insert() Cannot INSERT new record by the name: }.$argv );
					}

					is( $master->insert(), 0, q{Due to no db object, ->insert() returns 0: failed} );
				}

				UPDATE: {
					$object->name( uc($tabset->{$tclass}->{'new'}) );
					$object->description( q() );
					$object->disabled(1);
					$status = $object->update($D);
					$entity = $object->getentbyid($D);

					ok( $status, qq{->update($status): name = }.$object->name().q{, disabled() = 1} );
					is( $entity->{'id'}, $object->id(), q{->getentbyid() again(id) = }.$entity->{'id'} );
					is( $entity->{'name'}, $object->name(), q{->getentbyid() again(name)} );
					is( $entity->{'description'}, q(), q{->getentbyid() again(disabled)} );
					is( $entity->{'disabled'}, 1, q{->getentbyid() again(disabled)} );

					foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
					{
						my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
						$master->id( $e );
						is( $master->update($D), 0, '->update() failed for invalid ID '.$argv );
					}

					is( $master->update(), 0, q{Due to no db object, ->update() returns 0: failed} );
				}


				DELETE: {
					$status = $object->remove($D);
					ok( $status, q{->remove(), ID = }.$object->id() );

					$entity = $object->getentbyid($D);
					is( exists($entity->{'id'}), q(), q{ID }.$object->id().q{ does not exist on the database} );

					foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
					{
						my $argv = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';
						$master->id( $e );
						is( $master->remove($D), 0,
							'->remove() failed for invalid ID '.$argv );
					}

					is( $master->remove(), 0, q{Due to no db object, ->remove() returns 0: failed} );
				}
			}

		} # End of foreach()
	}
}

__END__
