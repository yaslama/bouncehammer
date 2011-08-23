# $Id: Template.pm,v 1.1.2.1 2011/08/23 23:09:21 ak Exp $
# Copyright (C) 2010-2011 Cubicroot Co. Ltd.
# Kanadzuchi::MTA::User
                                                      
 ######                      ###          ##          
   ##     ####  ##  ## #####  ##   #### ###### ####   
   ##    ##  ## ###### ##  ## ##      ##  ##  ##  ##  
   ##    ###### ###### ##  ## ##   #####  ##  ######  
   ##    ##     ##  ## #####  ##  ##  ##  ##  ##      
   ##     ####  ##  ## ##    ####  #####   ### ####   
                       ##                             
# Template for user-defined MTA module
package Kanadzuchi::MTA::User::Template;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub version { return '0.0.0'; }
sub description { return q(); }
sub emailheaders { return []; }
sub reperit { return q(); }

1;
__END__
