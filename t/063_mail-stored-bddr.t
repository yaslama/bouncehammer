# $Id: 063_mail-stored-bddr.t,v 1.3 2010/05/19 18:25:14 ak Exp $
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
use Kanadzuchi::Mail::Stored::BdDR;
use Kanadzuchi::Metadata;
use Time::Piece;
use Test::More ( tests => 691 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Y = undef();
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mail::Stored::BdDR|,
	'methods' => [ @{$Kanadzuchi::Test::Mail::MethodList->{'BaseClass'}},
		@{$Kanadzuchi::Test::Mail::MethodList->{'Stored::BdDR'}}, ],
	'instance' => new Kanadzuchi::Mail::Stored::BdDR(
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
		'disabled' => 0, ),
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
	# 9 Tests
}

SEARCH_AND_NEW:
{
	use Kanadzuchi::BdDR;
	use Kanadzuchi::BdDR::Page;
	use Kanadzuchi::BdDR::Cache;
	use Kanadzuchi::BdDR::BounceLogs;
	use Kanadzuchi::BdDR::BounceLogs::Masters;
	use Kanadzuchi::Mail;
	use Kanadzuchi::Test::DBI;
	use Kanadzuchi::Mail::Stored::YAML;

	SKIP: {
		my $howmanyskips = 682;
		eval { require DBI; }; skip( 'Because no DBI for testing', $howmanyskips ) if( $@ );
		eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $howmanyskips ) if( $@ );

		my $BdDR = undef();
		my $Btab = undef();
		my $Mtab = undef();
		my $Page = undef();
		my $Data = undef();
		my $File = '././examples/hammer.1970-01-01.ffffffff.000000.tmp';
		my $Yaml = undef();
		my $Cdat = undef();
		my $Stat = 0;
		my $nRec = 39;
		my $pNum = 1;
		my $Cond = {};
		my $Damn = {};

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
			$Page = Kanadzuchi::BdDR::Page->new();
			$Cdat = Kanadzuchi::BdDR::Cache->new();
			$Btab = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $BdDR->handle() );
			$Mtab = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables($BdDR->handle());

			isa_ok( $Page, q|Kanadzuchi::BdDR::Page| );
			isa_ok( $Cdat, q|Kanadzuchi::BdDR::Cache| );
			isa_ok( $Btab, q|Kanadzuchi::BdDR::BounceLogs::Table| );

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
				$Stat = $_y->insert( $Btab, $Mtab, $Cdat );
				$Stat = $_y->update( $Btab, $Cdat ) unless( $Stat );
				if( $_y->senderdomain ne 'example.org' )
				{
					ok( $Stat, '->insert() or ->update() test data = '.$_y->recipient->address() );
				}
				else
				{
					is( $Stat, 0, '->insert() or ->update() = 0; test data = '.$_y->recipient->address() );
				}
			}
		}

		SEARCH_AND_NEW1: {

			$Page->set( $Btab->count() );
			is( $Page->count(), $nRec - 1, '->count() = '.($nRec - 1) );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),{},$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );
				is( $pNum, $Page->currentpagenum(), '->currentpagenum() = '.$pNum );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );
					isa_ok( $_e->addresser(), q|Kanadzuchi::Address| );
					isa_ok( $_e->recipient(), q|Kanadzuchi::Address| );
					isa_ok( $_e->bounced(), q|Time::Piece| );
					isa_ok( $_e->updated(), q|Time::Piece| );
					isa_ok( $_e->description(), q|HASH| );

					is( $_e->senderdomain(), $_e->addresser->host(), '->senderdomain() = '.$_e->senderdomain() );
					is( $_e->destination(), $_e->recipient->host(), '->destination() = '.$_e->destination() );
					ok( Kanadzuchi::Mail->gname2id($_e->hostgroup()), '->hostgroup() = '.$_e->hostgroup() );
					ok( Kanadzuchi::Mail->rname2id($_e->reason()), '->reason() = '.$_e->reason() );
					like( $_e->provider(), qr{\A\w+\z}, '->provider() = '.$_e->provider() );
					is( length($_e->token()), 32, '->token() = '.$_e->token() );
				}

				last() unless($Page->hasnext());
				$Page->next();
				$pNum++;
			}
		}

		SEARCH_AND_NEW2: {
			$Cond = {'token' => '8dbb1b9ce9cc47eb6bb1316096c858cd' };
			$Page->reset();
			$Page->set( $Btab->count( $Cond ) );
			is( $Page->count(), 1, '->count() = 1 by token 8dbb1b9ce9cc47eb6bb1316096c858cd' );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );
				is( $Data->count(), 1, '->count() = 1' );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );
				}
				last() unless($Page->next());
			}

		}

		SEARCH_AND_NEW3: {
			$Cond = { 'reason' => 'userunknown', 'hostgroup' => 'cellphone' };
			$Page->reset();
			$Page->set( $Btab->count( $Cond ) );
			is( $Page->count(), 4, '->count() = 4 by reason=userunknown, hostgroup=cellphone' );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );
				is( $Data->count(), 4, '->count() = 4' );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );
					is( $_e->hostgroup(), 'cellphone', '->hostgroup() = cellphone' );
					is( $_e->reason(), 'userunknown', '->reason() = userunknown' );
				}
				last() unless($Page->next());
			}
		}

		SEARCH_AND_NEW4: {
			$Cond = { 'bounced' => { '>' => 1234568000 } };
			$Page->reset();
			$Page->set( $Btab->count( $Cond ) );
			is( $Page->count(), 24, '->count() = 24 by bounced > 1234568000' );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );
					ok( $_e->bounced->epoch() > 1234568000, '->bounced() = '.$_e->bounced->ymd() );
				}
				last() unless($Page->next());
			}
		}

		SEARCH_AND_NEW5: {
			$Cond = { 'frequency' => { '>=' => 1 } };
			$Page->reset();
			$Page->set( $Btab->count( $Cond ) );
			is( $Page->count(), $nRec - 1, '->count() = '.( $nRec - 1 ).' by frequency >= 1 ' );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );
					ok( $_e->frequency() >= 1, '->frequency() >= 1' );
				}
				last() unless($Page->next());
			}
		}

		DAMNED: {
			$Cond = { 'id' => 1 };
			$Page->reset();
			$Page->set( $Btab->count( $Cond ) );
			is( $Page->count(), 1, '->count() = 1 by id = 1 ' );

			while(1)
			{
				$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
				isa_ok( $Data, q|Kanadzuchi::Iterator| );

				while( my $_e = $Data->next() )
				{
					ok( $_e->id(), '->id() = '.$_e->id() );

					$Damn = $_e->damn();
					isa_ok( $Damn, q|HASH|, '->damn()' );
				}
				last() unless($Page->next());
			}
		}

		EACH_METHODS: {
			UPDATE: {
				$Cond = {'token' => '5bcd3527c45ffe1893dcd3f4270e0c19' };
				$Page->reset();
				$Page->set( $Btab->count( $Cond ) );
				is( $Page->count(), 1, '->count() = 1 by token 5bcd3527c45ffe1893dcd3f4270e0c19' );

				while(1)
				{
					$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
					isa_ok( $Data, q|Kanadzuchi::Iterator| );

					while( my $_e = $Data->next() )
					{
						ok( $_e->id(), '->id() = '.$_e->id() );
						is( $_e->hostgroup(), 'reserved', '->hostgroup() = reserved' );
						is( $_e->reason(), 'mailererror', '->reason() = mailererror' );

						$_e->hostgroup('neighbor');
						$_e->reason('onhold');

						$Stat = $_e->update( $Btab, $Cdat );
						ok( $Stat, '->update()' );
					}
					last() unless($Page->next());
				}

				# Search Again
				$Page->reset();
				$Page->set( $Btab->count( $Cond ) );
				is( $Page->count(), 1, '->count() = 1 by token 5bcd3527c45ffe1893dcd3f4270e0c19' );

				while(1)
				{
					$Data = $T->class->searchandnew($BdDR->handle(),$Cond,$Page);
					isa_ok( $Data, q|Kanadzuchi::Iterator| );

					while( my $_e = $Data->next() )
					{
						ok( $_e->id(), '->id() = '.$_e->id() );
						is( $_e->hostgroup(), 'neighbor', '->update->hostgroup() = neighbor' );
						is( $_e->reason(), 'onhold', '->update->reason() = onhold' );
					}
					last() unless($Page->next());
				}
			}
		}

	}
}


__END__

