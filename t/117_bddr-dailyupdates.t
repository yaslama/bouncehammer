# $Id: 117_bddr-dailyupdates.t,v 1.2 2010/08/28 17:22:44 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 239 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
SKIP: {
	my $howmanyskips = 239;
	eval { require DBI; }; skip( 'Because no DBI for testing', $howmanyskips ) if( $@ );
	eval { require DBD::SQLite; }; skip( 'Because no DBD::SQLite for testing', $howmanyskips ) if( $@ );

	require Kanadzuchi::Test::DBI;
	require Kanadzuchi::BdDR;
	require Kanadzuchi::BdDR::DailyUpdates;
	require Time::Piece;

	my $BdDR = undef();
	my $Dtab = undef();
	my $Dobj = undef();
	my $Methods = [];
	my $Class = q();
	my $uData = {};
	my $nData = [];

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

	$uData = { 
		'1970-01-01' => { 'inserted' => 1, 'updated' => 2, 'skipped' => 3 },
		'1975-04-09' => { 'inserted' => 4, 'updated' => 5, 'skipped' => 6 },
		'1980-07-17' => { 'inserted' => 7, 'updated' => 8, 'skipped' => 9 },
	};

	TABLE_CLASS: {
		$Methods = [ 'new', 'is_validid', 'is_validcolumn', 'size', 'count',
				'search', 'insert', 'update', 'disable', 'remove' ];
		$Class = q|Kanadzuchi::BdDR::DailyUpdates::Table|;

		can_ok( $Class, @$Methods );

		TABLE: {
			$Dtab = new Kanadzuchi::BdDR::DailyUpdates::Table( 'handle' => $BdDR->handle() );
			isa_ok( $Dtab, $Class );
		}

		CONSTRUCTOR: {
			is( $Dtab->table(), 't_dailyupdates', 'Table name = t_dailyupdates' );
			is( $Dtab->alias(), 'DailyUpdates', 'Table alias = DailyUpdates' );
			isa_ok( $Dtab->fields(), q|HASH| );
		}

		INSERT: {
			foreach my $d ( sort keys %$uData )
			{
				my $this = $uData->{ $d };
				my $data = {};

				map { $data->{$_} = $this->{$_} } qw(inserted updated skipped);
				$data->{'thedate'} = $d;
				$data->{'thetime'} = Time::Piece->strptime($d,'%Y-%m-%d');
				$data->{'executed'} = 1;

				ok( $Dtab->insert( $data ), 'insert = '.$d );
			}
		}

		SEARCH1: {
			foreach my $d ( sort keys %$uData )
			{
				my $data = $Dtab->search( { 'thedate' => $d } );

				isa_ok( $data, q|ARRAY| );
				while( my $this = shift @$data )
				{
					is( $this->{'thedate'}, $d, 'thedate = '.$d );
					foreach my $x ( qw(inserted updated skipped) )
					{
						is( $this->{$x}, $uData->{$d}->{$x}, $x.' = '.$this->{$x} );
					}
					is( $this->{'failed'}, 0, 'failed = 0' );
					is( $this->{'executed'}, 1, 'executed = 1' );

					isa_ok( $this->{'thetime'}, q|Time::Piece| );
					isa_ok( $this->{'modified'}, q|Time::Piece| );
				}
			}
		}

		UPDATE: {
			foreach my $d ( sort keys %$uData )
			{
				my $this = $uData->{ $d };
				my $data = {};

				map { $data->{$_} = $this->{$_} * 10 } qw(inserted updated skipped);
				$data->{'thedate'} = $d;
				$data->{'executed'} = 2;

				ok( $Dtab->update( $data, { 'thedate' => $d } ), 'update = '.$d );
			}

		}

		SEARCH2: {
			foreach my $d ( sort keys %$uData )
			{
				my $data = $Dtab->search( { 'thedate' => $d } );

				isa_ok( $data, q|ARRAY| );
				while( my $this = shift @$data )
				{
					is( $this->{'thedate'}, $d, 'thedate = '.$d );
					foreach my $x ( qw(inserted updated skipped) )
					{
						is( $this->{$x}, $uData->{$d}->{$x} * 10, $x.' = '.$this->{$x} );
					}
					is( $this->{'failed'}, 0, 'failed = 0' );
					is( $this->{'executed'}, 2, 'executed = 2' );

					isa_ok( $this->{'thetime'}, q|Time::Piece| );
					isa_ok( $this->{'modified'}, q|Time::Piece| );
				}
			}
		}
	}

	DATA_CLASS: {
		$Methods = [ 'new', 'recordit', 'quaerit', 'congregat' ];
		$Class = q|Kanadzuchi::BdDR::DailyUpdates::Data|;

		can_ok( $Class, @$Methods );

		TABLE: {
			$Dtab = new Kanadzuchi::BdDR::DailyUpdates::Table( 'handle' => $BdDR->handle() );
		}

		DATA: {
			$Dobj = new Kanadzuchi::BdDR::DailyUpdates::Data( 'handle' => $BdDR->handle() );
			isa_ok( $Dobj, $Class );

			foreach my $d ( keys %$uData )
			{
				push( @$nData, { 
						'thedate' => $d, 
						'inserted' => $uData->{$d}->{'inserted'} || 0,
						'updated' => $uData->{$d}->{'updated'} || 0,
						'skipped' => $uData->{$d}->{'skipped'} || 0,
						'failed' => $uData->{$d}->{'failed'} || 0, } );
			}
		}

		CONSTRUCTOR: {
			isa_ok( $Dobj->db(), q|Kanadzuchi::BdDR::DailyUpdates::Table| );
			isa_ok( $Dobj->handle(), q|DBI::db| );
			isa_ok( $Dobj->data(), q|ARRAY| );
			isa_ok( $Dobj->subtotal(), q|ARRAY| );

			is( $Dobj->totalsby(), 'w' );
			is( scalar @{ $Dobj->data() }, 0 );
			is( scalar @{ $Dobj->subtotal() }, 0 );
		}

		RECORDIT: {
			ok( $Dobj->recordit($nData) );
		}

		SEARCH3: {
			foreach my $d ( sort keys %$uData )
			{
				my $data = $Dtab->search( { 'thedate' => $d } );

				isa_ok( $data, q|ARRAY| );
				while( my $this = shift @$data )
				{
					is( $this->{'thedate'}, $d, 'thedate = '.$d );
					foreach my $x ( qw(inserted updated skipped) )
					{
						is( $this->{$x}, $uData->{$d}->{$x} * 10 + $uData->{$d}->{$x}, $x.' = '.$this->{$x} );
					}
					is( $this->{'failed'}, 0, 'failed = 0' );
					is( $this->{'executed'}, 3, 'executed = 3' );

					isa_ok( $this->{'thetime'}, q|Time::Piece| );
					isa_ok( $this->{'modified'}, q|Time::Piece| );
				}
			}
		}

		QUAERIT: {
			my $iterator = undef();

			foreach my $unit ( qw(d w m y) )
			{
				$Dobj->totalsby($unit);
				is( $Dobj->totalsby(), $unit, 'totals by = '.$unit );

				$iterator = $Dobj->quaerit();
				isa_ok( $iterator, q|Kanadzuchi::Iterator| );

				while( my $e = $iterator->next() )
				{
					isa_ok( $e, q|HASH| );
					isa_ok( $e->{'thetime'}, q|Time::Piece| );
					isa_ok( $e->{'modified'}, q|Time::Piece| );
					ok( $e->{'thedate'}, $e->{'thedate'} );
					foreach my $k ( qw(estimated inserted updated skipped failed executed) )
					{
						like( $e->{$k}, qr{\A\d+\z}, $k.' = '.$e->{$k} );
					}
				}
			}
		}

		CONGREEGAT: {
			foreach my $unit ( qw(w m y) )
			{
				$Dobj->totalsby($unit);
				is( $Dobj->totalsby(), $unit, 'totals by = '.$unit );

				$Dobj->congregat();
				isa_ok( $Dobj->subtotal, q|ARRAY| );

				foreach my $e ( @{ $Dobj->subtotal() } )
				{
					isa_ok( $e, q|HASH| );
					ok( $e->{'name'}, $e->{'name'} );

					foreach my $k ( qw(estimated inserted updated skipped failed executed) )
					{
						like( $e->{$k}, qr{\A\d+\z}, $k.' = '.$e->{$k} );
					}
				}
			}
		}
	}

}

__END__
