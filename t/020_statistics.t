# $Id: 020_statistics.t,v 1.3 2010/06/25 19:29:20 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Statistics;
use List::Util;
use Test::More ( tests => 142 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Statistics|,
	'methods' => [
		'new', 'is_number', 'round', 'size',
		'mean', 'variance', 'stddev', 'max', 'var',
		'min', 'quartile', 'median', 'range', ],
	'instance' => new Kanadzuchi::Statistics(), );

my $RecurrenceRelations = {
	'Normal'	=> [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
	'Descend'	=> [ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ],
	'Cube'		=> [ 1, 8, 27, 64, 125, 216, 343, 512, 729, 1000, 1331, 1728 ],
	'Fibonacci'	=> [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ],
	'Friedman'	=> [ 25, 121, 125, 126, 127, 128, 153, 216, 289, 343, 347, 625, 688, 736, 1022, 1024 ],
	'SophieGermain'	=> [ 2, 3, 5, 11, 23, 29, 41, 53, 83, 89, 113, 131, 173, 179, 191 ],
};

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

METHODS: {
	my $object = $T->instance();
	my $classx = $T->class();

	IS_NUMBER: {
		ok( $classx->is_number(1) );
		ok( $classx->is_number('1') );
		ok( $classx->is_number(-1) );
		ok( $classx->is_number(1.0) );
		ok( $classx->is_number(1.01) );
		ok( $classx->is_number(0e0) );
		ok( $classx->is_number(-1e-01) );
		is( $classx->is_number(' '), 0, $classx.q{->is_number( )} );
		is( $classx->is_number('beaf'), 0, $classx.q{->is_number(beaf)} );
		is( $classx->is_number([]), 0, $classx.q{->is_number([])} );
		is( $classx->is_number({}), 0, $classx.q{->is_number({})} );
	}

	ROUND: {
		# round();

		is( $object->round(3.14), 3.14, $classx.q{->round(3.14)} );
		is( $object->round(3.141), 3.141, $classx.q{->round(3.141)} );
		is( $object->round(3.1415), 3.142, $classx.q{->round(3.142)} );
		$object->rounding(0);
		is( $object->round(3.141593), 3.141593, $classx.q{->round(3.141593,0)} );
		$object->rounding(1);
		is( $object->round(3.14), 3, $classx.q{->round(3.14,1)} );
		$object->rounding(4);
		is( $object->round(3141593e-6), 3.142, $classx.q{->round(3141593e-6)} );
	}

	ARRAY_REFERENCE: {
		# Array reference as an argument

		$object->sample([]);
		foreach my $rr ( keys(%{$RecurrenceRelations}) )
		{
			is( $object->size($RecurrenceRelations->{$rr}), 
				$#{$RecurrenceRelations->{$rr}} + 1, $classx.q{->size([}.$rr.q{])} );
			is( $object->max($RecurrenceRelations->{$rr}), 
				List::Util::max(@{$RecurrenceRelations->{$rr}}), $classx.q{->max([}.$rr.q{])} );
			is( $object->min($RecurrenceRelations->{$rr}), 
				List::Util::min(@{$RecurrenceRelations->{$rr}}), $classx.q{->min([}.$rr.q{])} );
		}
	}

	OTHER_STATISTICS_METHODS: {
		# other instance methods

		NORMAL_SAMPLES: {
			# Normal
			$object->label( 'Normal test' );
			$object->sample( $RecurrenceRelations->{'Normal'} );

			is( $object->label(), 'Normal test', $classx.q{->label(Normal test)} );
			is( $object->size(), 10, $classx.q{->size(Normal)} );
			is( $object->range(), 9, $classx.q{->range(Normal)} );
			is( $object->mean(), 4.5, $classx.q{->mean(Normal)} );
			is( $object->median(), 4.5, $classx.q{->median(Normal)} );
			is( $object->quartile(1), 2.25, $classx.q{->quartile(1,Normal)} );
			is( $object->quartile(3), 6.75, $classx.q{->quartile(3,Normal)} );
			is( $object->max(), 9, $classx.q{->max(Normal)} );
			is( $object->min(), 0, $classx.q{->min(Normal)} );
			is( $object->stddev(), 3.028, $classx.q{->stddev(Normal)} );
			is( $object->variance(), 9.167, $classx.q{->variance(Normal) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 8.25, $classx.q{->variance(Normal) Sample} );
			$object->unbiased(1);
		}

		DESCEND_SAMPLES: {
			# Descend
			$object->label( 'Descending' );
			$object->sample( $RecurrenceRelations->{'Descend'} );

			is( $object->label(), 'Descending', $classx.q{->label(Descending)} );
			is( $object->size(), 10, $classx.q{->size(Descend)} );
			is( $object->range(), 9, $classx.q{->range(Descend)} );
			is( $object->mean(), 4.5, $classx.q{->mean(Descend)} );
			is( $object->median(), 4.5, $classx.q{->median(Descend)} );
			is( $object->quartile(1), 2.25, $classx.q{->quartile(1,Descend)} );
			is( $object->quartile(3), 6.75, $classx.q{->quartile(3,Descend)} );
			is( $object->max(), 9, $classx.q{->max(Descend)} );
			is( $object->min(), 0, $classx.q{->min(Descend)} );
			is( $object->stddev(), 3.028, $classx.q{->stddev(Descend)} );
			is( $object->variance(), 9.167, $classx.q{->variance(Descend) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 8.25, $classx.q{->variance(Descend) Sample} );
			$object->unbiased(1);
		}

		CUBE_SAMPLES: {
			# Cube
			$object->label('Cube');
			$object->sample( $RecurrenceRelations->{'Cube'} );

			is( $object->label(), 'Cube', $classx.q{->label(Cube)} );
			is( $object->size(), 12, $classx.q{->size(Cube)} );
			is( $object->range(), 1727, $classx.q{->range(Cube)} );
			is( $object->mean(), 507, $classx.q{->mean(Cube)} );
			is( $object->median(), 279.5, $classx.q{->median(Cube)} );
			is( $object->quartile(1), 54.75, $classx.q{->quartile(1,Cube)} );
			is( $object->quartile(3), 796.75, $classx.q{->quartile(3,Cube)} );
			is( $object->max(), 1728, $classx.q{->max(Cube)} );
			is( $object->min(), 1, $classx.q{->min(Cube)} );
			is( $object->stddev(), 576.144, $classx.q{->stddev(Cube)} );
			is( $object->variance(), 331942, $classx.q{->variance(Cube) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 304280.167, $classx.q{->variance(Cube) Sample} );
			$object->unbiased(1);
		}

		FIBONACCI_SAMPLES: {
			# Fibonacci
			$object->label('Fibonacci');
			$object->sample( $RecurrenceRelations->{'Fibonacci'} );

			is( $object->label(), 'Fibonacci', $classx.q{->label(Fibonacci)} );
			is( $object->size(), 17, $classx.q{->size(Fibonacci)} );
			is( $object->range(), 987, $classx.q{->range(Fibonacci)} );
			is( $object->mean(), 151.941, $classx.q{->mean(Fibonacci)} );
			is( $object->median(), 21, $classx.q{->median(Fibonacci)} );
			is( $object->quartile(1), 3, $classx.q{->quartile(1,Fibonacci)} );
			is( $object->quartile(3), 144, $classx.q{->quartile(3,Fibobacci)} );
			is( $object->max(), 987, $classx.q{->max(Fibonacci)} );
			is( $object->min(), 0, $classx.q{->min(Fibonacci)} );
			is( $object->stddev(), 272.004, $classx.q{->stddev(Fibonacci)} );
			is( $object->variance(), 73985.934, $classx.q{->variance(Fibonacci) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 69633.82, $classx.q{->variance(Fibonacci) Sample} );
			$object->unbiased(1);
		}

		FRIEDMAN_SAMPLES: {
			# Friedman
			$object->label( 'Friedman' );
			$object->sample( $RecurrenceRelations->{'Friedman'} );

			is( $object->label(), 'Friedman', $classx.q{->label(Friedman)} );
			is( $object->size(), 16, $classx.q{->size(Friedman)} );
			is( $object->range(), 999, $classx.q{->range(Friedman)} );
			is( $object->mean(), 380.938, $classx.q{->mean(Friedman)} );
			is( $object->median(), 252.5, $classx.q{->median(Friedman)} );
			is( $object->quartile(1), 126.75, $classx.q{->quartile(1,Friedman)} );
			is( $object->quartile(3), 640.75, $classx.q{->quartile(3,Friedman)} );
			is( $object->max(), 1024, $classx.q{->max(Friedman)} );
			is( $object->min(), 25, $classx.q{->min(Friedman)} );
			is( $object->stddev(), 331.445, $classx.q{->stddev(Friedman)} );
			is( $object->variance(), 109855.663, $classx.q{->variance(Friedman) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 102989.684, $classx.q{->variance(Friedman) Sample} );
			$object->unbiased(1);
		}

		SOPHIE_GERMAIN_SAMPLES: {
			# SophieGermain
			$object->label( 'SophieGermain' );
			$object->sample( $RecurrenceRelations->{'SophieGermain'} );

			is( $object->label(), 'SophieGermain', $classx.q{->label(SophieGermain)} );
			is( $object->size(), 15, $classx.q{->size(SophieGermain)} );
			is( $object->range(), 189, $classx.q{->range(SophieGermain)} );
			is( $object->mean(), 75.067, $classx.q{->mean(SophieGermain)} );
			is( $object->median(), 53, $classx.q{->median(SophieGermain)} );
			is( $object->quartile(1), 17, $classx.q{->quartile(1,SophieGermain)} );
			is( $object->quartile(3), 122, $classx.q{->quartile(3,SophieGermain)} );
			is( $object->max(), 191, $classx.q{->max(SophieGermain)} );
			is( $object->min(), 2, $classx.q{->min(SophieGermain)} );
			is( $object->stddev(), 67.973, $classx.q{->stddev(SophieGermain)} );
			is( $object->variance(), 4620.352, $classx.q{->variance(SophieGermain) Unbiased} );

			$object->unbiased(0);
			is( $object->variance(), 4312.329, $classx.q{->variance(SophieGermain) Sample} );
			$object->unbiased(1);
		}

		ERROR_CASES: {

			EMPTY: {
				# Error Case: Empty
				$object->sample([]);

				is( $object->size(), 0, $classx.q{->size(Empty)} );
				is( $object->range(), q(), $classx.q{->range(Empty)} );
				is( $object->mean(), q(), $classx.q{->mean(Empty)} );
				is( $object->median(), q(), $classx.q{->median(Empty)} );
				is( $object->quartile(1), q(), $classx.q{->quartile(1,Empty)} );
				is( $object->quartile(3), q(), $classx.q{->quartile(3,Empty)} );
				is( $object->max(), q(), $classx.q{->max(Empty)} );
				is( $object->min(), q(), $classx.q{->min(Empty)} );
				is( $object->stddev(), q(), $classx.q{->stddev(Empty)} );
				is( $object->variance(), q(), $classx.q{->variance(Empty)} );
			}

			NULL: {
				# Error Case: Null
				$object->sample(q{});

				is( $object->size(), -1, $classx.q{->size(Null)} );
				is( $object->range(), q(), $classx.q{->range(Null)} );
				is( $object->mean(), q(), $classx.q{->mean(Null)} );
				is( $object->median(), q(), $classx.q{->median(Null)} );
				is( $object->quartile(1), q(), $classx.q{->quartile(1,Null)} );
				is( $object->quartile(3), q(), $classx.q{->quartile(3,Null)} );
				is( $object->max(), q(), $classx.q{->max(Null)} );
				is( $object->min(), q(), $classx.q{->min(Null)} );
				is( $object->stddev(), q(), $classx.q{->stddev(Null)} );
				is( $object->variance(), q(), $classx.q{->variance(Null)} );
			}

			UNDEF: {
				# Error Case: undef
				$object->sample(undef());

				is( $object->size(), -1, $classx.q{->size(undef())} );
				is( $object->range(), q(), $classx.q{->range(undef())} );
				is( $object->mean(), q(), $classx.q{->mean(undef())} );
				is( $object->median(), q(), $classx.q{->median(undef())} );
				is( $object->quartile(1), q(), $classx.q{->quartile(1,undef())} );
				is( $object->quartile(3), q(), $classx.q{->quartile(3,undef())} );
				is( $object->max(), q(), $classx.q{->max(undef())} );
				is( $object->min(), q(), $classx.q{->min(undef())} );
				is( $object->stddev(), q(), $classx.q{->stddev(undef())} );
				is( $object->variance(), q(), $classx.q{->variance(undef())} );
			}
		}
	}
}

__END__
