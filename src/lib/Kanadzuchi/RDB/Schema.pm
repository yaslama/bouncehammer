# $Id: Schema.pm,v 1.2 2010/02/21 20:41:58 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::
                                            
  #####        ##                           
 ###      #### ##      ####  ##  ##  ####   
  ###    ##    #####  ##  ## ######     ##  
   ###   ##    ##  ## ###### ######  #####  
    ###  ##    ##  ## ##     ##  ## ##  ##  
 #####    #### ##  ##  ####  ##  ##  #####  
package Kanadzuchi::RDB::Schema;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'DBIx::Class::Schema';

# Load all Kanadzuchi::RDB::Schema::* automatically
__PACKAGE__->load_classes();

1;
__END__

