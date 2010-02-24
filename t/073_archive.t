# $Id: 073_archive.t,v 1.2 2009/12/22 06:34:42 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Archive;
use Test::More ( tests => 12 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $A = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Archive|,
	'methods' => [ 'ARCHIVEFORMAT', 'new', 'compress', 'is_available' ],
	'instance' => new Kanadzuchi::Archive( 'input' => './examples/17-messages.eml' ),
);

PREPROCESS: {
	isa_ok( $A->instance(), $A->class() );
	can_ok( $A->class(), @{$A->methods} );
}

CONSTRUCTOR: {
	my $z = $A->instance();
	my $c = $A->class();

	isa_ok( $z, $c );
	isa_ok( $z->input(), q|Path::Class::File|, q{->input() = }.$z->input->stringify() );
	isa_ok( $z->output(), q|Path::Class::File|, q{->output() = }.$z->output->stringify() );
	ok( $c->ARCHIVEFORMAT(), q{->ARCHIVEFORMAT() = }.$c->ARCHIVEFORMAT() );
	ok( $z->filename(), q{->filename() = }.$z->filename() );
	is( $z->format(), 'gzip', q{->format() = gzip} );
	is( $z->prefix(), 'gz', q{->prefix() = gz} );
	is( $z->override(), 0, q{->override() = 0} );
	is( $z->cleanup(), 0, q{->cleanup() = 0} );
	is( $z->level(), 6, q{->level() = 6} );
}

__END__
