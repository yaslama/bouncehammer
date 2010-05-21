#!/usr/bin/perl
# $Id: make-dummy-data.pl,v 1.1 2010/05/20 13:11:08 ak Exp $
use strict;
use warnings;
use Digest::MD5;
use Time::Piece;

my $howmanylines = shift() || 10;
my $createdcount = 0;
my $senderdomain = 'example.jp';
my $destinations = [
		{ 'domain' => 'cubicroot.jp', 'hostgroup' => 'pc', 'provider' => 'various' },
		{ 'domain' => 'bouncehammer.jp', 'hostgroup' => 'undefined', 'provider' => 'various' },
		{ 'domain' => 'example.com', 'hostgroup' => 'reserved', 'provider' => 'rfc2606' },
		{ 'domain' => 'example.ac.jp', 'hostgroup' => 'reserverd', 'provider' => 'reserved' },
		{ 'domain' => 'aol.com', 'hostgroup' => 'webmail', 'provider' => 'aol' },
		{ 'domain' => 'msn.com', 'hostgroup' => 'webmail', 'provider' => 'microsoft' },
		{ 'domain' => 'yahoo.com' ,'hostgroup' => 'webmail', 'provider' => 'yahoo' },
		{ 'domain' => 'mail.ru', 'hostgroup' => 'webmail', 'provider' => 'runet' },
		{ 'domain' => 'me.com', 'hostgroup' => 'webmail', 'provider' => 'apple' },
		{ 'domain' => 'gmail.com', 'hostgroup' => 'webmail', 'provider' => 'google' },
		{ 'domain' => 'ovi.com', 'hostgroup' => 'webmail', 'provider' => 'nokia' },
		{ 'domain' => 'docomo.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'nttdocomo' },
		{ 'domain' => 'ezweb.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'aubykddi' },
		{ 'domain' => 'softbank.ne.jp', 'hostgroup' => 'cellphone', 'provider' => 'softbank' },
		{ 'domain' => 'willcom.com', 'hostgroup' => 'smartphone', 'provider' => 'willcom' },
		{ 'domain' => 'emnet.ne.jp', 'hostgroup' => 'smartphone', 'provider' => 'emobile' },
		{ 'domain' => 'i.softbank.jp', 'hostgroup' => 'smartphone', 'provider' => 'softbank' },
		{ 'domain' => 'docomo.blackberry.com', 'hostgroup' => 'smartphone', 'provider' => 'nttdocomo' },
	];
my $reasons = [ qw(
		undefined userunknown hostunknown hasmoved filtered
		suspend mailboxfull exceedlimit systemfull notaccept
		mesgtoobig mailererror securityerr whitelisted unstable
		onhold
	) ];
my $outputformat = qq|- { "bounced": %d, "addresser": "%s", "recipient": "%s", |
			. qq|"senderdomain": "%s", "destination": "%s", "reason": "%s", |
			. qq|"hostgroup": "%s", "provider": "%s", "frequency": %d, |
			. qq|"description": { "deliverystatus": 5%d, "diagnosticcode": "Dummy Record", |
			. qq|"timezoneoffset": "+0900" }, "token": "%s" }\n|;


while( $createdcount < $howmanylines )
{
	my $bouncedat = Time::Piece->new->epoch() - int(rand(1e7));
	my $reasonwhy = $reasons->[ rand(1e2) % scalar(@$reasons) ];
	my $localpart = substr( Digest::MD5->new->add( rand(10) )->hexdigest(), 1, int(rand(24)) + 12 );

	my $randomindex = rand(1e2) % scalar(@$destinations);
	my $destination = $destinations->[ $randomindex ]->{'domain'};

	my $recipient = $localpart.'@'.$destination;
	my $addresser = 'bouncehammer@'.$senderdomain;

	my $messagetoken =  Digest::MD5::md5_hex( sprintf( "\x02%s\x1e%s\x03", lc($addresser), lc($recipient) ) );

	printf( STDOUT $outputformat, 
			$bouncedat, $addresser, $recipient, $senderdomain, $destination, $reasonwhy, 
			$destinations->[ $randomindex ]->{'hostgroup'}, $destinations->[ $randomindex ]->{'provider'},
			int(rand(1e3)), int(rand(1e2)), $messagetoken );

	$createdcount++;
}
