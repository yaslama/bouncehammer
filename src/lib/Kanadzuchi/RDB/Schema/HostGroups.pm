# $Id: HostGroups.pm,v 1.4 2010/03/04 08:33:28 ak Exp $
# -Id: Categories.pm,v 1.1 2009/08/29 08:58:48 ak Exp -
# -Id: Categories.pm,v 1.5 2009/08/27 05:09:55 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Schema::
                                                                         
 ##  ##                  ##    ####                                      
 ##  ##   ####   ##### ###### ##  ## #####   ####  ##  ## #####   #####  
 ######  ##  ## ##       ##   ##     ##  ## ##  ## ##  ## ##  ## ##      
 ##  ##  ##  ##  ####    ##   ## ### ##     ##  ## ##  ## ##  ##  ####   
 ##  ##  ##  ##     ##   ##   ##  ## ##     ##  ## ##  ## #####      ##  
 ##  ##   ####  #####     ###  ####  ##      ####   ##### ##     #####   
                                                          ##             
package Kanadzuchi::RDB::Schema::HostGroups;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'DBIx::Class';

# O/R Mapper of t_hostgroups table and relations
__PACKAGE__->load_components('Core');
__PACKAGE__->table('t_hostgroups');
__PACKAGE__->add_columns('id', 'name', 'description', 'disabled');
__PACKAGE__->set_primary_key('id');

1;
__END__
