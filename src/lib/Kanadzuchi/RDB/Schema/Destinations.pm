# $Id: Destinations.pm,v 1.3 2010/02/21 20:42:00 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Schema::
                                                                                     
 ####                   ##      ##                 ##      ##                        
 ## ##   ####   ##### ######        #####   #### ######         ####  #####   #####  
 ##  ## ##  ## ##       ##     ###  ##  ##     ##  ##     ###  ##  ## ##  ## ##      
 ##  ## ######  ####    ##      ##  ##  ##  #####  ##      ##  ##  ## ##  ##  ####   
 ## ##  ##         ##   ##      ##  ##  ## ##  ##  ##      ##  ##  ## ##  ##     ##  
 ####    ####  #####     ###   #### ##  ##  #####   ###   ####  ####  ##  ## #####   
package Kanadzuchi::RDB::Schema::Destinations;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'DBIx::Class';

# O/R Mapper of t_destinations table and relations
__PACKAGE__->load_components('Core');
__PACKAGE__->table('t_destinations');
__PACKAGE__->add_columns('id', 'domainname', 'description', 'disable');
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many( 'destinations' => 'Kanadzuchi::RDB::Schema::BounceLogs','destination' );

1;
__END__
