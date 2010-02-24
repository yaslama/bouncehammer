# $Id: 061_mail-stored-yaml.t,v 1.3 2010/02/19 14:32:59 ak Exp $
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
use Kanadzuchi::Mail::Stored::YAML;
use JSON::Syck;
use Test::More ( tests => 44 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Y = <DATA>;
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mail::Stored::YAML|,
	'methods' => [ @{$Kanadzuchi::Test::Mail::MethodList->{'BaseClass'}},
		@{$Kanadzuchi::Test::Mail::MethodList->{'Stored::YAML'}}, ],
	'instance' => undef(),
);

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	my $json = shift @{ JSON::Syck::Load($Y) };
	my $destinationd = q();
	my $senderdomain = q();

	isa_ok( $json, q|HASH|, q{Loaded data is HASH} );

	( $destinationd = $json->{'recipient'} ) =~ s{\A.+[@]}{}g;
	( $senderdomain = $json->{'addresser'} ) =~ s{\A.+[@]}{}g;

	$T->instance(
		new Kanadzuchi::Mail::Stored::YAML(
			'bounced' => $json->{'bounced'},
			'addresser' => ucfirst($json->{'addresser'}),
			'recipient' => ucfirst($json->{'recipient'}),
			'token' => $json->{'token'},
			'hostgroup' => $json->{'hostgroup'},
			'provider' => $json->{'provider'},
			'description' => $json->{'description'},
			'reason' => $json->{'reason'},
		)
	);

	isa_ok( $T->instance(), $T->class() );
	can_ok( $T->class(), @{$T->methods()} );
}

CHECK_VALUES: {
	my $object = $T->instance();
	my $descrs = {};
	my $sender = q();
	my $destnd = q();

	isa_ok( $object->addresser(), q|Kanadzuchi::Address|, q{->addresser() == Kanadzuchi::Address} );
	isa_ok( $object->recipient(), q|Kanadzuchi::Address|, q{->recipient() == Kanadzuchi::Address} );
	isa_ok( $object->bounced(), q|Time::Piece|, q{->bounced() == Time::Piece} );
	isa_ok( $object->description(), q|HASH|, q{->description() == HASH} );

	$sender = $object->addresser->host();
	$destnd = $object->recipient->host();
	$descrs = $object->description();

	is( $object->bounced->epoch(), 166222661, q{Epoch of the date} );
	is( $object->bounced->year(), 1975, q{Year of the date} );
	is( $object->bounced->month(), q(Apr), q{Month name of the date} );

	$object->timezoneoffset($descrs->{'timezoneoffset'});
	$object->diagnosticcode($descrs->{'diagnosticcode'});

	is( $object->senderdomain(), $sender, q{Sender domain = }.$sender );
	is( $object->destination(), $destnd, q{Destination host = }.$destnd );
	is( $object->timezoneoffset(), q{+0900}, q{Timezone = +0900} );
	is( $object->diagnosticcode(), q{Test record}, q{Diagnostic code = }.$descrs->{'diagnosticcode'});
}

LOAD_AND_NEW: {
	my $object = undef();
	my $entity = undef();
	my $reqobj = 0;
	my $jsoned = shift @{ JSON::Syck::Load($Y) };
	my $member = [ 'addresser', 'recipient', 'senderdomain', 'destination', 'reason',
			'hostgroup', 'provider', 'token', ];
	my $descrp = [ 'deliverystatus', 'diagnosticcode', 'timezoneoffset' ];

	REQUIRE_HASHREF: {

		$reqobj = 0;
		$T->instance( $T->class->loadandnew( $Y, $reqobj ) );
		$object = $T->instance();
		$entity = $object->[0];

		isa_ok( $object, q|ARRAY| );
		isa_ok( $entity, q|HASH| );
		isa_ok( $entity->{'description'}, q|HASH|, q{->description() is HASH} );

		foreach my $_m ( @$member )
		{
			is( $entity->{$_m}, $jsoned->{$_m}, qq|->$_m == $jsoned->{$_m}| );
		}

		foreach my $_d ( @$descrp )
		{
			is( $entity->{$_d}, $jsoned->{'description'}->{$_d}, qq|->$_d == $jsoned->{'description'}->${_d}| );
		}
	}

	REQUIRE_OBJECT: {

		$reqobj = 1;
		$T->instance( $T->class->loadandnew( $Y, $reqobj ) );

		$object = $T->instance();
		$entity = $object->[0];

		isa_ok( $object, q|ARRAY| );
		isa_ok( $entity, q|HASH| );
		isa_ok( $entity, $T->class() );
		isa_ok( $entity->addresser(), q|Kanadzuchi::Address| );
		isa_ok( $entity->recipient(), q|Kanadzuchi::Address| );
		isa_ok( $entity->bounced(), q|Time::Piece| );
		isa_ok( $entity->description(), q|HASH| );

		is( $entity->addresser->address(), $jsoned->{'addresser'}, q{->addresser->address == }.$jsoned->{'addresser'} );
		is( $entity->recipient->address(), $jsoned->{'recipient'}, q{->recipient->address == }.$jsoned->{'recipient'} );

		is( $entity->addresser->host(), $entity->senderdomain, q{->addresser->host == senderdomain} );
		is( $entity->recipient->host(), $entity->destination, q{->recipient->host == destination} );

		is( $entity->senderdomain(), $jsoned->{'senderdomain'}, q{->senderdomain == }.$jsoned->{'senderdomain'} );
		is( $entity->destination(), $jsoned->{'destination'}, q{->destination == }.$jsoned->{'destination'} );

		is( $entity->deliverystatus(), 534, $T->class.q{->loadandnew()->deliverystatus() } );
		is( $entity->diagnosticcode(), q(Test record), $T->class.q{->loadandnew()->diagnosticcode() } );
		is( $entity->timezoneoffset(), q(+0900), $T->class.q{->loadandnew()->timezoneoffset() } );
	}
}

__DATA__
- { "bounced": 166222661, "addresser": "postmaster@example.jp", "recipient": "very-very-big-message-to-you@gmail.com", "senderdomain": "example.jp", "destination": "gmail.com", "reason": "mesgtoobig", "hostgroup": "webmail", "provider": "google", "description": { "deliverystatus": 534, "timezoneoffset": "+0900", "diagnosticcode": "Test record" }, "token": "aeaaeb939a918caaef3be00f19b66506" }
