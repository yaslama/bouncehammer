# $Id: 052_mail-bounced.t,v 1.8 2010/10/05 11:30:56 ak Exp $
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
use Kanadzuchi::Mail::Bounced;
use Kanadzuchi::Mbox;
use Kanadzuchi::RFC2822;
use Kanadzuchi::String;
use Kanadzuchi::Time;
use Path::Class::Dir;
use Test::More ( tests => 1640 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $T = new Kanadzuchi::Test(
	'class' => q|Kanadzuchi::Mail::Bounced|,
	'methods' => [ @{$Kanadzuchi::Test::Mail::MethodList->{'BaseClass'}},
		@{$Kanadzuchi::Test::Mail::MethodList->{'Bounced'}}, ],
	'instance' => new Kanadzuchi::Mail::Bounced(),
);

my $ReturnedMesg = [];
my $ZciParser = new Kanadzuchi::Mbox( 'file' => $T->example->stringify().'/17-messages.eml' );
my $nMessages = 37;

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	isa_ok( $T->instance(), $T->class() );
	isa_ok( $T->tempdir(), q|Path::Class::Dir| );
	isa_ok( $ZciParser, q|Kanadzuchi::Mbox| );
	can_ok( $T->class(), @{$T->methods()} );

	$T->tempdir()->mkpath() unless( -e $T->tempdir()->stringify() );
}

CALL_PARSER: {
	my $mesgtoken = q();
	my $addresser = q();
	my $recipient = q();
	my $damnedobj = {};

	is( $ZciParser->slurpit(), $nMessages, q|Kanadzuchi::Mbox->slurpit()| );
	is( $ZciParser->nmails(), $nMessages, q{The number of emails = }.$nMessages );
	isa_ok( $ZciParser->emails(), q|ARRAY| );
	is( $ZciParser->parseit(), $nMessages, q|Kanadzuchi::Mbox->parseit()| );
	is( $ZciParser->nmesgs(), $nMessages, q{The number of messages = }.$nMessages );
	isa_ok( $ZciParser->messages(), q|ARRAY| );

	$ReturnedMesg = $T->class->eatit( $ZciParser, { 
				'cache' => $T->tempdir()->stringify(), 
				'greed' => 1, 'verbose' => 0 } );
	isa_ok( $ReturnedMesg, q|Kanadzuchi::Iterator| );
	ok( $ReturnedMesg->count(), '->count() = '.$nMessages );

	PARSE: while( my $_p = $ReturnedMesg->next() )
	{
		isa_ok( $_p, $T->class() );

		EMAIL_ADDRESS: {
			isa_ok( $_p, $T->class );
			isa_ok( $_p->addresser(), q|Kanadzuchi::Address| );
			isa_ok( $_p->recipient(), q|Kanadzuchi::Address| );

			$addresser = $_p->addresser->address();
			$recipient = $_p->recipient->address();

			ok( Kanadzuchi::RFC2822->is_emailaddress($addresser), q{->addresser->address() is valid: }.$addresser );
			ok( Kanadzuchi::RFC2822->is_domainpart($_p->addresser->host()), q{->addresser->host is valid} );
			is( $_p->addresser->host(), $_p->senderdomain(), q{->addresser->host == senderdomain: }.$_p->senderdomain() );

			ok( Kanadzuchi::RFC2822->is_emailaddress($recipient), q{->recipient->address() is valid: }.$recipient );
			ok( Kanadzuchi::RFC2822->is_domainpart($_p->recipient->host()), q{->recipient->host() is valid} );
			is( $_p->recipient->host(), $_p->destination(), q{->recipient->host == destination: }.$_p->destination() );
		}

		MESSAGETOKEN: {
			$mesgtoken = Kanadzuchi::String->token( $addresser, $recipient );
			is( length($_p->token()), 32, q{length of token is 32} );
			is( $_p->token(), $mesgtoken, q{->token() is valid: }.$mesgtoken );
		}

		BOUNCED_DATE: {
			isa_ok( $_p->bounced(), q|Time::Piece| );
			ok( $_p->bounced->epoch(), q{->bounced->epoch() is valid: }.$_p->bounced->epoch() );
			ok( $_p->bounced->year(), q{->bounced->year() is valid: }.$_p->bounced->year() );
			ok( $_p->bounced->month(), q{->bounced->month() is valid: }.$_p->bounced->month() );
			ok( $_p->bounced->day_of_month(), q{->bounced->day_of_month() is valid: }.$_p->bounced->day_of_month() );
			ok( $_p->bounced->day(), q{->bounced->day() is valid: }.$_p->bounced->day() );

			like( $_p->bounced->hour(), qr{\A\d+\z}, q{->bounced->hour() is valid: }.$_p->bounced->hour() );
			like( $_p->bounced->minute(), qr{\A\d+\z}, q{->bounced->minute() is valid: }.$_p->bounced->minute() );
			like( $_p->bounced->second(), qr{\A\d+\z}, q{->bounced->second() is valid: }.$_p->bounced->second() );
		}

		REASON: {
			my $id = $T->class->rname2id( $_p->reason() );
			my $rn = $T->class->id2rname( $id );

			like( $rn, qr{\A\w+\z}, q{->reason() is valid: }.$rn );
			ok( $id, q{The ID of }.$rn.q{ is }.$id );
			is( $_p->reason(), $rn, q{The name of ID:}.$id.q{ is }.$rn );
		}

		HOSTGROUP: {
			my $id = $T->class->gname2id( $_p->hostgroup() );
			my $cn = $T->class->id2gname( $id );

			like( $cn, qr{\A\w+\z}, q{->hostgroup() is valid: }.$cn );
			ok( $id, q{The ID of }.$cn.q{ is }.$id );
			is( $_p->hostgroup(), $cn, q{The name of ID:}.$id.q{ is }.$cn );
		}

		PROVIDER: {
			ok( length($_p->provider()), q{->provider() is valid: }.$_p->provider() );
		}

		DESCRIPTION: {
			isa_ok( $_p->description(), q|HASH|, q{->description is HASH} );

			DELIVERY_STATUS: {

				is( $_p->deliverystatus(), $_p->description->{'deliverystatus'},
						q{->description->deliverystatus() == deliverystatus()} );

				foreach my $ds ( $_p->deliverystatus, $_p->description->{'deliverystatus'} )
				{
					like( $ds, qr{\A\d[.]\d[.]\d+\z}, q{->deliverystatus() is valid: }.$ds );
					ok( $_p->is_permerror(), q{->is_permerror(}.$ds.q{)} ) if( $ds =~ m{\A5} );
					ok( $_p->is_temperror(), q{->is_temperror(}.$ds.q{)} ) if( $ds =~ m{\A4} );
				}
			}

			DIAGNOSTIC_CODE: {

				is( $_p->description->{'diagnosticcode'}, $_p->diagnosticcode(), 
						q{->description->diagnosticcode() == diagnosticcode()} );

				foreach my $dc ( $_p->diagnosticcode(), $_p->description->{'diagnosticcode'} )
				{
					like( $dc, qr{\A.*\z}, q{->diagnosticcode() is valid: }.$dc );
				}
			}

			TIMEZONE_OFFSET: {

				is( $_p->description->{'timezoneoffset'}, $_p->timezoneoffset(),
						q{->description->timezoneoffset() == timezoneoffset()} );

				foreach my $tz ( $_p->timezoneoffset(), $_p->description->{'timezoneoffset'} )
				{
					like( $tz, qr{\A[-+]\d{4}\z}, q{->timezoneoffset() is valid: }.$tz );
					like( Kanadzuchi::Time->tz2second($tz), qr{\d+\z}, q{Kanadzuchi::Time->tz2second(}.$tz.q{)} );
				}
			}
		}

		is( $_p->frequency(), 1, q{->frequency() == 1} );

		DAMNED: {
			$damnedobj = $_p->damn();
			isa_ok( $damnedobj, q|HASH|, '->damn()' );
		}
	}
}


__END__
