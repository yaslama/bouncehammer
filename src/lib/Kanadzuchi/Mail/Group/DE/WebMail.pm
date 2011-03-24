# $Id: WebMail.pm,v 1.4.2.1 2011/03/24 05:40:58 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::DE::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::DE::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Germany(Bundesrepublik Deutschland)
# sub communisexemplar { return qr{[.]de\z}; }
sub nominisexemplaria
{
	my $class = shift();
	return {
		# GMX - http://www.gmx.net/
		'gmx' => [
			qr{\Agmx[.](?:at|ca|cc|ch|cn|de|es|eu|fr|hk|ie|it)\z},
			qr{\Agmx[.](?:li|lu|ph|pt|ru|se|sg|tm|tw|us)\z},
			qr{\Agmx[.](?:biz|com|info|name|net)\z},
			qr{\Agmx[.]co[.](?:in|uk)\z},
			qr{\Agmx[.]com[.](?:br|my|tr)\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'gmx'	=> 'Generic',
	};
}

1;
__END__
