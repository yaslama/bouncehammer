# $Id: 090_log.t,v 1.5 2010/03/07 04:05:08 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Mail::Bounced;
use Kanadzuchi::Mbox;
use Kanadzuchi::Log;
use Path::Class;
use Test::More ( tests => 17 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $L = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Log|,
	'methods' => [ 'new', 'logger', 'dumper' ],
);

my $NM = 37;
my $OF = [ 'yaml', 'asciitable' ];
my $MR = undef();
my $TD = new Path::Class::Dir($L->tempdir().q{/hammer-log.temp.}.$$);
my $KP = new Kanadzuchi::Mbox( 'file' => $L->example->stringify().'/17-messages.eml' );

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	$L->instance( new Kanadzuchi::Log(
		'directory' => new Path::Class::Dir($L->tempdir()),
		'logfile' => new Path::Class::File($L->tempdir().q{/test-data.tmp}),
		'entities' => [],
		'count' => 0,
		'format' => q{yaml},
		'device' => q{STDOUT}, )
	);

	isa_ok( $L->instance(), $L->class() );
	isa_ok( $L->instance->directory(), q|Path::Class::Dir| );
	isa_ok( $L->instance->logfile(), q|Path::Class::File| );
	can_ok( $L->class(), @{$L->methods} );

	isa_ok( $TD, q|Path::Class::Dir| );
	isa_ok( $KP, q|Kanadzuchi::Mbox| );

	CALL_PARSER: {
		is( $KP->slurpit(), $NM, q|Kanadzuchi::Mbox->slurpit()| );
		is( $KP->parseit(), $NM, q|Kanadzuchi::Mbox->parseit()| );

		$TD->mkpath() unless( -e $TD->stringify() );
		$MR = Kanadzuchi::Mail::Bounced->eatit( 
			\$KP, { cache => $TD->stringify(), 'greed' => 1, 'verbose' => 0 } );

		isa_ok( $MR, q|ARRAY| );
	}

	$L->instance->entities( $MR );
	$L->instance->count( $#{$MR} + 1 );
}

LOG_INSTANCE: {

	my $dumpeddata = q();

	isa_ok( $L->instance->entities(), q|ARRAY|, $L->class.q{->entities()} );

	is( $L->instance->count(), $NM, $L->class.q{->count()} );
	is( $L->instance->format(), q{yaml}, $L->class.q{->format()} );
	is( $L->instance->device(), q{STDOUT}, $L->class.q{->device()} );

	OUTPUT_FORMAT: foreach my $f ( @$OF )
	{
		$L->instance->format( $f );

		$dumpeddata = $L->instance->logger();
		ok( length($dumpeddata), $L->class.'->logger() with '.$f );

		$dumpeddata = $L->instance->dumper();
		ok( length($dumpeddata), $L->class.'->dumper() with '.$f );
	}
}

__END__
