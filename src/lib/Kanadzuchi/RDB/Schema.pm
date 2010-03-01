# $Id: Schema.pm,v 1.3 2010/03/01 23:42:04 ak Exp $
# -Id: Schema.pm,v 1.1 2009/08/29 08:58:38 ak Exp -
# -Id: Schema.pm,v 1.3 2009/05/25 09:40:07 ak Exp -
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

