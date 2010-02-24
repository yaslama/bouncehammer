# $Id: BounceLogs.pm,v 1.7 2010/02/21 20:42:00 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::Schema::
                                                                     
 #####                                   ##                          
 ##  ##  ####  ##  ## #####   #### ####  ##     ####   #####  #####  
 #####  ##  ## ##  ## ##  ## ##   ##  ## ##    ##  ## ##  ## ##      
 ##  ## ##  ## ##  ## ##  ## ##   ###### ##    ##  ## ##  ##  ####   
 ##  ## ##  ## ##  ## ##  ## ##   ##     ##    ##  ##  #####     ##  
 #####   ####   ##### ##  ##  #### ####  ###### ####      ## #####   
                                                      #####          
package Kanadzuchi::RDB::Schema::BounceLogs;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'DBIx::Class';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Columns = [ 'id', 'addresser', 'recipient', 'senderdomain', 'destination',
		'token', 'frequency', 'bounced', 'updated', 'hostgroup', 
		'provider', 'reason', 'description', 'disable' ]; 

# O/R Mapper of t_bouncelogs table and relations
__PACKAGE__->load_components('Core');
__PACKAGE__->table('t_bouncelogs');
__PACKAGE__->add_columns(@$Columns);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to( 'provider' => 'Kanadzuchi::RDB::Schema::Providers' );
__PACKAGE__->belongs_to( 'addresser' => 'Kanadzuchi::RDB::Schema::Addressers' );
__PACKAGE__->belongs_to( 'senderdomain' => 'Kanadzuchi::RDB::Schema::SenderDomains' );
__PACKAGE__->belongs_to( 'destination' => 'Kanadzuchi::RDB::Schema::Destinations' );

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub is_validcolumn
{
	#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#|i|s|_|v|a|l|i|d|c|o|l|u|m|n|
	#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	The argument name is valid column name or not
	# @Param <str>	(String)
	# @Return	(Integer) 1 = includes
	# @Return	(Integer) 0 = not
	my $class = shift();
	my $field = shift() || return(0);
	return( grep( { $_ eq $field } @$Columns ) );
}

1;
__END__
