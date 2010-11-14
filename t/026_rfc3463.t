# $Id: 026_rfc3463.t,v 1.2 2010/11/13 19:13:25 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::RFC3463;
use Test::More ( tests => 109 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::RFC3463|,
	'methods' => [ 'status', 'causa' ],
	'instance' => undef(), );

my $StandardCode = {
	'temporary' => {
		# 'undefined'	=> [ '4.0.0' ],
		'hasmoved'	=> [ '4.1.6' ],
		'rejected'	=> [ '4.1.8' ],
		'mailboxfull'	=> [ '4.2.2' ],
		'exceedlimit'	=> [ '4.2.3' ],
		'systemfull'	=> [ '4.3.1' ],
		'systemerror'	=> [ '4.3.5' ],
		'expired'	=> [ '4.4.7' ],
	},
	'permanent' => {
		# 'undefined'	=> [ '5.0.0', '5.5.1', '5.5.2', '5.5.3', '5.5.4', '5.5.5' ],
		'userunknown'	=> [ '5.1.1', '5.1.0' ],	# 5.1.3 ?
		'hostunknown'	=> [ '5.1.2' ],
		'hasmoved'	=> [ '5.1.6' ],
		'rejected'	=> [ '5.1.8', '5.1.7' ],
		'filtered'	=> [ '5.2.1', '5.2.0' ],
		'mailboxfull'	=> [ '5.2.2' ],
		'exceedlimit'	=> [ '5.2.3' ],
		'systemfull'	=> [ '5.3.1' ],
		'notaccept'	=> [ '5.3.2' ],
		'mesgtoobig'	=> [ '5.3.4' ],
		'systemerror'	=> [ '5.3.5', '5.3.0', '5.4.0', '5.4.1', '5.4.2', '5.4.3', '5.4.4', '5.4.5', '5.4.6',],
		'expired'	=> [ '5.4.7' ],
		'mailererror'	=> [ '5.2.4' ],
		'contenterr'	=> [ '5.6.0' ],
		'securityerr'	=> [ '5.7.0' ],
	},
};

my $InternalCode = {
	'temporary' => {
		'undefined'	=> [ '4.0.900' ],
		'hasmoved'	=> [ '4.0.916' ],
		'mailboxfull'	=> [ '4.0.922' ],
		'exceedlimit'	=> [ '4.0.923' ],
		'systemfull'	=> [ '4.0.931' ],
		'suspend'	=> [ '4.0.990' ],
	},
	'permanent' => {
		'undefined'	=> [ '5.0.900' ],
		'userunknown'	=> [ '5.0.911' ],
		'hostunknown'	=> [ '5.0.912' ],
		'hasmoved'	=> [ '5.0.916' ],
		'rejected'	=> [ '5.0.918' ],
		'filtered'	=> [ '5.0.921' ],
		'mailboxfull'	=> [ '5.0.922' ],
		'exceedlimit'	=> [ '5.0.923' ],
		'systemfull'	=> [ '5.0.931' ],
		'notaccept'	=> [ '5.0.932' ],
		'mesgtoobig'	=> [ '5.0.934' ],
		'systemerror'	=> [ '5.0.935' ],
		'expired'	=> [ '5.0.947' ],
		'contenterr'	=> [ '5.0.960' ],
		'securityerr'	=> [ '5.0.970' ],
		'mailererror'	=> [ '5.0.991' ],
		'onhold'	=> [ '5.0.999' ],
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
	my $klass = q();
	my $causa = q();
	my $state = q();

	STANDARD: foreach my $c ( keys(%$StandardCode) )
	{
		$klass = substr($c,0,1);
		foreach my $r ( keys(%{$StandardCode->{$c}}) )
		{
			$state = $class->status($r,$klass,'s');
			is( $state, $StandardCode->{$c}->{$r}->[0], sprintf("->status(%s,%s,s) = %s", $r,$c,$state, ));

			$causa = $class->causa($state);
			is( $causa, $r, sprintf("->causa(%s) = %s", $state, $causa ) );
		}
	}

	INTERNAL: foreach my $c ( keys(%$InternalCode) )
	{
		$klass = substr($c,0,1);
		foreach my $r ( keys(%{$InternalCode->{$c}}) )
		{
			$state = $class->status($r,$klass,'i');
			is( $state, $InternalCode->{$c}->{$r}->[0], sprintf("->status(%s,%s,i) = %s", $r,$c,$state, ));

			$causa = $class->causa($state);
			is( $causa, $r, sprintf("->causa(%s) = %s", $state, $causa ) );
		}
	}

	IRREGULAR: foreach my $e ( 0, 1, ' ', {}, [], undef() )
	{
		$state = $class->status($e);
		is( $state, q(), sprintf("->status(%s) = ''", defined($e) ? $e : 'undef') );

		$state = $class->status($e);
		is( $state, q(), sprintf("->status(%s) = ''", defined($e) ? $e : 'undef' ) );

		$causa = $class->causa($e);
		is( $causa, q(), sprintf("->causa(%s) = ''", defined($e) ? $e : 'undef' ) );
	}
}

__END__
