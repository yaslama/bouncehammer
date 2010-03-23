#__PERLEXECUTABLE__
# $Id: bouncehammer.PL,v 1.3 2010/03/23 06:38:23 ak Exp $
# -Id: bouncehammer.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: bouncehammer.cgi,v 1.2 2009/10/05 08:56:49 ak Exp -
# -Id: bouncehammer.PL,v 1.1 2009/08/27 05:10:08 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
package Kanadzuchi::UI::Web::CGI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use Kanadzuchi::UI::Web::Dispatch;
Kanadzuchi::UI::Web::Dispatch->dispatch();

__END__
