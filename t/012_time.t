# $Id: 012_time.t,v 1.3 2010/07/07 09:05:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Time;
use Test::More ( tests => 191 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Time|,
	'methods' => [
		'to_second', 'tz2second', 'second2tz',
		'monthname', 'dayofweek', 'hourname', ],
	'instance' => undef(), );

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $T->class(), @{$T->methods()} );
}

METHODS: {
	my $class = $T->class();

	TO_SECOND: {
		is( $class->to_second(q{1d}), 86400, $class.q{ 1 Day});
		is( $class->to_second(q{2w}), ( 86400 * 7 * 2 ), $class.q{ 2 Weeks} );
		is( $class->to_second(q{3f}), ( 86400 * 14 * 3 ), $class.q{ 3 Fortnites} );
		is( int($class->to_second(q{4l})), 10205771, $class.q{ 4 Lunar months} );
		is( int($class->to_second(q{5q})), 39446190, $class.q{ 5 Quarters} );
		is( int($class->to_second(q{6y})), 189341712, $class.q{ 6 Years} );
		is( int($class->to_second(q{7o})), 883594656, $class.q{ 7 Olympiads} );

		is( int($class->to_second(q{gs})), 23, $class.q{ 23.14(e^p) seconds} );
		is( int($class->to_second(q{pm})), 188, $class.q{ 3.14(PI) minutes} );
		is( int($class->to_second(q{eh})), 9785, $class.q{ 2.718(e) hours} );

		is( $class->to_second(-1), 0, q{The value: -1} );
		is( $class->to_second( -4294967296 ), 0, q{ The value: -4294967296} );
	}

	TIMEZONE_TO_SECOND: {
		is( $class->tz2second('+0000'), 0, $class.q{->tz2second(+0000)} );
		is( $class->tz2second('-0000'), 0, $class.q{->tz2second(-0000)} );
		is( $class->tz2second('-0900'), -32400, $class.q{->tz2second(-0900)} );
		is( $class->tz2second('+0900'), 32400, $class.q{->tz2second(+0900)} );
		is( $class->tz2second('-1200'), -43200, $class.q{->tz2second(-1200)} );
		is( $class->tz2second('+1200'), 43200, $class.q{->tz2second(+1200)} );
		is( $class->tz2second('-1800'), undef(), $class.q{->tz2second(-1800)} );
		is( $class->tz2second('+1800'), undef(), $class.q{->tz2second(+1800)} );
		is( $class->tz2second('NULL'), undef(), $class.q{->tz2second(NULL)} );
		is( $class->tz2second(), undef(), $class.q{->tz2second()} );
	}

	SECOND_TO_TIMEZONE: {
		is( $class->second2tz(0), q{+0000}, $class.q{->second2tz(0)} );
		is( $class->second2tz(-32400), q{-0900}, $class.q{->second2tz(-32400)} );
		is( $class->second2tz(32400), q{+0900}, $class.q{->second2tz(32400)} );
		is( $class->second2tz(-43200), q{-1200}, $class.q{->second2tz(-43200)} );
		is( $class->second2tz(43200), q{+1200}, $class.q{->second2tz(43200)} );
		is( $class->second2tz(-65535), q{}, $class.q{->second2tz(65535)} );
		is( $class->second2tz(65535), q{}, $class.q{->second2tz(65535)} );
		is( $class->second2tz(0e0), q{+0000}, $class.q{->second2tz(0e0)} );
		is( $class->second2tz(), q{+0000}, $class.q{->second2tz()} );
	}

	IRREGULAR_CASE: {
		foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x",ord($z)) : 'undef()';
			is( $class->to_second($z), 0, '->to_second() The value: '.$argv );
			is( $class->tz2second($z), undef(), '->tz2second() The value: '.$argv );
		}

		foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			is( $class->to_second($n), 0, '->to_second() The value: '.$n );
			is( $class->tz2second($n), undef(), '->tz2second() The value: '.$n );
		}
	}

	MONTH_NAME: {
		my $month = undef();

		$month = $class->monthname(0);
		isa_ok( $month, q|ARRAY|, $class.q{->monthname(0)} );
		is( $month->[0], q{Jan}, $class.q{->monthname(0)->[0]} );
		is( $month->[9], q{Oct}, $class.q{->monthname(0)->[9]} );

		$month = $class->monthname(1);
		isa_ok( $month, q|ARRAY|, $class.q{->monthname(1)} );
		is( $month->[1], q{February}, $class.q{->monthname(1)->[1]} );
		is( $month->[8], q{September}, $class.q{->monthname(1)->[8]} );
	}

	DAY_OF_WEEK: {
		my $dayofweek = undef();

		$dayofweek = $class->dayofweek(0);
		isa_ok( $dayofweek, q|ARRAY|, $class.q{->dayofweek(0)} );
		is( $dayofweek->[1], q{Mon}, $class.q{->dayofweek(0)->[1]} );
		is( $dayofweek->[5], q{Fri}, $class.q{->dayofweek(0)->[5]} );

		$dayofweek = $class->dayofweek(1);
		isa_ok( $dayofweek, q|ARRAY|, $class.q{->dayofweek(1)} );
		is( $dayofweek->[0], q{Sunday}, $class.q{->dayofweek(1)->[0]} );
		is( $dayofweek->[6], q{Saturday}, $class.q{->dayofweek(1)->[6]} );
	}

	HOURS: {
		my $hours = $class->hourname(0);

		isa_ok( $hours, q|ARRAY|, $class.q{->hourname(0)} );
		is( $hours->[0], q{Midnight}, $class.q{->hourname(0)->[0]} );
		is( $hours->[6], q{Morning}, $class.q{->hourname(0)->[6]} );
		is( $hours->[12], q{Noon}, $class.q{->hourname(0)->[12]} );
		is( $hours->[18], q{Evening}, $class.q{->hourname(0)->[18]} );
	}
}

__END__
