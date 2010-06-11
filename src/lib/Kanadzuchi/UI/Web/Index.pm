# $Id: Index.pm,v 1.5 2010/06/10 10:28:56 ak Exp $
# -Id: Index.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Index.pm,v 1.3 2009/08/13 07:13:57 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                     
  ####             ##                
   ##   #####      ##   #### ##  ##  
   ##   ##  ##  #####  ##  ## ####   
   ##   ##  ## ##  ##  ######  ##    
   ##   ##  ## ##  ##  ##     ####   
  ####  ##  ##  #####   #### ##  ##  
package Kanadzuchi::UI::Web::Index;
use base 'Kanadzuchi::UI::Web';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub index_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|n|d|e|x|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Draw index page in HTML
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'index.'.$self->{language}.'.html';
	$self->tt_process($file);
}

1;
__END__
