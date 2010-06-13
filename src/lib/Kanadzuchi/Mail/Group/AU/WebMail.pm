# $Id: WebMail.pm,v 1.1 2010/06/13 12:13:45 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CA::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::AU::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Australia
my $Domains = {
	# http://fastmail.fm/
	'fastmail' => [
		qr{\Afastmail[.](?:cn|com[.]au|es|fm|in|jp|net|to|us)\z},
		qr{\A(?:fastmail|fmail)[.]co[.]uk\z},
		qr{\A(?:4e|all|hail|jete|juste|own|nospam|reale|warp|yep)[.]net\z},
		qr{\A(?:150|16|50|clue|fast[-]e|myfast|mymac|theinternete|xs)mail[.]com\z},
		qr{\A(?:2|imap|internet[-]e|ssl|swift|your)[-]mail[.]com\z},
		qr{\A(?:123|elite|imap|speedy)mail[.]org\z},
		qr{\A(?:fast|internet)[-]mail[.]org\z},
		qr{\Aemail(?:cornet|engine|groups|user)[.]net\z},
		qr{\Aemail(?:engine|plus)[.]org\z},
		qr{\Asent[.](?:as|at|com)\z},
		qr{\Amail[-](?:central|page)[.]com\z},
		qr{\Amail(?:andftp|as|bolt|can|ftp|haven|ite|might|new)[.]com\z},
		qr{\Amail(?:c|force|sent|up)[.]net\z},
		qr{\Amail(?:ingaddress|works)[.]org\z},
		qr{\A(?:best|faste|h[-])mail[.]us\z},
		qr{\Ainternet(?:emails|mailing)[.]net\z},
		qr{\Areallyfast[.](?:biz|info)\z},
		qr{\A(?:eml|fastest|imap)[.]cc\z},
		qr{\A(?:fea|mm)[.]st\z},
		qr{\Afast(?:en|emailer|imap|messaging)[.]com\z},
		qr{\A(?:fmail|inout|post|pro)inbox[.]com\z},
		qr{\A(?:air|speed)post[.]net\z},
		qr{\A(?:rushpost|fmgirl|fmguy|petml|150ml|promessage|the[-]quickest)[.]com\z},
		qr{\A(?:fastmailbox|ftml|ml1|postpro|the[-]fastest|veryspeedy)[.]net\z},
		qr{\Alatterboxes[.]org\z},
		qr{\Af[-]m[.]fm\z},
		qr{\Amailservice[.]ms\z},
		qr{\Averyfast[.]biz\z},
	],
};

my $Classes = {
	'fastmail'	=> 'Generic',
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };
	my $cpath = q();

	foreach my $d ( keys(%$Domains) )
	{
		next() unless( grep { $dpart =~ $_ } @{ $Domains->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::|.$Classes->{$d};
		$mdata->{'group'} = 'webmail';
		$mdata->{'provider'} = $d;
		last();
	}

	return($mdata);
}

1;
__END__
