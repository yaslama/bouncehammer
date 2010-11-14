# $Id: 012_time.t,v 1.7 2010/11/13 19:13:24 ak Exp $
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
use Time::Piece;
use Test::More ( tests => 360 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Time|,
	'methods' => [ 'to_second', 'monthname', 'dayofweek', 'hourname', 'o2d', 
			'abbr2tz', 'tz2second', 'second2tz', 'canonify' ],
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

	IRREGULAR_CASE: {
		foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x",ord($z)) : 'undef()';
			is( $class->to_second($z), 0, '->to_second() The value: '.$argv );
		}

		foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			is( $class->to_second($n), 0, '->to_second() The value: '.$n );
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

	OFFSET2DATE: {
		my $date = q();
		my $base = new Time::Piece;
		my $time = undef();

		foreach my $o ( -2, -1, 0, 1, 2 )
		{
			$date = $class->o2d($o);
			$base = Time::Piece->strptime($base->ymd(), "%Y-%m-%d");
			$time = Time::Piece->strptime($date, "%Y-%m-%d");
			like( $date, qr{\A\d{4}[-]\d{2}[-]\d{2}\z}, 'offset = '.$o.', date = '.$date );
			is( $time->epoch, $base->epoch - ( $o * 86400 ) );
		}

		foreach my $o ( 'a', ' ', 'string' )
		{
			$date = $class->o2d($o);
			$base = Time::Piece->strptime($base->ymd(), "%Y-%m-%d");
			$time = Time::Piece->strptime($date, "%Y-%m-%d");
			like( $date, qr{\A\d{4}[-]\d{2}[-]\d{2}\z}, 'offset = '.$o.', date = '.$date );
			is( $time->epoch, $base->epoch )
		}
	}

	CANONIFY: {
		my $datestrings = [
			q|Thu, 2 Jul 2008 04:01:03 +0900 (JST)|,
			q|Thu, 2 Jul 2008 04:01:03 +0900 (GMT)|,
			q|Thu, 2 Jul 2008 04:01:03 +0900 (UTC)|,
			q|Thu, 03 Mar 2010 12:46:23 +0900|,
			q|Thu, 17 Jun 2010 01:43:33 +0900|,
			q|Thu, 1 Apr 2010 20:51:58 +0900|,
			q|Thu, 01 Apr 2010 16:25:40 +0900|,
			q|27 Apr 2009 08:08:54 +0000|,
			q|Fri,18 Oct 2002 16:03:06 PM|,
			q|27 Sep 1998 00:51:27 -0400|,
			q|Sat, 21 Nov 1998 16:38:02 -0500 (EST)|,
			q|Sat, 21 Nov 1998 13:13:04 -0800 (PST)|,
			q|    Sat, 21 Nov 1998 15:40:24 -0600|,
			q|Thu, 19 Nov 98 06:53:46 +0100|,
			q|03 Apr 1998 09:59:35 +0200|,
			q|19 Mar 1998 20:55:10 +0100|,
			q|2010-06-18 17:17:52 +0900|,
			q|2010-06-18T17:17:52 +0900|,
			q|Foo, 03 Mar 2010 12:46:23 +0900|,
			q|Thu, 13 Mar 100 12:46:23 +0900|,
			q|Thu, 03 Mar 2001 12:46:23 -9900|,
			q|Thu, 03 Mar 2001 12:46:23 +9900|,
		];

		my $invaliddates = [
			q|Thu, 13 Bar 2000 12:46:23 +0900|,
			q|Thu, 13 Apr 1900 12:46:23 +0900|,
			q|Thu, 13 Apr 2200 12:46:23 +0900|,
			q|Thu, 03 Mar 2001 32:46:23 +0900|,
			q|Thu, 03 Mar 2001 12:86:23 +0900|,
			q|Thu, 03 Mar 2001 12:46:73 +0900|,
		];

		foreach my $d ( @$datestrings )
		{
			my $time = undef();
			my $text = Kanadzuchi::Time->canonify($d,0,1);
			ok( length $text, '->canonify('.$d.') = '.$text );

			$text =~ s/\s+[-+]\d{4}\z//;
			$time = Time::Piece->strptime($text,q|%a, %d %b %Y %T|);
			isa_ok( $time, q|Time::Piece| );
			ok( $time->cdate(), '->cdate() = '.$time->cdate() );

			$time = Kanadzuchi::Time->canonify($d,1,1);
			isa_ok( $time, q|Time::Piece| );
			ok( $time->cdate(), '->cdate() = '.$time->cdate() );
			is( $time->tzoffset(), 0, '->tzoffset() = 0' );
		}

		foreach my $d ( @$invaliddates )
		{
			my $text = Kanadzuchi::Time->canonify($d,0,1);
			ok( length($text) == 0, '->canonify('.$d.') = '.$text );

			my $time = Kanadzuchi::Time->canonify($d,1,1);
			is( $time, undef(), '->canonify('.$d.') = undef' );
		}
	}

	ABBR2TZ: {
		is( $class->abbr2tz('GMT'), '+0000', 'GMT = +0000' );
		is( $class->abbr2tz('UTC'), '-0000', 'UTC = -0000' );
		is( $class->abbr2tz('JST'), '+0900', 'JST = +0900' );
		is( $class->abbr2tz('PDT'), '-0700', 'PDT = -0700' );
		is( $class->abbr2tz('MST'), '-0700', 'MST = -0700' );
		is( $class->abbr2tz('CDT'), '-0500', 'CDT = -0500' );
		is( $class->abbr2tz('EDT'), '-0400', 'EDT = -0400' );
		is( $class->abbr2tz('HST'), '-1000', 'HST = -1000' );
		is( $class->abbr2tz('UT'),  '-0000', 'UT  = -0000' );
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
			is( $class->tz2second($z), undef(), '->tz2second() The value: '.$argv );
		}

		foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			is( $class->tz2second($n), undef(), '->tz2second() The value: '.$n );
		}
	}
}

__END__
