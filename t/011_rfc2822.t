# $Id: 011_rfc2822.t,v 1.3 2010/02/17 16:07:58 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RFC2822;
use Test::More ( tests => 225 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RFC2822|,
	'methods' => [
		'is_emailaddress', 'is_domainpart', 'expand_subaddress',
		'is_mailerdaemon', 'is_subaddress', 'cleanup' ],
	'instance' => undef(), );

my $e = {
	'ok' => q{postmaster@example.jp},
	'ng' => q{postmaster-example-jp},
};
my $s = {
	'ok' => q{postmaster+hostmaster@example.jp},
	'ng' => q{postmaster-hostmaster@example.jp},
};
my $x = {
	'ok' => q{bounce+postmaster=example.org@example.jp},
	'ng' => q{bounce-postmaster@example.jp},
};
my $d = {
	'ok' => q{example.jp},
	'ng' => q{.},
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $T->class(), @{$T->methods()} );
}

CLASS_METHODS: {
	my $class = $T->class();

	VALID_ADDRESS: {
		ok( $class->is_emailaddress($e->{ok}), q{Check valid address} );
		ok( $class->is_domainpart($d->{ok}), q{Check valid domain}  );
		ok( $class->is_mailerdaemon(q{MAILER-DAEMON}), q{Check MAILER-DAEMON}  );
		ok( $class->is_subaddress($s->{ok}), q{Check sub-address} );

		my $xa = $class->expand_subaddress($x->{ok});
		is( $class->expand_subaddress($x->{ok}), $xa, q{Expand sub-address = }.$xa );

		like( $class->cleanup(qq| <$e->{ok}> |), qr($e->{ok}) );
	}

	INVALID_ADDRESS: {
		is( $class->is_emailaddress($e->{ng}),0, q{Check invalid address} );
		is( $class->is_domainpart($d->{ng}),0, q{Check invalid domain}  );
		is( $class->is_mailerdaemon(q{Postmaster}),0, q{Check Non MAILER-DAEMON} );
		is( $class->is_subaddress($s->{ng}), 0, q{Check invalid sub-address} );

		my $xa = $class->expand_subaddress($x->{ng});
		is( $class->expand_subaddress($x->{ng}), q{}, q{Expand invalid sub-address = } );
	}

	CLEANUP: {
		my $a = $e->{'ok'};

		foreach my $m ( $a, ' '.$a, $a.' ', ' '.$a.' ', 'mailto:'.$a, '<'.$a.'>' )
		{
			is( $class->cleanup($m), $a, qq{->cleanup($m) == $a} );
			ok( $class->is_emailaddress( $class->cleanup($m) ), qq{->is_emailaddress($m)} );
		}
	}

	IRREGULAR_CASES: {

		foreach my $e ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($e) ? sprintf("%#x",ord($e)) : 'undef()';
			is( $class->is_emailaddress($e) ,0, '->is_emailaddress('.$argv.')' );
			is( $class->is_mailerdaemon($e) ,0, '->is_mailerdaemon('.$argv.')' );
			is( $class->is_domainpart($e) ,0, '->is_domainpart('.$argv.')' );
		}
	}
}

__END__
