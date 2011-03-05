# $Id: 010_kanadzuchi.t,v 1.6.2.2 2011/03/05 10:29:18 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi;
use File::Basename qw(basename);
use Path::Class::File;
use Test::More ( tests => 125 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi|,
	'methods' => [ 'new', 'is_exception', 'load', 'is_logfile', 'get_logfile',
			'historique' ],
	'instance' => new Kanadzuchi(),
);

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class() );
	can_ok( $T->class(), @{$T->methods()} );
}

PROPERTIES: {
	my $object = $T->instance();
	my $classx = $T->class();

	is( $object->myname(), $classx, $classx.q{->myname()} );
	is( $object->version(), $Kanadzuchi::VERSION, $classx.q{->version()} );
	like( $object->user(), qr(\A\d+\z), $classx.q{->user()} );
}

METHODS: {
	my $object = $T->instance();
	my $classx = $T->class();

	LOAD: {
		my $loaded = 0;

		SUCCESS: {
			foreach my $c ( 'prove.cf', 'test-run.cf' )
			{
				$object->config( {} );
				ok( $object->load( q{./src/etc/}.$c ), q{->load(}.$c.q{)} );
				isa_ok( $object->config, q|HASH| );
				ok( length($object->config->{'system'}) );
				ok( length($object->config->{'version'}) );
				ok( length($object->config->{'name'}) );

			}
		}

		DOES_NOT_EXIST: {
			$object->config( {} );
			$loaded = $object->load( '/doesnotexist' );
			isa_ok( $loaded, q|Kanadzuchi::Exception::IO|, q{->load(/doesnotexist)} );
		}

		DEV_NULL: {
			$object->config( {} );
			$loaded = $object->load( '/dev/null' );
			ok( $loaded, $classx.q{->load(/dev/null)});

			$loaded = $object->load( '/dev/null' );
			is( $loaded, 0, $classx.q{->load(/dev/null) Again});
		}
	}

	IS_EXCEPTION: {
		my $text = 'Test';
		my $excp = bless( \$text, q|Kanadzuchi::Exception::System| );

		is( $classx->is_exception($excp), 1, q{->is_exception = 1} );
		is( $classx->is_exception($text), 0, q{->is_exception = 0} );
	}

	IS_LOGFILE: {
		my $tlog = q(/tmp/hammer.1970-01-01.ffffffff.000000.tmp);
		my $rlog = q(/tmp/hammer.1970-01-01.log);

		is( $object->is_logfile( '/dev/zero' ), 0, $classx.q{->is_logfile(/dev/zero)});
		is( $object->is_logfile( 'the log file' ), 0, $classx.q{->is_logfile(the log file)});
		is( $object->is_logfile( [] ), 0, $classx.q{->is_logfile([])});
		is( $object->is_logfile( {} ), 0, $classx.q|->is_logfile({}|);
		is( $object->is_logfile( $tlog ), 1, $classx.q{->is_logfile(}.$tlog.q{)} );
		is( $object->is_logfile( $rlog ), 2, $classx.q{->is_logfile(}.$rlog.q{)} );

		FALSE: foreach my $f ( @{$Kanadzuchi::Test::FalseValues}, @{$Kanadzuchi::Test::ZeroValues} )
		{
			my $argv = defined($f) ? sprintf("%#x",ord($f)) : 'undef()';
			is( $object->is_logfile( $f ), 0, q{->is_logfile(}.$argv.q{)} );
		}

		NEGATIVE: foreach my $n ( @{$Kanadzuchi::Test::NegativeValues} )
		{
			my $argv = defined($n) ? sprintf("%#x",ord($n)) : 'undef()';
			is( $object->is_logfile( $n ), 0, q{->is_logfile(}.$argv.q{)} );
		}

		CONTORL: foreach my $c ( @{$Kanadzuchi::Test::EscapeCharacters}, @{$Kanadzuchi::Test::ControlCharacters} )
		{
			my $argv = defined($c) ? sprintf("%#x",ord($c)) : 'undef()';
			is( $object->is_logfile( $c ), 0, '->is_logfile('.$argv.')' );
		}
	}

	GET_LOGFILE: {
		my( $tlog, $rlog, $flog, $mlog );

		foreach my $d ( '', '1970-01-01', 'a', 0, ' ', undef(), {} )
		{
			$tlog = $object->get_logfile('t',{ 'output' => '/var/tmp', 'date' => $d } );
			$rlog = $object->get_logfile('r',{ 'output' => './.test', 'date' => $d } );
			$flog = $object->get_logfile('f',{ 'output' => './examples', 'date' => $d } );
			$mlog = $object->get_logfile('m',{ 'output' => '/', 'date' => $d } );

			ok( $object->is_logfile($tlog), $classx.q|->is_logfile = |.$tlog );
			ok( $object->is_logfile($rlog), $classx.q|->is_logfile = |.$rlog );
			ok( $object->is_logfile($flog), $classx.q|->is_logfile = |.$flog );
			ok( $object->is_logfile($mlog), $classx.q|->is_logfile = |.$mlog );
		}

	}
}
__END__
