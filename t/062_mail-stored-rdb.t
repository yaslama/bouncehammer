# $Id: 062_mail-stored-rdb.t,v 1.5 2010/02/25 09:33:28 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Test::Mail;
use Kanadzuchi::Mail::Stored::RDB;
use Kanadzuchi::Metadata;
use Time::Piece;
use File::Copy;
use Test::More ( tests => 1602 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Y = undef();
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mail::Stored::RDB|,
	'methods' => [ @{$Kanadzuchi::Test::Mail::MethodList->{'BaseClass'}},
		@{$Kanadzuchi::Test::Mail::MethodList->{'Stored::RDB'}}, ],
	'instance' => new Kanadzuchi::Mail::Stored::RDB(
		'id' => 1,
		'addresser' => q(POSTMASTER@EXAMPLE.JP),
		'recipient' => 'USER01@EXAMPLE.ORG',
		'bounced' => bless( localtime(time()-90000), 'Time::Piece' ),
		'updated' => bless( localtime(), 'Time::Piece' ),
		'timezoneoffset' => q(+0900),
		'diagnosticcode' => q(Test),
		'deliverystatus' => 512,
		'hostgroup' => 'rfc2606',
		'provider' => 'rfc2606',
		'reason' => 'hostunknown',
		'disable' => 0, ),
);

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	my $object = $T->instance();

	isa_ok( $object, $T->class() );
	isa_ok( $object->bounced(), q|Time::Piece| );
	isa_ok( $object->updated(), q|Time::Piece| );
	isa_ok( $object->addresser(), q|Kanadzuchi::Address| );
	isa_ok( $object->recipient(), q|Kanadzuchi::Address| );
	isa_ok( $object->description(), q|HASH| );
	can_ok( $T->class(), @{$T->methods()} );

	is( $object->senderdomain(), $object->addresser->host(), q{senderdomain == addresser->host} );
	is( $object->destination(), $object->recipient->host(), q{senderdomain == addresser->host} );
}

SERIALIZE: {
	# Object to string
	my $object = $T->instance();
	my $entity = {};
	my $struct = {};
	my $jsonstring = $T->class->serialize( [ $object ] );
	my $jsonstruct = Kanadzuchi::Metadata->to_object( \$jsonstring );
	my $yamlstring = $T->class->serialize( $jsonstruct );

	isa_ok( $jsonstruct, q|ARRAY| );
	ok( length($jsonstring), $T->class.q{->serialize() from Object} );
	ok( length($yamlstring), $T->class.q{->serialize() from Hash reference} );

	foreach my $j ( $jsonstring, $yamlstring )
	{
		$struct = Kanadzuchi::Metadata->to_object( \$j );
		$entity = $struct->[0];

		isa_ok( $struct, q|ARRAY|, q{struct is ARRAY} );
		isa_ok( $entity, q|HASH|, q{entity is HASH} );

		is( $entity->{'description'}->{'deliverystatus'}, 512, q{->description->deliverystats == 512 } );
		is( $entity->{'description'}->{'timezoneoffset'}, q(+0900), q{->description->timezoneoffset == +0900} );
		is( $entity->{'description'}->{'diagnosticcode'}, q(Test), q{->description->timezoneoffset == +0900} );

		is( $entity->{'deliverystatus'}, $entity->{'description'}->{'deliverystatus'},
						q{->deliverystatus == description->deliverystatus} );
		is( $entity->{'diagnosticcode'}, $entity->{'description'}->{'diagnosticcode'},
						q{->diagnosticcode == description->diagnosticcode} );
		is( $entity->{'timezoneoffset'}, $entity->{'description'}->{'timezoneoffset'},
						q{->timezoneoffset == description->timezoneoffset} );
	}
}

SEARCH_AND_NEW:
{
	use Kanadzuchi;
	use Kanadzuchi::Test::CLI;
	use Kanadzuchi::RDB;
	use Kanadzuchi::RDB::Schema;
	use Kanadzuchi::RFC2822;
	use Kanadzuchi::Time;
	use JSON::Syck;

	my $K = new Kanadzuchi();
	my $E = new Kanadzuchi::Test::CLI(
			'command' => q(/bin/sh),
			'config' => q(./src/etc/prove.cf),
			'input' => $T->example->stringify().q(/17-messages.eml),
			'output' => $T->example->stringify().q(/hammer.1970-01-01.ffffffff.000000.tmp),
			'database' => $T->tempdir->stringify().q(/test.db),
			'tempdir' => $T->tempdir->stringify(),
	);
	my $R = 39;

	# 28 Tests 
	# -----------------------------------------------------------------------------

	SKIP: {
		my $D = new Kanadzuchi::RDB( 'dbtype' => q|SQLite| );
		my $S = 1574;	# Skip

		eval { require DBI; }; skip( 'Because no DBI for testing', $S ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $S ) if( $@ );
		skip( 'Because no sqlite3 command', $S ) unless( -x $E->sqlite3() );


		PREPARE_LOGFILE : {
			File::Copy::copy( $E->output(), $E->tempdir().q{/}.File::Basename::basename($E->output()) );
		}

		PREPARE_DATABSE: {
			my $objects = [];
			my $pageset = { 'resultsperpage' => 100, };

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
				is( $D->datasn(), qq{dbi:SQLite:dbname=}.$D->dbname(), q{Data source name} );
				like( $D->handle(), qr(\AKanadzuchi::RDB::Schema=HASH), q{Database connection} );
			}

			CREATE_OBJECT: {

				$T->instance( $T->class->searchandnew( $D, {}, \$pageset, 1 ) );
				$objects = $T->instance();

				isa_ok( $objects, q|ARRAY| );
				is( ( $#{$objects} + 1 ), $R, $R.q{ Records} );

				foreach my $o ( @$objects )
				{
					isa_ok( $o, $T->class() );
					isa_ok( $o->addresser(), q|Kanadzuchi::Address| );
					isa_ok( $o->recipient(), q|Kanadzuchi::Address| );
					isa_ok( $o->bounced(), q|Time::Piece| );
					isa_ok( $o->updated(), q|Time::Piece| );
					isa_ok( $o->description(), q|HASH| );

					ok( $o->id(), q{ID = }.$o->id() );
					ok( $o->frequency(), q{->frequency = }.$o->frequency() );
					is( $o->disable(), 0, q{->diable = 0 } );

					ok( Kanadzuchi::RFC2822->is_emailaddress($o->addresser->address()), q{->addresser->address()} );
					ok( Kanadzuchi::RFC2822->is_emailaddress($o->recipient->address()), q{->recipient->address()} );
					ok( Kanadzuchi::RFC2822->is_domainpart($o->senderdomain()), q{->senderdomain} );
					ok( Kanadzuchi::RFC2822->is_domainpart($o->destination()), q{->destination} );

					like( $o->deliverystatus(), qr{\A\d+\z}, q{->deliverystatus = }.$o->deliverystatus() );
					like( $o->diagnosticcode(), qr{\A.*\z}, q{->diagnosticcode = }.$o->diagnosticcode() );
					is( length($o->token()), 32, q{->token = }.$o->token() );

					ok( $o->bounced->epoch(), q{->bounced->epoch = }.$o->bounced->epoch() );
					ok( $o->updated->epoch(), q{->updated->epoch = }.$o->bounced->epoch() );
					isnt( Kanadzuchi::Time->tz2second($o->timezoneoffset()), undef(), q{->timezoneoffset = }.$o->timezoneoffset() );

					ok( $T->class->rname2id( $o->reason() ), q{->reason = }.$o->reason() );
					ok( $T->class->gname2id( $o->hostgroup() ), q{->hostgroup = }.$o->hostgroup() );
				}
			}

			CREATE_HAHSREFERENCE: {

				$T->instance( $T->class->searchandnew( $D, {}, \$pageset, 0 ) );
				$objects = $T->instance();

				isa_ok( $objects, q|ARRAY| );
				is( ( $#{$objects} + 1 ), $R, $R.q{ Records} );

				foreach my $o ( @$objects )
				{
					isa_ok( $o, q|HASH| );
					isa_ok( $o->{'bounced'}, q|Time::Piece| );
					isa_ok( $o->{'updated'}, q|Time::Piece| );
					isa_ok( $o->{'description'}, q|HASH| );

					ok( $o->{'id'}, q{ID = }.$o->{'id'} );
					ok( $o->{'frequency'}, q{->frequency = }.$o->{'frequency'} );
					is( $o->{'disable'}, 0, q{->diable = 0 } );

					ok( Kanadzuchi::RFC2822->is_emailaddress($o->{'addresser'}), q{->addresser} );
					ok( Kanadzuchi::RFC2822->is_emailaddress($o->{'recipient'}), q{->recipient()} );
					ok( Kanadzuchi::RFC2822->is_domainpart($o->{'senderdomain'}), q{->senderdomain} );
					ok( Kanadzuchi::RFC2822->is_domainpart($o->{'destination'}), q{->destination} );

					like( $o->{'deliverystatus'}, qr{\A\d+\z}, q{->deliverystatus = }.$o->{'deliverystatus'} );
					like( $o->{'diagnosticcode'}, qr{\A.*\z}, q{->diagnosticcode = }.$o->{'diagnosticcode'} );
					is( length($o->{'token'}), 32, q{->token = }.$o->{'token'} );

					ok( $o->{'bounced'}->year(), q{->bounced->year = }.$o->{'bounced'}->year() );
					ok( $o->{'updated'}->year(), q{->updated->year = }.$o->{'bounced'}->year() );
					isnt( Kanadzuchi::Time->tz2second($o->{'timezoneoffset'}), undef(), q{->timezoneoffset = }.$o->{'timezoneoffset'} );

					ok( $T->class->rname2id( $o->{'reason'} ), q{->reason = }.$o->{'reason'} );
					ok( $T->class->gname2id( $o->{'hostgroup'} ), q{->hostgroup = }.$o->{'hostgroup'} );
				}
			}
		}
	}
}


__END__

