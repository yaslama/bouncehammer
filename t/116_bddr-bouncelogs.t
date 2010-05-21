# $Id: 116_bddr-bouncelogs.t,v 1.1 2010/05/17 00:00:56 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 872 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Methods = [ 'new', '_is_validid', 'is_validcolumn', 'count', 'search',
		'insert', 'update', 'disableit' ];

my $Class = q|Kanadzuchi::BdDR::BounceLogs::Table|;
my $Klass = q|Kanadzuchi::BdDR::BounceLogs|;

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
can_ok( $Class, @$Methods );

SKIP: {
	my $howmanyskips = 871;
	eval { require DBI; }; skip( 'Because no DBI for testing', $howmanyskips ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $howmanyskips ) if( $@ );

	use Kanadzuchi::Test::DBI;
	use Kanadzuchi::BdDR;
	use Kanadzuchi::BdDR::Page;
	use Kanadzuchi::BdDR::BounceLogs;
	use Kanadzuchi::BdDR::BounceLogs::Masters;
	use Kanadzuchi::Metadata;
	use JSON::Syck;
	use Time::Piece;

	my $Btable = undef();
	my $Mtable = undef();
	my $BdDR = undef();
	my $Page = undef();
	my $File = './examples/hammer.1970-01-01.ffffffff.000000.tmp';
	my $Temp = {};
	my $Data = [];
	my $JSON = undef();

	CONNECT: {

		$BdDR = Kanadzuchi::BdDR->new();
		$BdDR->setup( { 'dbname' => ':memory:', 'dbtype' => 'SQLite' } );
		$BdDR->printerror(1);
		$BdDR->connect();

		isa_ok( $BdDR, q|Kanadzuchi::BdDR| );
		isa_ok( $BdDR->handle(), q|DBI::db| );
	}

	TXNTABLE: {
		$Btable = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $BdDR->handle() );
		$Page  = new Kanadzuchi::BdDR::Page();
		isa_ok( $Btable, $Class );
		isa_ok( $Page,  q|Kanadzuchi::BdDR::Page| );
	}

	MASTERTABLE: {
		foreach my $_mt ( qw(addressers senderdomains destinations hostgroups providers reasons) )
		{
			$Mtable->{$_mt} = Kanadzuchi::BdDR::BounceLogs::Masters::Table->new(
							'alias' => $_mt, 'handle' => $BdDR->handle );
			isa_ok( $Mtable->{$_mt}, q|Kanadzuchi::BdDR::BounceLogs::Masters::Table| );
		}
	}

	CONSTRUCTOR: {
		is( $Btable->table(), 't_bouncelogs', 'Table name = t_bouncelogs' );
		is( $Btable->alias(), 'BounceLogs', 'Table alias = BounceLogs' );
		isa_ok( $Btable->fields(), q|HASH| );
		isa_ok( $Btable->fields->{'join'}, q|ARRAY| );
		isa_ok( $Btable->fields->{'trxn'}, q|ARRAY| );
		isa_ok( $Btable->fields->{'desc'}, q|ARRAY| );
	}

	BUILD_DATABASE: {
		ok( Kanadzuchi::Test::DBI->buildtable($BdDR->handle()), '->DBI->buildtable()' );
	}

	PREPARE: {
		$JSON = JSON::Syck::LoadFile( $File );
		isa_ok( $JSON, q|ARRAY|, 'Load file = '.$File );
		is( scalar(@$JSON), 37, 'Loaded records = 37' );

		foreach my $_j ( @$JSON )
		{
			foreach my $_t ( qw(addresser senderdomain destination provider) )
			{
				$Temp->{$_t} = $Mtable->{$_t.'s'}->getidbyname($_j->{$_t});
				$Temp->{$_t} = $Mtable->{$_t.'s'}->insert( { 'name' => $_j->{$_t} } ) unless($Temp->{$_t});
			}

			push( @$Data, {
				'bounced' => new Time::Piece($_j->{'bounced'}),
				'updated' => new Time::Piece(),
				'token' => $_j->{'token'},
				'recipient' => $_j->{'recipient'},
				'description' => ${ Kanadzuchi::Metadata->to_string($_j->{'description'}) },
				'reason' => $_j->{'reason'},
				'hostgroup' => $_j->{'hostgroup'},
				'addresser' => $Temp->{'addresser'},
				'senderdomain' => $Temp->{'senderdomain'},
				'destination' => $Temp->{'destination'},
				'provider' => $Temp->{'provider'},
			} );
		}

		is( scalar(@$Data), 37, 'Converted data = 37' );
	}

	EACH_METHODS: {

		my $entity = [];
		my $record = 2;		# + 2 example records
		my $thisid = 0;
		my $origin = {};

		$Page->resultsperpage(1e3);

		foreach my $_e ( @$Data )
		{
			$record++;
			$origin = shift(@$JSON);

			INSERT: {
				ok( $Btable->insert( $_e ), '->insert('.$_e->{'token'}.')' );
			}

			COUNT: {
				is( $Btable->count(), $record, '->count() = '.$record );
			}

			SEARCH: {
				$entity = $Btable->search( {}, $Page );
				isa_ok( $entity, q|ARRAY|, '->search()' );

				$entity = shift @{ $Btable->search( { 'token' => $_e->{'token'} }, $Page ) };
				isa_ok( $entity, q|HASH|, '->search('.$_e->{'token'}.')' );

				foreach my $_r ( 'bounced', 'updated', 'token', 'recipient', 'reason', 'hostgroup',
						'provider', 'addresser', 'senderdomain', 'destination' ){

					if( $_r eq 'bounced' )
					{
						is( $entity->{$_r}->epoch(), $origin->{$_r}, $_r.' = '.$entity->{$_r}->ymd() );
					}
					elsif( $_r eq 'updated' )
					{
						isa_ok( $entity->{$_r}, q|Time::Piece| );
					}
					else
					{
						is( $entity->{$_r}, $origin->{$_r}, $_r.' = '.$entity->{$_r} );
					}
				}
			}

			UPDATE: {
				$thisid = $Btable->update( 
						{ 'reason' => 'unstable', 'hostgroup' => 'neighbor' }, 
						{ 'id' => $_e->{'id'} } );
				ok( $thisid, '->update(id='.$thisid.')' );

				$entity = shift @{ $Btable->search( { 'token' => $_e->{'token'} }, $Page ) };
				is( $entity->{'reason'}, 'unstable', 'new reason = unstable' );
				is( $entity->{'hostgroup'}, 'neighbor', 'new hostgroup = neighbor' );
				is( $entity->{'addresser'}, $origin->{'addresser'}, 'addresser:'.$origin->{'addresser'}.'is not updated' );
			}

			DISABLEIT: {
				$thisid = $Btable->disableit( { 'token' => $_e->{'token'} } );
				ok( $thisid, '->disableit(token='.$_e->{'token'}.')' );

				$entity = shift @{ $Btable->search( { 'token' => $_e->{'token'} }, $Page ) };
				is( $entity->{'disabled'}, 1, 'disabled = 1' );
				is( $entity->{'recipient'}, $origin->{'recipient'}, 'recipient'.$origin->{'recipient'}.'is not updated' );
			}

			SEARCH_AGAIN: {
				is( $Btable->count( { 'disabled' => 1 } ), $record - 2, '->count(disabled) = '.$record );

				$Page->resultsperpage(10);
				$Page->set($record);

				$entity = $Btable->search( { 'disabled' => 1 }, $Page );
				is( scalar(@$entity), $record < 12 ? $record - 2 : 10 );
			}

		}
	}


}

__END__

