# $Id: 151_ui-cli.t,v 1.5 2010/05/17 00:00:56 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::UI::CLI;
use Path::Class::File;
use JSON::Syck;
use File::Basename qw(basename);
use Test::More ( tests => 700 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $K = new Kanadzuchi();
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::UI::CLI|,
	'methods' => [ 'new', 'init', 'batchstatus', 'd', 'e', 'catch_signal',
			'DESTROY', 'abort', 'exception', 'finish' ],
	'instance' => new Kanadzuchi::UI::CLI(
		'commandline' => join(q{ }, $0, @ARGV ),
	),
);
my $P = {};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {

	isa_ok( $T->instance(), $T->class() );
	can_ok( $T->class(), @{$T->methods()} );
}

CONSTRUCTOR: {

	my $o = $T->instance();
	isa_ok( $o->option(), q|HASH|, q{->option()} );

	is( $o->cf(), undef(), q{->cf() = undefined} );
	is( $o->operation(), 0, q{->operation() = 0} );
	is( $o->debuglevel(), 0, q{->debuglevel() = 0} );
	is( $o->calledfrom(), File::Basename::basename($0), q{->calledfrom() = }.$o->calledfrom() );
	ok( $o->processid(), q{->processid() = }.$o->processid() );
	ok( length($o->commandline()), q{->commandline() = }.$o->commandline() );
}

foreach my $cf ( './src/etc/prove.cf', './src/etc/test-run.cf', '/dev/null', '/doesnotexist' )
{

	DESTORACTOR_OF_PREVIOUS_OBJECT: {
		last() unless(defined($P));
		last() unless(defined($P->{'tmpdir'}));
		last() unless(defined($P->{'pf'}));
		ok( ! -d $P->{'tmpdir'}, q|DESTROY(): $P->{tmpdir} = |.$P->{'tmpdir'} );
		ok( ! -f $P->{'pf'}, q|DESTROY(): $P->{pf} = |.$P->{'pf'} );
		$P = {};
	}

	my $o = new Kanadzuchi::UI::CLI( 
		'commandline' => $T->instance->commandline(), 'cf' => $cf );
	my $l = 0;

	PREPROCESS: {

		isa_ok( $o, $T->class() );
		can_ok( $o, @{$T->methods()} );
	}

	CONSTRUCTOR: {

		isa_ok( $o->option(), q|HASH|, q{->option()} );

		is( $o->operation(), 0, q{->operation() = 0} );
		is( $o->debuglevel(), 0, q{->debuglevel() = 0} );
		is( $o->calledfrom(), File::Basename::basename($0), q{->calledfrom() = }.$o->calledfrom() );
		ok( $o->processid(), q{->processid() = }.$o->processid() );
		ok( length($o->commandline()), q{->commandline() = }.$o->commandline() );
	}

	INITIALIZED: {
		$K->config( {} );
		$l = $K->load( $o->cf() );

		if( defined($o->cf) && -e $o->cf )
		{
			isa_ok( $K->config(), q|HASH| );
			isa_ok( $o->cf(), q|Path::Class::File|, q{->cf()} );
			like( $o->cf->stringify(), qr{/}, q{->cf() = }.$o->cf->stringify() );
			ok( length($K->config->{'system'}), q{Kanadzuchi->config->system = }.$K->config->{'system'} );
			is( $l, 1, q{Kanadzuchi->load() = }.$o->cf->stringify() );
		}
		else
		{
			isnt( ref($o->cf()), q|Path::Class::File|, q{->cf()} );
			is( ref($l), q|Kanadzuchi::Exception::IO|, q{Kanadzuchi->load() = } );
			$P = {};
			next();
		}
		ok( $o->init( $K ), q{->init()} );

		ENVIRONMENT: {
			is( $ENV{'LANG'}, q(C), q|ENV{LANG} = C| );
			is( $ENV{'LC_ALL'}, q(C), q|ENV{LC_ALL} = C| );
			is( exists($ENV{'IFS'}), q(), q|ENV{IFS} is removed| );
			is( exists($ENV{'CDPATH'}), q(), q|ENV{CDPATH} is removed| );
			is( exists($ENV{'ENV'}), q(), q|ENV{ENV} is removed| );
			is( exists($ENV{'BASH_ENV'}), q(), q|ENV{BASH_ENV} is removed| );
		}

		OTHER_MEMBERS: {
			isa_ok( $o->tmpdir(), q|Path::Class::Dir|, q{->tmpdir()} );
			isa_ok( $o->pf(), q|Path::Class::File|, q{->pf()} );

			ok( -d $o->tmpdir(), q{->tmpdir() = }.$o->tmpdir->stringify() );
			ok( -f $o->pf, q{->pf() = }.$o->pf->stringify() );
		}

		$P = { 'tmpdir' => $o->tmpdir->stringify(), 'pf' => $o->pf->stringify(), };
	}
}

foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
{
	my $l = 0;
	my $o = new Kanadzuchi::UI::CLI( 
		'commandline' => $T->instance->commandline(), 'cf' => $e );
	$a = defined($e) ? sprintf("%#x", ord($e)) : 'undef()';

	PREPROCESS: {

		isa_ok( $o, $T->class() );
		can_ok( $o, @{$T->methods()} );
	}

	CONSTRUCTOR: {

		isa_ok( $o->option(), q|HASH|, q{->option()} );

		isnt( ref($o->cf()), q|Path::Class::File|, q{->cf() = undef, }.$a );
		is( $o->operation(), 0, q{->operation() = 0} );
		is( $o->debuglevel(), 0, q{->debuglevel() = 0} );
		is( $o->calledfrom(), File::Basename::basename($0), q{->calledfrom() = }.$o->calledfrom() );
		ok( $o->processid(), q{->processid() = }.$o->processid() );
		ok( length($o->commandline()), q{->commandline() = }.$o->commandline() );
	}
}

__END__
