# $Id: Smartphone.pm,v 1.8 2010/06/16 08:15:34 ak Exp $
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

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Smart phone domains in Japan
sub nominisexemplaria
{
	my $class = shift();
	return {
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
}

sub classisnomina
{
	my $class = shift();
	return {
		'willcom'	=> 'Generic',
		'emobile'	=> 'Generic',
		'softbank'	=> 'Generic',
		'nttdocomo'	=> 'Generic',
	};
}

1;
__END__
