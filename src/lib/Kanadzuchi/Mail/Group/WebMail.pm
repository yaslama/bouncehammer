# $Id: WebMail.pm,v 1.4 2010/02/24 00:12:44 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::WebMail;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::Mail::Group';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains(World wide)
#  * http://en.wikipedia.org/wiki/Webmail
#  * http://en.wikipedia.org/wiki/Comparison_of_webmail_providers
my $domains = {
	'aol' => [
		qr{(?>\A(?:aol|aim)[.]com\z)},		# AOL; America OnLine
		qr{(?>\Aaol[.](?:de|fr|in|jp|nl|se)\z)},
		qr{(?>\Aaol[.](?:co[.]uk|com[.]br)\z)},
		qr{(?>\Anetscape[.]net\z)},
	],
	'microsoft' => [
		qr{(?>\Amsn[.]com\z)},			# Windows Live Hotmail http://www.hotmail.com/
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
		# http://promo.mail.yahoo.co.jp/collabo/
		qr{(?>\Ayahoo[.]com\z)},
		qr{(?>\Ayahoo[.]com[.](?:ar|au|br|cn|hk|kr|my|mx|no|ph|ru|sg|es|se|tw)\z)},
		qr{(?>\Ayahoo[.](?:at|ba|ca|de|dk|es|fr|gr|ie|it|kr|ru|se|tw)\z)},
		qr{(?>\Ayahoo[.]co[.](?:in|jp|kr|ru|th|tw|uk)\z)},
		qr{(?>\A(?:ymail|rocketmail)[.]com\z)},					# From 2008/06/19
		qr{(?>\Ailove-(?:mickey|minnie|pooh|stitch|tinkerbell)[.]jp\z)},	# From 2009/12/01
		qr{(?>\Agamba[-]fan[.]jp\z)},
		qr{(?>\Ahawks[-]fan[.]jp\z)},
		qr{(?>\Ay[-]fmarinos[.]com\z)},						# From 2010/02/17
	],
	'runet' => [
		qr{(?>\A(?:mail|bk|inbox|list)[.]ru\z)},# mobileme, http://mail.ru/
	],
	'apple' => [
		qr{(?>\A(?:mac|me)[.]com\z)},		# mobileme, http://me.com/
	],
	'google' => [
		qr{(?>\Agmail[.]com\z)},		# GMail http://mail.google.com/mail/
		qr{(?>\Agooglemail[.]com\z)},		# GMail in U.K. and Germany
		#qr{(?>\Aauone[.]jp\z)},		# KDDI auone, Gmail
		#qr{(?>\Alivedoor[.]com\z)},		# livedoor mail http://mail.livedoor.com/, Gmail
	],
	'nokia' => [
		qr{(?>\Aovi[.]com\z)},			# Ovi by Nokia, http://www.ovi.com/
	],
};

my $classes = {
	'aol' => 'Generic',
	'microsoft' => 'Generic',
	'yahoo' => 'Generic',
	'runet' => 'Generic',
	'apple' => 'Generic',
	'google' => 'Generic',
	'nokia' => 'Generic',
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub detectus
{
	# +-+-+-+-+-+-+-+-+
	# |d|e|t|e|c|t|u|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };

	foreach my $d ( keys(%$domains) )
	{
		if( grep { $dpart =~ $_ } @{$domains->{$d}} )
		{
			$mdata->{'class'} = $Kanadzuchi::Mail::Group::ClassName.q{::}.$classes->{$d};
			$mdata->{'group'} = 'webmail';
			$mdata->{'provider'} = $d;
			last();
		}
	}

	return($mdata);
}

sub is_webmail
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|w|e|b|m|a|i|l|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether addr is webmail or not
	# @Param	<None>
	# @Return	(Integer) 1 = is webmail
	#		(Integer) 0 = is not webmail
	my $class = shift();
	my $dpart = shift() || return(0);

	foreach my $d ( keys(%$domains) )
	{
		return(1) if( grep { $dpart =~ $_ } @{$domains->{$d}} );
	}
	return(0);
}

1;
__END__
