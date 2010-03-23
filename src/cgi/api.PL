#__PERLEXECUTABLE__
# $Id: api.PL,v 1.4 2010/03/23 07:55:44 ak Exp $
# -Id: api.PL,v 1.5 2010/02/21 20:11:18 ak Exp -
# -Id: api.cgi,v 1.3 2009/10/06 00:36:28 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
package Kanadzuchi::API::CGI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use Kanadzuchi::API::Dispatch;
Kanadzuchi::API::Dispatch->dispatch();

__END__
