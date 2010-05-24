# $Id: WebMail.pm,v 1.1 2010/05/24 16:55:12 ak Exp $
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
package Kanadzuchi::Mail::Group::JP::WebMail;

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
# Major company's Webmail domains(Japan)
my $domains = {
	'goo' => [
		# goo mail, http://mail.goo.ne.jp/goomail/index.ghtml
		qr{(?>\Amail[.]goo[.]ne[.]jp\z)},
		qr{(?>\Agoo[.]jp\z)},
	],
	'nttdocomo' => [
		# DoCoMo web mail powered by goo; http://dwmail.jp/
		qr{(?>\Adwmail[.]jp\z)},
	],
	'aubykddi' => [
		# KDDI auone(Gmail); http://auone.jp/
		qr{(?>\Aauone[.]jp\z)},
	],
	'livedoor' => [
		# livedoor mail(Gmail) http://mail.livedoor.com/
		qr{(?>\Alivedoor[.]com\z)},
	],
};

my $classes = {
	'goo' => 'Generic',
	'nttdocomo' => 'Generic',
	'aubykddi' => 'Generic',
	'livedoor' => 'Generic',
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
			require $Kanadzuchi::Mail::Group::ClassPath.'/'.$classes->{$d}.'.pm';
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
