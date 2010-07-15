# $Id: 020_statistics.t,v 1.6 2010/07/15 00:33:26 ak Exp $
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
use Test::More ( tests => 177 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Statistics|,
	'methods' => [
		'new', 'is_number', 'round', 'size', 'sum',
		'mean', 'variance', 'stddev', 'max', 'var',
		'min', 'quartile', 'median', 'range', 'sd' ],
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
	my $rrname = q();

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
			$rrname = 'Normal',
			$object->label( $rrname );
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label = }.$rrname );
			is( $object->size(), 10, $classx.q{->size = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum = }.$rrname );
			is( $object->range(), 9, $classx.q{->range = }.$rrname );
			is( $object->mean(), 4.5, $classx.q{->mean = }.$rrname );
			is( $object->median(), 4.5, $classx.q{->median = }.$rrname );
			is( $object->quartile(1), 2.25, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 6.75, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 9, $classx.q{->max = }.$rrname );
			is( $object->min(), 0, $classx.q{->min = }.$rrname );
			is( $object->stddev(), 3.028, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 9.167, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 8.25, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		DESCEND_SAMPLES: {
			# Descend
			$rrname = 'Descend';
			$object->label( $rrname );
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label = }.$rrname );
			is( $object->size(), 10, $classx.q{->size = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum = }.$rrname );
			is( $object->range(), 9, $classx.q{->range = }.$rrname );
			is( $object->mean(), 4.5, $classx.q{->mean = }.$rrname );
			is( $object->median(), 4.5, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 2.25, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 6.75, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 9, $classx.q{->max() = }.$rrname );
			is( $object->min(), 0, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 3.028, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 9.167, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 8.25, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		CUBE_SAMPLES: {
			# Cube
			$rrname = 'Cube';
			$object->label($rrname);
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 12, $classx.q{->size() = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum() = }.$rrname );
			is( $object->range(), 1727, $classx.q{->range() = }.$rrname );
			is( $object->mean(), 507, $classx.q{->mean() = }.$rrname );
			is( $object->median(), 279.5, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 54.75, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 796.75, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 1728, $classx.q{->max() = }.$rrname );
			is( $object->min(), 1, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 576.144, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 331942, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 304280.167, $classx.q{->variance() Biased = }.$rrname );
			$object->unbiased(1);
		}

		FIBONACCI_SAMPLES: {
			# Fibonacci
			$rrname = 'Fibonacci';
			$object->label($rrname);
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 17, $classx.q{->size() = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum() = }.$rrname );
			is( $object->range(), 987, $classx.q{->range() = }.$rrname );
			is( $object->mean(), 151.941, $classx.q{->mean() = }.$rrname );
			is( $object->median(), 21, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 3, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 144, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 987, $classx.q{->max() = }.$rrname );
			is( $object->min(), 0, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 272.004, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 73985.934, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 69633.82, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		FRIEDMAN_SAMPLES: {
			# Friedman
			$rrname = 'Friedman';
			$object->label( $rrname );
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 16, $classx.q{->size() = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum() = }.$rrname );
			is( $object->range(), 999, $classx.q{->range() = }.$rrname );
			is( $object->mean(), 380.938, $classx.q{->mean() = }.$rrname );
			is( $object->median(), 252.5, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 126.75, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 640.75, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 1024, $classx.q{->max() = }.$rrname );
			is( $object->min(), 25, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 331.445, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 109855.663, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 102989.684, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		SOPHIE_GERMAIN_SAMPLES: {
			# SophieGermain
			$rrname = 'SophieGermain';
			$object->label( $rrname );
			$object->sample( $RecurrenceRelations->{$rrname} );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 15, $classx.q{->size() = }.$rrname );
			is( $object->sum(), List::Util::sum(@{$RecurrenceRelations->{$rrname}}), q{->sum() = }.$rrname );
			is( $object->range(), 189, $classx.q{->range() = }.$rrname );
			is( $object->mean(), 75.067, $classx.q{->mean() = }.$rrname );
			is( $object->median(), 53, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 17, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 122, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 191, $classx.q{->max() = }.$rrname );
			is( $object->min(), 2, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 67.973, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 4620.352, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 4312.329, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		ZERO_SAMPLES: {
			# 0
			$rrname = 'Zero';
			$object->label( $rrname );
			$object->sample( [0, +0, -0, 00_0, 00, 0<<0, 0<<1, 0>>0, 0>>1, 0%1] );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 10, $classx.q{->size() = }.$rrname );
			is( $object->sum(), 0, q{->sum() = }.$rrname );
			is( $object->range(), 0, $classx.q{->range() = }.$rrname );
			is( $object->mean(), 0, $classx.q{->mean() = }.$rrname );
			is( $object->median(), 0, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), 0, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), 0, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 0, $classx.q{->max() = }.$rrname );
			is( $object->min(), 0, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 0, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 0, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 0, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		NEGATIVE_SAMPLES: {
			# -1
			$rrname = 'Negative';
			$object->label( $rrname );
			$object->sample( [ -0, -1, -2, -3, -1e0, -1e1, -1e2 ] );

			is( $object->label(), $rrname, $classx.q{->label() = }.$rrname );
			is( $object->size(), 7, $classx.q{->size() = }.$rrname );
			is( $object->sum(), -116.999, q{->sum() = }.$rrname );
			is( $object->range(), 100, $classx.q{->range() = }.$rrname );
			is( $object->mean(), -16.713, $classx.q{->mean() = }.$rrname );
			is( $object->median(), -2, $classx.q{->median() = }.$rrname );
			is( $object->quartile(1), -6.5, $classx.q{->quartile(1) = }.$rrname );
			is( $object->quartile(3), -1, $classx.q{->quartile(3) = }.$rrname );
			is( $object->max(), 0, $classx.q{->max() = }.$rrname );
			is( $object->min(), -100, $classx.q{->min() = }.$rrname );
			is( $object->stddev(), 36.877, $classx.q{->stddev() = }.$rrname );
			is( $object->variance(), 1359.905, $classx.q{->variance() Unbiased = }.$rrname );

			$object->unbiased(0);
			is( $object->variance(), 1165.633, $classx.q{->variance() Baiased = }.$rrname );
			$object->unbiased(1);
		}

		ERROR_CASES: {

			EMPTY: {
				# Error Case: Empty
				$object->sample([]);

				is( $object->size(), 0, $classx.q{->size()} );
				is( $object->sum(), q(NA), $classx.q{->sum()} );
				is( $object->range(), q(NA), $classx.q{->range()} );
				is( $object->mean(), q(NA), $classx.q{->mean()} );
				is( $object->median(), q(NA), $classx.q{->median()} );
				is( $object->quartile(1), q(NA), $classx.q{->quartile(1)} );
				is( $object->quartile(3), q(NA), $classx.q{->quartile(3)} );
				is( $object->max(), q(NA), $classx.q{->max()} );
				is( $object->min(), q(NA), $classx.q{->min()} );
				is( $object->stddev(), q(NA), $classx.q{->stddev()} );
				is( $object->variance(), q(NA), $classx.q{->variance()} );
			}

			NULL: {
				# Error Case: Null
				$object->sample(q{});

				is( $object->size(), -1, $classx.q{->size()} );
				is( $object->sum(), q(NA), $classx.q{->sum()} );
				is( $object->range(), q(NA), $classx.q{->range()} );
				is( $object->mean(), q(NA), $classx.q{->mean()} );
				is( $object->median(), q(NA), $classx.q{->median()} );
				is( $object->quartile(1), q(NA), $classx.q{->quartile(1)} );
				is( $object->quartile(3), q(NA), $classx.q{->quartile(3)} );
				is( $object->max(), q(NA), $classx.q{->max()} );
				is( $object->min(), q(NA), $classx.q{->min()} );
				is( $object->stddev(), q(NA), $classx.q{->stddev()} );
				is( $object->variance(), q(NA), $classx.q{->variance()} );
			}

			UNDEF: {
				# Error Case: undef
				$object->sample(undef());

				is( $object->size(), -1, $classx.q{->size()} );
				is( $object->sum(), q(NA), $classx.q{->sum()} );
				is( $object->range(), q(NA), $classx.q{->range()} );
				is( $object->mean(), q(NA), $classx.q{->mean()} );
				is( $object->median(), q(NA), $classx.q{->median()} );
				is( $object->quartile(1), q(NA), $classx.q{->quartile(1)} );
				is( $object->quartile(3), q(NA), $classx.q{->quartile(3)} );
				is( $object->max(), q(NA), $classx.q{->max()} );
				is( $object->min(), q(NA), $classx.q{->min()} );
				is( $object->stddev(), q(NA), $classx.q{->stddev()} );
				is( $object->variance(), q(NA), $classx.q{->variance()} );
			}
		}
	}
}

__END__
