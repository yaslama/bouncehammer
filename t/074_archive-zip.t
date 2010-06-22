# $Id: 074_archive-zip.t,v 1.3 2010/06/22 07:17:15 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Test::More ( tests => 119 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
SKIP: {
	my $Skip = 119;
	eval { require IO::Compress::Zip; }; 
	skip( 'Because no IO::Compress::Zip for testing', $Skip ) if( $@ );

	require Kanadzuchi::Test;
	require Path::Class;
	require File::Copy;
	require File::Basename;
	require Kanadzuchi::Archive;
	require Kanadzuchi::Archive::Zip;

	my $Z = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::Archive::Zip|,
		'methods' => [ 'ARCHIVEFORMAT', 'new', 'compress', 'is_available' ],
		'instance' => new Kanadzuchi::Archive::Zip(),
	);
	my $Prefix = 'zip';

	PREPROCESS: {
		isa_ok( $Z->instance(), $Z->class() );
		can_ok( $Z->class(), @{$Z->methods} );
	}

	foreach my $archive ( $Z )
	{
		my $object = undef();
		my $classx = $archive->class();
		my $testsf = $Z->tempdir().'/17-messages.eml';
		my $zipped = $Z->tempdir().'/17-messages.zip';
		my $format = lc( [ reverse(split( '::', $classx )) ]->[0] );
		my $zisize = 0;
		my $lvsize = 0;

		File::Copy::copy( $Z->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );
		unlink( $testsf.q{.zip} ) if( -e $testsf.q{.zip} );
		unlink( $zipped ) if( -e $zipped );

		my $z1 = $classx->new( 'input' => $testsf );
		my $z2 = $classx->new( 'input' => $testsf, 'output' => $zipped );
		my $z3 = $classx->new( 'input' => $testsf, 'output' => $zipped, 'filename' => '17.eml' );


		skip( 'There is no IO::Copress::Zip module', 117 ) unless( $z1->is_available() );

		foreach my $z ( $z1, $z2, $z3 )
		{
			File::Copy::copy( $Z->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );

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
					File::Copy::copy( $Z->example().q{/17-messages.eml}, $testsf ) unless( -e $testsf );
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
