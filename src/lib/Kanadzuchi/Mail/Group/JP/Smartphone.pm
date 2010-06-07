# $Id: Smartphone.pm,v 1.4 2010/06/01 05:28:00 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::JP::Smartphone;

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
# Smart phone domains
my $domains = {
	'willcom' => [
		qr{(?>\Apdx[.]ne[.]jp\z)},			# Willcom AIR-EDGE
		qr{(?>\A(?:di|dj|dk|wm)[.]pdx[.]ne[.]jp\z)},	# http://www.willcom-inc.com/ja/service/contents_service/create/center_info/index.html
		qr{(?>willcom[.]com\z)},			# Created at 2009/01/15
	],
	'emobile' => [ 
		qr{(?>\Aemnet[.]ne[.]jp\z)},			# EMOBILE EMNET
	],
	'softbank' => [ 
		qr{(?>\Ai[.]softbank[.]jp\z)},			# SoftBank|Apple iPhone
	],
	'nttdocomo' => [
		qr{(?>\Amopera[.]ne[.]jp\z)},			# mopera, http://www.mopera.net/
		qr{(?>\Amopera[.]net\z)},
		qr{(?>\Adocomo[.]blackberry[.]com\z)},		# BlackBerry by NTT DoCoMo
	],
};

my $classes = {
	'willcom'   => 'Generic',
	'emobile'   => 'Generic',
	'softbank'  => 'Generic',
	'nttdocomo' => 'Generic',
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
			$mdata->{'group'} = 'smartphone';
			$mdata->{'provider'} = $d;
			last();
		}
	}

	return($mdata);
}

sub is_smartphone
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|s|m|a|r|t|p|h|o|n|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether addr is smartphone or not
	# @Param	<None>
	# @Return	(Integer) 1 = is smartphone
	#		(Integer) 0 = is not smartphone
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
