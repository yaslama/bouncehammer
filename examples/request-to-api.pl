#!/usr/local/bin/perl
# $Id: request-to-api.pl,v 1.4 2010/07/13 09:08:31 ak Exp $
use strict;
use warnings;
use LWP::UserAgent;
use JSON::Syck;
use Digest::MD5;

# Message Token
my $addresser = 'sender01@example.jp';
my $recipient = 'user01@example.org';
my $queryhost = 'http://apitest.bouncehammer.jp/modperl/a.cgi';
my $mesgtoken = Digest::MD5::md5_hex(sprintf("\x02%s\x1e%s\x03",$addresser,$recipient));
my $useragent = new LWP::UserAgent();
my $response = $useragent->request( HTTP::Request->new( 'GET' => $queryhost.'/select/'.$mesgtoken ));
my $metadata = JSON::Syck::Load($response->content()) || [];
foreach my $j ( @$metadata )
{
	printf( "%s: %s\n", $j->{recipient}, $j->{reason} );
}

# Recipient
$response = $useragent->request( HTTP::Request->new( 
			'GET' => $queryhost.'/search/recipient/'.$recipient ));
$metadata = JSON::Syck::Load($response->content()) || [];
foreach my $j ( @$metadata )
{
	printf( "%s: %s\n", $j->{recipient}, $j->{reason} );
}
