# $Id: WebMail.pm,v 1.2.2.1 2011/03/24 05:40:59 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::IN::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::IN::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in India
sub nominisexemplaria
{
	my $class = shift();
	return {
		'ibibo' => [
			# Experimental(Not tested)
			# http://www.ibibo.com/
			qr{\Aibibo[.]com\z},
		],
		'in.com' => [
			# in.com; http://mail.in.com/
			qr{\Ain[.]com\z}
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'ibibo'		=> 'Generic',
		'in.com'	=> 'Generic',
	};
}

1;
__END__
