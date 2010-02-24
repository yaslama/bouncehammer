# $Id: Addressers.pm,v 1.3 2010/02/21 20:42:00 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Schema::
                                                                        
   ##       ##     ##                                                   
  ####      ##     ##  #####   ####   ##### #####  ####  #####   #####  
 ##  ##  #####  #####  ##  ## ##  ## ##    ##     ##  ## ##  ## ##      
 ###### ##  ## ##  ##  ##     ######  ####  ####  ###### ##      ####   
 ##  ## ##  ## ##  ##  ##     ##         ##    ## ##     ##         ##  
 ##  ##  #####  #####  ##      ####  ##### #####   ####  ##     #####   
package Kanadzuchi::RDB::Schema::Addressers;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'DBIx::Class';

# O/R Mapper of t_senderdomains table and relations
__PACKAGE__->load_components('Core');
__PACKAGE__->table('t_addressers');
__PACKAGE__->add_columns('id', 'email', 'description', 'disable');
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many( 'addressers' => 'Kanadzuchi::RDB::Schema::BounceLogs','addresser' );

1;
__END__
