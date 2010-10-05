# $Id: 016_address.t,v 1.3 2010/10/05 11:30:56 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Address;
use Kanadzuchi::RFC2822;
use Path::Class;
use Test::More ( tests => 1178 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Address|,
	'methods' => [ 'new', 'parse', 'canonify' ],
	'instance' => new Kanadzuchi::Address(
			'address' => 'user@example.jp' ),
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

CLASS_METHODS: {
	my $class = $T->class();
	my $email = q(POSTMASTER@BOUNCEHAMMER.JP);
	my $user = 'POSTMASTER';
	my $host = 'BOUNCEHAMMER.JP';
	my $heads = [
		'X-Actual-Recipient',
		'Final-Recipient',
		'Original-Recipient',
		'To',
		'Delivered-To',
		'From',
		'Return-Path',
		'Reply-To',
		'Errors-To',
		'X-Postfix-Sender',
		'Envelope-From',
		'X-Envelope-From',
		'Resent-From',
		'Sender',
		'Resent-Reply-To',
		'Apparently-From',
		'Envelope-To',
		'X-Envelope-To',
		'Resent-To',
		'Apparently-To',
	];
	my $froms = [
		q{"hoge" <hoge@example.jp>},
		q{"=?ISO-2022-JP?B?dummy?=" <fuga@example.jp>},
		q{"T E S T" <test@exampe.jp>},
		q{"Nanashi no gombe" <gombe@example.jp>},
		q{<root@example.jp>},
		q{User name <user@example.jp>},
		q{dummy@host <dummy@example.jp>},
		q{address@example.jp},
	];

	CONSTRUCTOR: {
		my $object = new Kanadzuchi::Address( 'address' => $email );

		isa_ok( $object, $class );
		is( $object->address(), lc($email), q{->address() = }.$object->address() );
		is( $object->user(), lc($user), q{->user() = }.$object->user() );
		is( $object->host(), lc($host), q{->host() = }.$object->host() );

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
			$object = new Kanadzuchi::Address( 'address' => $z );
			is( $object, undef(), q{->new(}.$argv.q{) = undef()} );
		}
	}

	PARSER: {
		my $mailbox = new Path::Class::File( $T->example().q{/17-messages.eml} );
		my $objects = undef();

		foreach my $l ( $mailbox->slurp( chomp => 1 ) )
		{
			next() unless($l);
			next() unless(length($l));
			next() unless( grep { $l =~ m{\A$_[:]\s+} } @$heads );

			map { $l =~ s{\A$_[:]\s+(RFC822;\s*)?}{}i; } @$heads;
			$l =~ y{[`'"()<>\r\n$]}{}d;
			$l =~ s{\s}{,}g;
			$l =~ s{\A[,;\s]}{}g;

			$objects = Kanadzuchi::Address->parse( [ $l ] );
			isa_ok( $objects, q|ARRAY| );

			foreach my $o ( @$objects )
			{
				isa_ok( $o, $class );
				ok( Kanadzuchi::RFC2822->is_emailaddress($o->address), q{->address() = }.$o->address() );
				ok( length($o->user), q{->user() = }.$o->user() );
				ok( Kanadzuchi::RFC2822->is_domainpart($o->host), q{->host() = }.$o->host() );
			}
		}

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
			$objects = Kanadzuchi::Address->parse( [$z] );
			isa_ok( $objects, q|ARRAY| );
			is( scalar(@$objects), 0, q{->parser(}.$argv.q{) = Empty array} );
		}
	}

	CANONIFY: {
		foreach my $e ( @$froms )
		{
			my $c = Kanadzuchi::Address->canonify($e);
			ok( Kanadzuchi::RFC2822->is_emailaddress($c), '->canonify('.$e.') => '.$c );
		}

		is( Kanadzuchi::Address->canonify(), q(), '->canonify() = Empty' );
		is( Kanadzuchi::Address->canonify([]), q(), '->canonify([]) = Empty' );
		is( Kanadzuchi::Address->canonify({}), q(), '->canonify([]) = Empty' );
		is( Kanadzuchi::Address->canonify(0), 0, '->canonify(0) = 0' );
	}
}


__END__

