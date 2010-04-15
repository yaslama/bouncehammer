# $Id: 018_rfc1893.t,v 1.1 2010/04/15 09:21:48 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RFC1893;
use Test::More ( tests => 130 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RFC1893|,
	'methods' => [ 'code2int', 'int2code', 'standardcode', 'internalcode' ],
	'instance' => undef(), );

my $StandardCode = {
	'temporary' => {
		'undefined'	=> 400,
		'hasmoved'	=> 416,
		'mailboxfull'	=> 422,
		'exceedlimit'	=> 423,
		'systemfull'	=> 431,
	},
	'permanent' => {
		'undefined'	=> 500,
		'userunknown'	=> 511,
		'hostunknown'	=> 512,
		'hasmoved'	=> 516,
		'filtered'	=> 520,
		'mailboxfull'	=> 522,
		'exceedlimit'	=> 523,
		'systemfull'	=> 531,
		'notaccept'	=> 532,
		'mesgtoobig'	=> 534,
		'mailererror'	=> 500,
		'securityerr'	=> 570,
	},
};

my $InternalCode = {
	'temporary' => {
		'undefined'	=> 480,
		'hasmoved'	=> 483,
		'mailboxfull'	=> 485,
		'exceedlimit'	=> 486,
		'systemfull'	=> 487,
	},
	'permanent' => {
		'undefined'	=> 580,
		'userunknown'	=> 581,
		'hostunknown'	=> 582,
		'hasmoved'	=> 583,
		'filtered'	=> 584,
		'mailboxfull'	=> 585,
		'exceedlimit'	=> 586,
		'systemfull'	=> 587,
		'notaccept'	=> 591,
		'mesgtoobig'	=> 592,
		'mailererror'	=> 593,
		'securityerr'	=> 594,
		'onhold'	=> 597,
	},
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
	my $dsstr = q();
	my $dsint = 0;
	my $dcode = q();

	STANDARD: foreach my $c ( keys(%$StandardCode) )
	{
		foreach my $r ( keys(%{$StandardCode->{$c}}) )
		{
			$dsint = $class->standardcode($r,$c);
			$dcode = $1.'.'.$2.'.'.$3 if( $dsint =~ m{(\d)(\d)(\d)} );
			is( $dsint, $StandardCode->{$c}->{$r}, sprintf("->standardcode(%s/%s) = %d", $c,$r,$dsint, ));

			$dsstr = $class->int2code($dsint);
			is( $dsstr, $dcode, sprintf("->int2code(%d) = %s", $dsint, $dsstr ) );

			$dsint = $class->code2int($dsstr);
			is( $dsint, $StandardCode->{$c}->{$r}, sprintf("->code2int(%s) = %d", $dsstr, $dsint) );
		}
	}

	INTERNAL: foreach my $c ( keys(%$InternalCode) )
	{
		foreach my $r ( keys(%{$InternalCode->{$c}}) )
		{
			$dsint = $class->internalcode($r,$c);
			$dcode = $1.'.'.$2.'.'.$3 if( $dsint =~ m{(\d)(\d)(\d)} );
			is( $dsint, $InternalCode->{$c}->{$r}, sprintf("->internalcode(%s/%s) = %d", $c,$r,$dsint, ));

			$dsstr = $class->int2code($dsint);
			is( $dsstr, $dcode, sprintf("->int2code(%d) = %s", $dsint, $dsstr ) );

			$dsint = $class->code2int($dsstr);
			is( $dsint, $InternalCode->{$c}->{$r}, sprintf("->code2int(%s) = %d", $dsstr, $dsint) );
		}
	}

	IRREGULAR: foreach my $e ( 0, 1, ' ', {}, [], undef() )
	{
		$dsint = $class->standardcode($e);
		is( $dsint, 0, sprintf("->standardcode(%s) = 0", defined($e) ? $e : 'undef') );

		$dsint = $class->internalcode($e);
		is( $dsint, 0, sprintf("->internalcode(%s) = 0", defined($e) ? $e : 'undef' ) );

		$dsstr = $class->int2code($e);
		is( $dsstr, q(), sprintf("->int2code(%s) = ''", defined($e) ? $e : 'undef' ) );

		$dsint = $class->code2int($e);
		is( $dsint, 0, sprintf("->code2int(%s) = 0", defined($e) ? $e : 'undef' ) );
	}
}

__END__
