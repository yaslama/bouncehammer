# $Id: 050_mail.t,v 1.8 2010/02/19 14:32:59 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::Test::Mail;
use Kanadzuchi::Mail;
use Kanadzuchi::String;
use Test::More ( tests => 726 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mail|,
	'methods' => [ @{$Kanadzuchi::Test::Mail::MethodList->{'BaseClass'}} ],
	'instance' => new Kanadzuchi::Mail(),
);

my $Suite = {
	'hostgroups' => [
		{ 'recipient' => 'POSTMASTER@localhost.localdomain', 'hostgroup' => 'local', 'provider' => 'local', },
		{ 'recipient' => 'POSTMASTER@example.jp', 'hostgroup' => 'example', 'provider' => 'example', },

		{ 'recipient' => 'POSTMASTER@ovi.com', 'hostgroup' => 'webmail', 'provider' => 'nokia', },
		{ 'recipient' => 'POSTMASTER@mail.ru', 'hostgroup' => 'webmail', 'provider' => 'runet', },
		{ 'recipient' => 'POSTMASTER@inbox.ru', 'hostgroup' => 'webmail', 'provider' => 'runet', },
		{ 'recipient' => 'POSTMASTER@mac.com', 'hostgroup' => 'webmail', 'provider' => 'apple', },
		{ 'recipient' => 'POSTMASTER@me.com', 'hostgroup' => 'webmail', 'provider' => 'apple', },

		{ 'recipient' => 'POSTMASTER@yahoo.com', 'hostgroup' => 'webmail', 'provider' => 'yahoo', },
		{ 'recipient' => 'POSTMASTER@yahoo.co.jp', 'hostgroup' => 'webmail', 'provider' => 'yahoo', },
		{ 'recipient' => 'POSTMASTER@ymail.com', 'hostgroup' => 'webmail', 'provider' => 'yahoo', },
		{ 'recipient' => 'POSTMASTER@rocketmail.com', 'hostgroup' => 'webmail', 'provider' => 'yahoo', },
		{ 'recipient' => 'POSTMASTER@ilove-pooh.jp', 'hostgroup' => 'webmail', 'provider' => 'yahoo', },

		{ 'recipient' => 'POSTMASTER@hotmail.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },
		{ 'recipient' => 'POSTMASTER@msn.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },
		{ 'recipient' => 'POSTMASTER@msnhotmail.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },
		{ 'recipient' => 'POSTMASTER@live.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },
		{ 'recipient' => 'POSTMASTER@live.jp', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },
		{ 'recipient' => 'POSTMASTER@windowslive.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft', },

		{ 'recipient' => 'POSTMASTER@aol.com', 'hostgroup' => 'webmail', 'provider' => 'aol', },
		{ 'recipient' => 'POSTMASTER@aol.jp', 'hostgroup' => 'webmail', 'provider' => 'aol', },
		{ 'recipient' => 'POSTMASTER@aol.co.uk', 'hostgroup' => 'webmail', 'provider' => 'aol', },

		{ 'recipient' => 'POSTMASTER@gmail.com', 'hostgroup' => 'webmail', 'provider' => 'google', },
		{ 'recipient' => 'POSTMASTER@googlemail.com', 'hostgroup' => 'webmail', 'provider' => 'google', },

		{ 'recipient' => 'POSTMASTER@i.softbank.jp', 'hostgroup' => 'smartphone', 'provider' => 'softbank', },
		{ 'recipient' => 'POSTMASTER@emnet.ne.jp', 'hostgroup' => 'smartphone', 'provider' => 'emobile', },
		{ 'recipient' => 'POSTMASTER@willcom.com', 'hostgroup' => 'smartphone', 'provider' => 'willcom', },
		{ 'recipient' => 'POSTMASTER@pdx.ne.jp', 'hostgroup' => 'smartphone', 'provider' => 'willcom', },
		{ 'recipient' => 'POSTMASTER@mopera.ne.jp', 'hostgroup' => 'smartphone', 'provider' => 'nttdocomo', },
		{ 'recipient' => 'POSTMASTER@docomo.blackberry.com', 'hostgroup' => 'smartphone', 'provider' => 'nttdocomo', },

		{ 'recipient' => 'POSTMASTER@docomo.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'nttdocomo', },
		{ 'recipient' => 'POSTMASTER@ezweb.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'aubykddi', },
		{ 'recipient' => 'POSTMASTER@d.vodafone.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'softbank', },
		{ 'recipient' => 'POSTMASTER@softbank.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'softbank', },
		{ 'recipient' => 'POSTMASTER@jp-d.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'softbank', },
		{ 'recipient' => 'POSTMASTER@disney.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'softbank', },
	],
};

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

	CONSTRUCTOR: {
		my $email = q(POSTMASTER@BOUNCEHAMMER.JP);
		foreach my $m ( 'addresser', 'recipient' )
		{
			my $object_x = new Kanadzuchi::Mail( $m => $email, 'bounced' => 166222661 );
			my $object_y = new Kanadzuchi::Mail( 
					$m => new Kanadzuchi::Address( 'address' => $email ), 'bounced' => 166222661 );

			foreach my $o ( $object_x, $object_y )
			{
				isa_ok( $o, $T->class() );
				isa_ok( $o->$m(), q|Kanadzuchi::Address|, q{->}.$m.q{() is Kanadzuchi::Address} );
				isa_ok( $o->bounced(), q|Time::Piece|, q{->bounced() is Time::Piece} );
				isa_ok( $o->description(), q|HASH|, q{->description() is HASH} );

				if( $m eq 'addresser' )
				{
					is( $o->addresser->address(), lc($email), q{->addresser->address() == }.$email );
					is( $o->senderdomain(), q(bouncehammer.jp), q{->senderdomain() == bouncehammer.jp} );
				}
				
				if( $m eq 'recipient' )
				{
					is( $o->recipient->address(), lc($email), q{->recipient->address() == }.$email );
					is( $o->destination(), q(bouncehammer.jp), q{->destination() == bouncehammer.jp} )
				}

				is( $o->bounced->ymd(), q(1975-04-09), q{->bounced->ymd() == 1975-04-09} );
				is( $o->bounced->hms(), q(05:57:41), q{->bounced->hms() == 05:57:41} );
				is( $o->timezoneoffset(), q(+0000), q{->timezoneoffset() == +0000} );
				is( $o->frequency(), 1, q{->frequency() == 1} );
				is( $o->reason(), q(), q{->reason() is empty} );
				is( $o->hostgroup(), q(), q{->hostgroup() is empty} );
				is( $o->diagnosticcode(), q(), q{->diagnosticcode() is empty} );
				is( $o->deliverystatus(), 0, q{->deliverystatus() == 0} );
			}
		}
	}

	ID_TO_HOSTGROUPNAME: {

		is( $T->class->id2gname(8), q{smartphone}, $T->class.q{->id2gname(smartphone)} );
		is( $T->class->id2gname(0), q{}, $T->class.q{->id2gname(0)} );
		is( $T->class->id2gname(36), q{}, $T->class.q{->id2gname(36)} );
		ok( $T->class->id2gname('@'), $T->class.q{->id2gname(@), Get key names} );

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x",ord($z)) : 'undef()';
			is( $T->class->id2gname($z), q(), $T->class.'->id2gname('.$argv.')' );
		}
	}

	HOSTGROUPNAME_TO_ID: {

		is( $T->class->gname2id(q{cellphone}), 7, $T->class.q{->gname2id(cellphone)} );
		is( $T->class->gname2id(q{null}), 0, $T->class.q{->gname2id(null)} );
		ok( $T->class->gname2id('@'), $T->class.q{->gname2id(@), Get values} );

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
			is( $T->class->gname2id($z), 0, $T->class.'->gname2id('.$argv.')' );
		}
	}

	ID_TO_REASON: {

		is( $T->class->id2rname(9), q{mailboxfull}, $T->class.q{->id2rname(9)} );
		is( $T->class->id2rname(0), q{}, $T->class.q{->id2rname(0)} );
		is( $T->class->id2rname(81), q{}, $T->class.q{->id2rname(81)} );
		ok( $T->class->id2rname('@'), $T->class.q{->id2rname(@), Get key names} );

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
			is( $T->class->id2rname($z), q(), $T->class.'->id2rname('.$argv.')' );
		}
	}

	REASON_TO_ID: {
		is( $T->class->rname2id(q{filtered}), 5, $T->class.q{->gname2id(filtered)} );
		is( $T->class->rname2id(q{null}), 0, $T->class.q{->gname2id(null)} );
		ok( $T->class->rname2id('@'), $T->class.q{->rname2id(@), Get values} );

		ZERO_VALUES: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
		{
			my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
			is( $T->class->rname2id($z), 0, $T->class.'->rname2id('.$argv.')' );
		}
	}
}

INSTANCE_METHODS: {
	my $object = undef();
	my $mtoken = q();
	my $sender = q(POSTMASTER@CUBICROOT.JP);
	my $prefix = q(.MIL);

	SUCCESS: foreach my $c ( @{$Suite->{'hostgroups'}} )
	{
		next() unless( $c->{'recipient'} );

		$mtoken = Kanadzuchi::String->token( $sender, $c->{'recipient'} );
		$object = new Kanadzuchi::Mail(
					'addresser' => $sender,
					'recipient' => $c->{'recipient'},
					'hostgroup' => $c->{'hostgroup'},
					'provider' => $c->{'provider'},
				);

		isa_ok( $object, $T->class() );
		isa_ok( $object->addresser(), q|Kanadzuchi::Address| );
		isa_ok( $object->recipient(), q|Kanadzuchi::Address| );

		is( $object->token(), $mtoken, q{->token() == }.$mtoken );
		is( $object->senderdomain(), $object->addresser->host(), q{->senderdomain() == addresser->host} );
		is( $object->destination(), $object->recipient->host(), q{->destination() == recipient->host} );
		is( $object->provider(), $c->{'provider'}, q{->provider() == }.$c->{'provider'} );
	}

	FAILURE: foreach my $c ( @{$Suite->{'hostgroups'}} )
	{
		next() unless( $c->{'recipient'} );

		$mtoken = Kanadzuchi::String->token( $sender, $c->{'recipient'}.$prefix );
		$object = new Kanadzuchi::Mail(
					'addresser' => $sender,
					'recipient' => $c->{'recipient'}.$prefix
				);
		isa_ok( $object, $T->class() );
		isa_ok( $object->addresser(), q|Kanadzuchi::Address| );
		isa_ok( $object->recipient(), q|Kanadzuchi::Address| );

		is( $object->token(), $mtoken, q{->token() == }.$mtoken );
	}

}

OTHER_PROPERTIES: {
	is( $T->instance->frequency(), 1, $T->class.q{->frequency()} );
}


__END__

