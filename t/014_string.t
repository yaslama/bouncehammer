# $Id: 014_string.t,v 1.6 2010/07/07 09:05:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::String;
use Test::More ( tests => 105 );
no warnings 'once';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::String|,
	'methods' => [ 'token', 'is_validtoken' ],
	'instance' => undef(), );

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $T->class(), @{$T->methods()} );
}

MESSAGE_TOKEN: {
	my $c = $T->class();
	my $d = q();
	is( $c->token('hoge','fuga'), '58dabdb1c930521fc8ee80c5634e4db6', $c.q{->token()} );
	is( $c->token('HOGE','FUGA'), '58dabdb1c930521fc8ee80c5634e4db6', $c.q{->token()} );
	is( $c->token('hoge',''), q(), q{->token('hoge','')} );
	is( $c->token('','fuga'), q(), q{->token('','fuga')} );
	is( $c->token(0,0), q(), q{->token(0,0)} );
	ok( $c->is_validtoken($c->token('hoge','fuga')), '->is_validtoken() = 1' );

	FALSE: foreach my $f ( @{$Kanadzuchi::Test::FalseValues} )
	{
		my $argv = defined($f) ? sprintf("%#x",ord($f)) : 'undef';
		$d = $c->token( $f, $f );
		is( length($d), 0, q{->token(}.$argv.q{) = }.$d );
		is( $c->is_validtoken($d), 0, '->is_validtoken() = 0' );
	}

	CONTROL: foreach my $e ( @{$Kanadzuchi::Test::EscapeCharacters},
					@{$Kanadzuchi::Test::ControlCharacters}, @{$Kanadzuchi::Test::NegativeValues} ){

		my $argv = defined($e) ? sprintf("%#x",ord($e)) : 'undef';
		$d = $c->token( $e, $e );
		ok( length($d), q{->token(}.$e.q{) = }.$argv );
		ok( $c->is_validtoken($d), '->is_validtoken() = 1' );
	}
}

__END__
