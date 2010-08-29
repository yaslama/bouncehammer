# $Id: 070_crypt.t,v 1.1 2010/08/28 17:10:49 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Crypt;
use Test::More ( tests => 20 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $C = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Crypt|,
	'methods' => [ 'cryptcbc', 'encryptit', 'decryptit' ],
	'instance' => new Kanadzuchi::Crypt( 'cipher' => 'DES' ),
);

PREPROCESS: {
	isa_ok( $C->instance(), $C->class() );
	can_ok( $C->class(), @{$C->methods} );
}

REGULARCASE: {
	my $z = new Kanadzuchi::Crypt(
			'cipher' => 'DES',
			'salt' => 'hakatanoshio',
			'key' => '794-Uguisu-Heiankyo' );

	isa_ok( $z, q|Kanadzuchi::Crypt| );
	is( $z->cipher(), 'DES', '->cipher = DES' );
	is( $z->salt(), 'hakatanoshio', '->salt = hakatanoshio' );
	is( $z->key(), '794-Uguisu-Heiankyo', '->key = 794-Uguisu-Heiankyo');

	my $plaintext1 = 'muromachi-rokkaku';
	my $encrypted1 = q();
	my $decrypted1 = q();

	$encrypted1 = $z->encryptit($plaintext1);
	$decrypted1 = $z->decryptit($encrypted1);

	ok( $plaintext1, '1. Plain text = '.$plaintext1 );
	ok( $encrypted1, '1. Encrypted text = '.$encrypted1 );
	ok( $decrypted1, '1. Decrypted text = '.$decrypted1 );
	is( $plaintext1, $decrypted1, '1. Plain text == Decrypted text' );

	# Another salt
	$z->salt('nuchima-su');
	my $encrypted2 = $z->encryptit($plaintext1);
	my $decrypted2 = $z->decryptit($encrypted2);

	ok( $encrypted2, '2. Encrypted text = '.$encrypted2 );
	ok( $decrypted2, '2. Decrypted text = '.$decrypted2 );
	is( $plaintext1, $decrypted2, '2. Plain text == Decrypted text' );
	is( $decrypted1, $decrypted2, '2. Decrypted text(1) == Decrypted text(2)' );

	# Does not match
	$z->key('1467-ounin-no-ran');
	isnt( $z->decryptit( $encrypted2 ), $plaintext1 );
}

CIPHER: {
	foreach my $ci ( qw(Blowfish Rijndael IDEA DES Hoge) )
	{
		my $mp = 'Crypt/'.$ci.'.pm';
		my $cr = undef();

		$cr = new Kanadzuchi::Crypt('cipher' => $ci);
		eval { require $mp; };

		if( $@ )
		{
			is( $cr, undef(), 'Crypt::'.$ci.' Not Found' );
		}
		else
		{
			isa_ok( $cr, q|Kanadzuchi::Crypt| );
		}
	}
}






__END__
