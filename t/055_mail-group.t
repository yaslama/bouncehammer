# $Id: 055_mail-group.t,v 1.1 2010/05/25 23:54:00 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 74 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $BaseGrp = q|Kanadzuchi::Mail::Group|;
my $Classes = {
        'neighbor'	=> q|Kanadzuchi::Mail::Group::Neighbor|,
        'webmail'	=> q|Kanadzuchi::Mail::Group::WebMail|,
        'jpcellphone'	=> q|Kanadzuchi::Mail::Group::JP::Cellphone|,
        'jpsmartphone'	=> q|Kanadzuchi::Mail::Group::JP::Smartphone|,
        'jpwebmail'	=> q|Kanadzuchi::Mail::Group::JP::WebMail|,
};

my $Domains = {
        'neighbor'	=> [],
        'webmail'	=> [ qw( aol.com gmail.com yahoo.com hotmail.com mail.ru me.com ovi.com ) ],
        'jpcellphone'	=> [ qw( docomo.ne.jp ezweb.ne.jp softbank.ne.jp ) ],
        'jpsmartphone'	=> [ qw( i.softbank.jp docomo.blackberry.com emnet.ne.jp willcom.com ) ],
        'jpwebmail'	=> [ qw( auone.jp dwmail.jp ) ],
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
REQUIRE: foreach my $c ( keys(%$Classes) ){ require_ok("$Classes->{$c}"); }
METHODS: foreach my $c ( keys(%$Classes) ){ can_ok( $Classes->{$c}, 'detectus' ); }

# 3. Call class method
CLASS_METHODS: foreach my $c ( keys(%$Domains) )
{
	my $detected = {};
	MATCH: foreach my $s ( @{$Domains->{$c}} )
	{
		$detected = $Classes->{ $c }->detectus($s);
		isa_ok( $detected, q|HASH|, '->detecuts' );
		ok( $detected->{'class'}, '->class = '.$detected->{'class'} );
		ok( $detected->{'group'}, '->group = '.$detected->{'group'} );
		ok( $detected->{'provider'}, '->provider = '.$detected->{'provider'} );
	}
}

__END__
