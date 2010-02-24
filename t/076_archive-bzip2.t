# $Id: 076_archive-bzip2.t,v 1.2 2009/12/22 06:34:42 ak Exp $
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
use Kanadzuchi::Archive::Bzip2;
use Path::Class;
use File::Copy;
use File::Basename;
use Test::More ( tests => 119 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $B = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Archive::Bzip2|,
	'methods' => [ 'ARCHIVEFORMAT', 'new', 'compress', 'is_available' ],
	'instance' => new Kanadzuchi::Archive::Bzip2(),
);
my $Prefix = 'bz2';

PREPROCESS: {
	isa_ok( $B->instance(), $B->class() );
	can_ok( $B->class(), @{$B->methods} );
}


foreach my $archive ( $B )
{
	my $object = undef();
	my $classx = $archive->class();
	my $testsf = $B->tempdir().'/17-messages.eml';
	my $zipped = $B->tempdir().'/17-messages.bz2';
	my $format = lc( [ reverse(split( '::', $classx )) ]->[0] );
	my $zisize = 0;
	my $lvsize = 0;

	File::Copy::copy( $B->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );
	unlink( $testsf.q{.bz2} ) if( -e $testsf.q{.bz2} );
	unlink( $zipped ) if( -e $zipped );

	my $z1 = $classx->new( 'input' => $testsf );
	my $z2 = $classx->new( 'input' => $testsf, 'output' => $zipped );
	my $z3 = $classx->new( 'input' => $testsf, 'output' => $zipped, 'filename' => '17.eml' );

	SKIP: {
		skip( 'There is no IO::Copress::Bzip2 module', 117 ) unless( $z1->is_available() );

		foreach my $z ( $z1, $z2, $z3 )
		{
			File::Copy::copy( $B->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );

			CONSTRUCTOR: {
				isa_ok( $z, $classx );
				isa_ok( $z->input(), q|Path::Class::File|, q{->input() = }.$z->input->stringify() );
				isa_ok( $z->output(), q|Path::Class::File|, q{->output() = }.$z->output->stringify() );
				ok( $z->filename(), q{->filename() = }.$z->filename() );
				is( $z->format(), $format, q{->format() = }.$format );
				is( $z->prefix(), $Prefix, q{->prefix() = }.$Prefix );
				is( $z->override(), 0, q{->override() = 0} );
				is( $z->cleanup(), 0, q{->cleanup() = 0} );
				is( $z->level(), 6, q{->level() = 6} );
			}

			COMPRESS: {
				$zisize = $z->compress();
				$lvsize = 2 ** 31;

				ok( $zisize, q{->compress() returns size = }.$zisize );
				ok( -f $z->output(), q{->output exists = }.$z->output() );
				is( -s $z->output(), $zisize, q{->output file size = }.$zisize );

				$z->output->remove();
				$z->override(1);
				$z->cleanup(1);

				LEVEL_AND_OVERRIDE_AND_CLEANUP: foreach my $lv ( 1 .. 9 )
				{
					File::Copy::copy( $B->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );
					$z->level($lv);
					$zisize = $z->compress();

					ok( $zisize, q{->compress() with level }.$lv.q{ returns size = }.$zisize );
					ok( ( $zisize <= $lvsize ), qq{ $zisize <= $lvsize } );
					ok( ( ! -f $z->input() ), $z->input().q{ is removed(->cleanup())} );

					$lvsize = $zisize;
				}

				$z->override(0);
				$z->cleanup(0);
				$z->output->remove() if( -e $z->output() );
			}
		}
	}
}

__END__
