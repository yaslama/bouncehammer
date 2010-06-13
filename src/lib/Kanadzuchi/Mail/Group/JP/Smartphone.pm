# $Id: Smartphone.pm,v 1.7 2010/06/13 07:40:13 ak Exp $
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
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Smart phone domains
my $Domains = {
	'willcom' => [
		# Willcom AIR-EDGE
		# http://www.willcom-inc.com/ja/service/contents_service/create/center_info/index.html
		qr{\Apdx[.]ne[.]jp\z},
		qr{\A(?:di|dj|dk|wm)[.]pdx[.]ne[.]jp\z},
		qr{willcom[.]com\z},	# Created at 2009/01/15
	],
	'emobile' => [ 
		# EMOBILE EMNET
		qr{\Aemnet[.]ne[.]jp\z},
	],
	'softbank' => [ 
		# SoftBank|Apple iPhone
		qr{\Ai[.]softbank[.]jp\z},
	],
	'nttdocomo' => [
		# mopera, http://www.mopera.net/
		qr{\Amopera[.](?:ne[.]jp|net)\z},

		# BlackBerry by NTT DoCoMo
		qr{\Adocomo[.]blackberry[.]com\z},
	],
};

my $Classes = {
	'willcom'	=> 'Generic',
	'emobile'	=> 'Generic',
	'softbank'	=> 'Generic',
	'nttdocomo'	=> 'Generic',
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

	foreach my $d ( keys(%$Domains) )
	{
		next unless( grep { $dpart =~ $_ } @{ $Domains->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::|.$Classes->{$d};
		$mdata->{'group'} = 'smartphone';
		$mdata->{'provider'} = $d;
		last();
	}

	return($mdata);
}

1;
__END__
