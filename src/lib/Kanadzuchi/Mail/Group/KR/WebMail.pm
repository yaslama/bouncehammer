# $Id: WebMail.pm,v 1.2 2010/06/16 08:15:36 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::KR::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::KR::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in South Korea
# http://japan.cnet.com/sp/column_korea/story/0,3800105540,20333168,00.htm
sub nominisexemplaria
{
	my $class = shift();
	return {
		# http://www.daum.net/
		# Lycos?
		'daum' => [
			qr{\Ahanmail[.]net\z},
		],

		# http://www.empas.com/
		'empas' => [
			qr{\A(?:nate|empas|netsgo)[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'daum'		=> 'Generic',
		'empas'		=> 'Generic',
	};
}

1;
__END__
