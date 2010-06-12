# $Id: WebMail.pm,v 1.10 2010/06/12 13:20:27 ak Exp $
# -Id: AOL.pm,v 1.1 2009/08/29 07:33:21 ak Exp -
# -Id: Google.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# -Id: Hotmail.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# -Id: WebBased.pm,v 1.2 2009/09/03 18:45:31 ak Exp -
# -Id: Yahoo.pm,v 1.2 2009/12/01 10:33:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major webmail provider's domains in The World
#  * http://en.wikipedia.org/wiki/Webmail
#  * http://en.wikipedia.org/wiki/Comparison_of_webmail_providers
my $Domains = {
	'aol' => [
		# AOL; America OnLine
		qr{(?>\Aaim[.](?:com|net)\z},
		qr{(?>\Aaol[.](?:asia|be|ch|de|fr|in|jp|nl|se)\z)},
		qr{(?>\Aaol[.](?:co[.]uk|com[.]br)\z)},
		qr{(?>\Anetscape[.]net\z)},
	],
	'microsoft' => [
		# Windows Live Hotmail http://www.hotmail.com/
		qr{(?>\Amsn[.]com\z)},
		qr{(?>\Amsnhotmail[.]com\z)},
		qr{(?>\Awindowslive[.]com\z)},
		qr{(?>\Ahotmail[.](?:com|fr|it|de|es|jp|se)\z)},
		qr{(?>\Ahotmail[.]co[.](?:jp|uk|th)\z)},
		qr{(?>\Ahotmail[.]com[.](?:ar|tr|br)\z)},
		qr{(?>\Alive[.](?:com|at|be|ca|cl|cn|de|dk|fr|hk|ie|it|jp|nl|no|ru|se)\z)},
		qr{(?>\Alive[.]co[.](?:kr|za|uk)\z)},
		qr{(?>\Alive[.]com[.](?:ar|au|my|mx|sg)\z)},
	],
	'yahoo' => [
		# Yahoo! Mail; http://world.yahoo.com/
		qr{(?>\Ayahoo[.]com\z)},
		qr{(?>\Ayahoo[.]com[.](?:ar|au|br|cn|hk|kr|my|mx|no|ph|ru|sg|es|se|tw)\z)},
		qr{(?>\Ayahoo[.](?:at|ba|ca|de|dk|es|fr|gr|ie|it|kr|ru|se|tw)\z)},
		qr{(?>\Ayahoo[.]co[.](?:in|jp|kr|ru|th|tw|uk)\z)},
		qr{(?>\A(?:ymail|rocketmail)[.]com\z)},		# From 2008/06/19

		# http://promo.mail.yahoo.co.jp/collabo/
		# From 2009/12/01
		qr{(?>\Ailove-(?:mickey|minnie|pooh|stitch|tinkerbell)[.]jp\z)},
		qr{(?>\Agamba[-]fan[.]jp\z)},
		qr{(?>\Ahawks[-]fan[.]jp\z)},
		qr{(?>\Ay[-]fmarinos[.]com\z)},		# From 2010/02/17
	],
	'apple' => [
		# mobileme, http://me.com/
		qr{(?>\A(?:mac|me)[.]com\z)},
	],
	'google' => [
		# GMail http://mail.google.com/mail/
		qr{(?>\Agmail[.]com\z)},

		# GMail in U.K. and Germany
		qr{(?>\Agooglemail[.]com\z)},
	],
	'nokia' => [
		# Ovi by Nokia, http://www.ovi.com/
		qr{(?>\Aovi[.]com\z)},
	],
};

my $Classes = {
	'aol'		=> 'Generic',
	'microsoft'	=> 'Generic',
	'yahoo'		=> 'Yahoo',
	'runet'		=> 'Generic',
	'apple'		=> 'Generic',
	'google'	=> 'Generic',
	'nokia'		=> 'Generic',
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
	#
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

		$cpath =  $mdata->{'class'};
		$cpath =~ y{:}{/}s;
		$cpath .= '.pm';

		require $cpath;
		last();
	}

	return($mdata);
}

1;
__END__
