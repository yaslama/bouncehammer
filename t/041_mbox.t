# $Id: 041_mbox.t,v 1.3 2010/05/29 01:39:39 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Mbox;
use Time::Piece;
use File::Copy;
use Test::More ( tests => 1785 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mbox|,
	'methods' => [ 'ENDOF', 'new', 'slurpit', 'parseit', '_breakit' ],
	'instance' => new Kanadzuchi::Mbox(),
);
my $NonEmailFiles = { 'binary' => [], 'text' => [] };

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class() );
	can_ok( $T->class(), @{$T->methods()} );

	PREPARE_NON_EMAIL_FILES: {

		my $tempdir = $T->tempdir->stringify();

		File::Copy::copy( '/bin/ls', $tempdir.'/binary' );
		$NonEmailFiles->{'binary'} = [ '/dev/null', '/dev/zero', '/doesnotexist', '/var/tmp', '/tmp' ];
		push( @{$NonEmailFiles->{'binary'}}, $tempdir.'/binary', 'x y z', '1;2;3', qq(a\nz) );
		push( @{$NonEmailFiles->{'binary'}}, qq(a\az), qq(a\bz), qq(a\fz), qq(a\tz), qq(a\rz) );
		push( @{$NonEmailFiles->{'binary'}}, qq(a\cCz), qq(a\ez) );

		$NonEmailFiles->{'text'} = [ './Makefile.PL', '../configure.ac', '../acinclude.m4', '../NEWS' ];
	}
}

PARSE_EACH_MAILBOX: foreach my $f ( 'single-message.eml', 'double-messages.eml', '17-messages.eml' )
{
	my $object = new Kanadzuchi::Mbox( 'file' => $T->example->stringify().'/'.$f );
	my $classx = $T->class();

	CONSTRUCTOR: {
		isa_ok( $object, q|Kanadzuchi::Mbox| );
		isa_ok( $object->emails(), q|ARRAY|, q{->emails = 0} );
		isa_ok( $object->messages(), q|ARRAY|, q{->messages = 0} );

		is( $object->file(), $T->example->stringify().'/'.$f, q{->file = }.$f );
		is( $object->greed(), 0, q{->greed = 0} );
		is( $object->nmails(), 0, q{->nmails = 0} );
		is( $object->nmesgs(), 0, q{->nmesgs = 0} );
	}

	SLURPIT: {
		ok( $object->slurpit(), q{->slurpit()} );
		ok( $object->nmails(), q{->nmails = }.$object->nmails() );
		isa_ok( $object->emails(), q|ARRAY| );

		foreach my $s ( @{$object->emails()} )
		{
			ok( length($s), q{->emails() has length = }.length($s) );
			like( $s, qr{\n__THE_END_OF_THE_EMAIL__\n\z}, q{Ends with __THE_END_OF_THE_EMAIL__} );
		}
	}

	PARSEIT: {
		ok( $object->parseit(), q{->parseit()} );
		ok( $object->nmesgs(), q{->nmesgs() = }.$object->nmesgs() );
		isa_ok( $object->messages(), q|ARRAY| );
	}

	foreach my $p ( @{$object->messages} )
	{
		my $h = $p->{'head'};

		isa_ok( $p, q|HASH| );
		isa_ok( $h, q|HASH| );

		ok( length($p->{'from'}), q{UNIX From line = }.$p->{'from'} );
		ok( length($p->{'body'}), q{Body has length = }.length($p->{'body'}) );
		ok( length($h->{'content-type'}), q{Content-Type: }.$h->{'content-type'} );
		ok( length($h->{'from'}), q{From: }.$h->{'from'} );
		ok( length($h->{'to'}), q{To: }.$h->{'to'} );
		ok( length($h->{'subject'}), q{Subject: }.$h->{'subject'} );
		ok( length($h->{'date'}), q{Date: }.$h->{'date'} );
	}
}

TODO: {
	local $TODO = 'Not implemented';
	READ_FROM_STDIN : {
		;
	}
}

PARSE_NON_MAILBOX_TEXT: foreach my $x ( @{$NonEmailFiles->{'text'}} )
{
	my $object = new Kanadzuchi::Mbox( 'file' => $x );
	my $classx = $T->class();

	CONSTRUCTOR: {
		isa_ok( $object, q|Kanadzuchi::Mbox| );
		isa_ok( $object->emails(), q|ARRAY|, q{->emails = 0} );
		isa_ok( $object->messages(), q|ARRAY|, q{->messages = 0} );

		is( $object->file(), $x, q{->file = }.$x );
		is( $object->greed(), 0, q{->greed = 0} );
		is( $object->nmails(), 0, q{->nmails = 0} );
		is( $object->nmesgs(), 0, q{->nmesgs = 0} );
	}

	SLURPIT: {
		is( $object->slurpit(), 1, q{->slurpit() = 1} ) if( -s $x );
		is( $object->slurpit(), 0, q{->slurpit() = 0} ) if( -z $x );
		is( $object->nmails(), 1, q{->nmails = 1} ) if( -s $x );
		is( $object->nmails(), 0, q{->nmails = 0} ) if( -z $x );
		isa_ok( $object->emails(), q|ARRAY| );
	}

	PARSEIT: {
		is( $object->parseit(), 0, q{->parseit() = 0} );
		is( $object->nmesgs(), 0, q{->nmails() = 0} );
		isa_ok( $object->messages(), q|ARRAY| );
	}
}

PARSE_NON_MAILBOX_BINARY: foreach my $y ( @{$NonEmailFiles->{'binary'}}, 
	[], {}, @{$Kanadzuchi::Test::ExceptionalValues} ){

	next() unless(defined($y));
	my $object = new Kanadzuchi::Mbox( 'file' => $y );
	my $classx = $T->class();

	CONSTRUCTOR: {
		isa_ok( $object, q|Kanadzuchi::Mbox| );
		isa_ok( $object->emails(), q|ARRAY|, q{->emails = 0} );
		isa_ok( $object->messages(), q|ARRAY|, q{->messages = 0} );

		is( $object->file(), $y, q{->file = }.$y );
		is( $object->greed(), 0, q{->greed = 0} );
		is( $object->nmails(), 0, q{->nmails = 0} );
		is( $object->nmesgs(), 0, q{->nmesgs = 0} );
	}

	SLURPIT: {
		is( $object->slurpit(), 0, q{->slurpit() = 0} );
		is( $object->nmails(), 0, q{->nmails = 0} );
		isa_ok( $object->emails(), q|ARRAY| );
		is( $#{$object->emails()}, -1, q{Empty array} );
	}

	PARSEIT: {
		is( $object->parseit(), 0, q{->parseit() = 0} );
		is( $object->nmesgs(), 0, q{->nmails() = 0} );
		isa_ok( $object->messages(), q|ARRAY| );
		is( $#{$object->messages()}, -1, q{Empty array} );
	}
}



__END__
