#!/usr/local/bin/perl
# $Id: request-to-api.pl,v 1.1 2010/03/18 08:48:15 ak Exp $
use strict;
use warnings;
use LWP::UserAgent;
use JSON::Syck;
use Digest::MD5;

my $addresser = q{sender01@example.jp};
my $recipient = q{user01@example.org};
my $queryhost = q{http://apitest.bouncehammer.jp/index.cgi/query/};
my $mesgtoken = Digest::MD5::md5_hex(sprintf("\x02%s\x1e%s\x03",$addresser,$recipient));
my $useragent = new LWP::UserAgent();
my $response = $useragent->request( HTTP::Request->new( GET => $queryhost.$mesgtoken ));
my $metadata = JSON::Syck::Load($response->content()) || [];

foreach my $j ( @$metadata )
{
	printf( "%s: %s\n", $j->{recipient}, $j->{reason} );
}

