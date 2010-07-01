# $Id: 055_mail-group.t,v 1.29 2010/06/25 19:27:42 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 647 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $BaseGrp = q|Kanadzuchi::Mail::Group|;
my $Classes = {
	'neighbor'	=> q|Kanadzuchi::Mail::Group::Neighbor|,
	'webmail'	=> q|Kanadzuchi::Mail::Group::WebMail|,
	'auwebmail'	=> q|Kanadzuchi::Mail::Group::AU::WebMail|,
	'brwebmail'	=> q|Kanadzuchi::Mail::Group::BR::WebMail|,
	'cawebmail'	=> q|Kanadzuchi::Mail::Group::CA::WebMail|,
	'cnwebmail'	=> q|Kanadzuchi::Mail::Group::CN::WebMail|,
	'czwebmail'	=> q|Kanadzuchi::Mail::Group::CZ::WebMail|,
	'dewebmail'	=> q|Kanadzuchi::Mail::Group::DE::WebMail|,
	'egwebmail'	=> q|Kanadzuchi::Mail::Group::EG::WebMail|,
	'inwebmail'	=> q|Kanadzuchi::Mail::Group::IN::WebMail|,
	'ilwebmail'	=> q|Kanadzuchi::Mail::Group::IL::WebMail|,
	'irwebmail'	=> q|Kanadzuchi::Mail::Group::IR::WebMail|,
	'jpcellphone'	=> q|Kanadzuchi::Mail::Group::JP::Cellphone|,
	'jpsmartphone'	=> q|Kanadzuchi::Mail::Group::JP::Smartphone|,
	'jpwebmail'	=> q|Kanadzuchi::Mail::Group::JP::WebMail|,
	'krwebmail'	=> q|Kanadzuchi::Mail::Group::KR::WebMail|,
	'lvwebmail'	=> q|Kanadzuchi::Mail::Group::LV::WebMail|,
	'nowebmail'	=> q|Kanadzuchi::Mail::Group::NO::WebMail|,
	'nzwebmail'	=> q|Kanadzuchi::Mail::Group::NZ::WebMail|,
	'ruwebmail'	=> q|Kanadzuchi::Mail::Group::RU::WebMail|,
	'sgwebmail'	=> q|Kanadzuchi::Mail::Group::SG::WebMail|,
	'twwebmail'	=> q|Kanadzuchi::Mail::Group::TW::WebMail|,
	'uksmartphone'	=> q|Kanadzuchi::Mail::Group::UK::Smartphone|,
	'ukwebmail'	=> q|Kanadzuchi::Mail::Group::UK::WebMail|,
	'uswebmail'	=> q|Kanadzuchi::Mail::Group::US::WebMail|,
	'zawebmail'	=> q|Kanadzuchi::Mail::Group::ZA::WebMail|,
};

my $Domains = {
	'neighbor'	=> [],
	'webmail'	=> [ qw(aol.com aol.jp gmail.com googlemail.com yahoo.com yahoo.co.jp 
				hotmail.com windowslive.com mac.com me.com ovi.com excite.com
				lycos.com lycosmail.com ) ],
	'auwebmail'	=> [ qw( fastmail.net fastmail.fm ) ],
	'brwebmail'	=> [ qw( bol.com.br ) ],
	'cawebmail'	=> [ qw( hushmail.com hush.com ) ],
	'cnwebmail'	=> [ qw( 163.com 188.com ) ],
	'czwebmail'	=> [ qw( seznam.cz email.cz ) ],
	'dewebmail'	=> [ qw( gmx.de ) ],
	'egwebmail'	=> [ qw( gawab.com giza.cc ) ],
	'inwebmail'	=> [ qw( ibibo.com ) ],
	'ilwebmail'	=> [ qw( walla.co.il ) ],
	'irwebmail'	=> [ qw( iran.ir ) ],
	'jpcellphone'	=> [ qw( docomo.ne.jp ezweb.ne.jp softbank.ne.jp d.vodafone.ne.jp jp-k.ne.jp ) ],
	'jpsmartphone'	=> [ qw( i.softbank.jp docomo.blackberry.com emnet.ne.jp willcom.com ) ],
	'jpwebmail'	=> [ qw( auone.jp dwmail.jp mail.goo.ne.jp goo.jp infoseek.jp livedoor.com
				 nifty.com nifmail.jp kitty.jp x-o.jp ) ],
	'krwebmail'	=> [ qw( hanmail.net empas.com ) ],
	'lvwebmail'	=> [ qw( inbox.lv ) ],
	'nowebmail'	=> [ qw( runbox.com ) ],
	'nzwebmail'	=> [ qw( coolkiwi.com ) ],
	'ruwebmail'	=> [ qw( mail.ru yandex.ru ) ],
	'sgwebmail'	=> [ qw( insing.com ) ],
	'twwebmail'	=> [ qw( seed.net.tw mars.seed.net.tw ) ],
	'uksmartphone'	=> [ qw( o2.co.uk ) ],
	'ukwebmail'	=> [ qw( gmx.co.uk postmaster.co.uk yipple.com ) ],
	'uswebmail'	=> [ qw( bluetie.com lavabit.com luxsci.com inbox.com mail.com usa.com 
				pobox.com onepost.net ) ],
	'zawebmail'	=> [ qw( webmail.co.za ) ],
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#

REQUIRE: {
	use_ok($BaseGrp);
	foreach my $c ( keys(%$Classes) ){ require_ok("$Classes->{$c}") }
}

METHODS: {
	can_ok($BaseGrp, qw(reperit postulat communisexemplar nominisexemplaria classisnomina));
	foreach my $c ( keys(%$Classes) ){ can_ok( $Classes->{$c}, 'reperit' ) } 

	LEGERE: {
		my $loadedgr = $BaseGrp->postulat();

		isa_ok( $loadedgr, q|ARRAY| );
		foreach my $g ( @$loadedgr )
		{
			ok( (grep { $g eq $_ } values(%$Classes)), $g );
		}
	}
}

# 3. Call class method
CLASS_METHODS: foreach my $c ( keys(%$Domains) )
{
	my $detected = {};
	my $thegroup = q();
	MATCH: foreach my $s ( @{$Domains->{$c}} )
	{
		$detected = $Classes->{ $c }->reperit($s);
		$thegroup = lc $Classes->{ $c };
		$thegroup =~ s{\A.+::}{};

		isa_ok( $detected, q|HASH|, '->reperit('.$s.')' );
		ok( $detected->{'class'}, '->reperit('.$s.')->class = '.$detected->{'class'} );
		is( $detected->{'group'}, $thegroup, '->reperit('.$s.')->group = '.$detected->{'group'} );
		ok( $detected->{'provider'}, '->reperit('.$s.')->provider = '.$detected->{'provider'} );
	}

	DONT_MATCH: foreach my $s ( @{$Domains->{$c}} )
	{
		$detected = $Classes->{ $c }->reperit($s.'.org');
		isa_ok( $detected, q|HASH|, '->reperit' );
		is( $detected->{'class'}, q(), '->class = ' );
		is( $detected->{'group'}, q(), '->group = ' );
		is( $detected->{'provider'}, q(), '->provider = ' );

	}
}

__END__
