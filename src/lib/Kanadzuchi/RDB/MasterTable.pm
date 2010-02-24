# $Id: MasterTable.pm,v 1.7 2010/02/21 20:41:58 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::
                                                                           
 ##  ##                  ##              ######         ##    ###          
 ######   ####   ##### ###### ####  #####  ##     ####  ##     ##   ####   
 ######      ## ##       ##  ##  ## ##  ## ##        ## #####  ##  ##  ##  
 ##  ##   #####  ####    ##  ###### ##     ##     ##### ##  ## ##  ######  
 ##  ##  ##  ##     ##   ##  ##     ##     ##    ##  ## ##  ## ##  ##      
 ##  ##   ##### #####     ### ####  ##     ##     ##### ##### ####  ####   
package Kanadzuchi::RDB::MasterTable;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub newtable
{
	# +-+-+-+-+-+-+-+-+
	# |n|e|w|t|a|b|l|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Create new master table object
	# @Param <str>	(String) Table name
	# @Return	(Kanadzuchi::RDB::Table::*) table object
	my $class = shift();
	my $tname = lc(shift()) || return(undef());
	my $tbobj = undef();

	if( $tname eq 'addressers' || $tname eq 'a' )
	{
		require Kanadzuchi::RDB::Table::Addressers;
		$tbobj = new Kanadzuchi::RDB::Table::Addressers();
	}
	elsif( $tname eq 'senderdomains' || $tname eq 's' )
	{
		require Kanadzuchi::RDB::Table::SenderDomains;
		$tbobj = new Kanadzuchi::RDB::Table::SenderDomains();
	}
	elsif( $tname eq 'reasons' || $tname eq 'w' )
	{
		require Kanadzuchi::RDB::Table::Reasons;
		$tbobj = new Kanadzuchi::RDB::Table::Reasons();
	}
	elsif( $tname eq 'destinations' || $tname eq 'd' )
	{
		require Kanadzuchi::RDB::Table::Destinations;
		$tbobj = new Kanadzuchi::RDB::Table::Destinations();
	}
	elsif( $tname eq 'hostgroups' || $tname eq 'h' )
	{
		require Kanadzuchi::RDB::Table::HostGroups;
		$tbobj = new Kanadzuchi::RDB::Table::HostGroups();
	}
	elsif( $tname eq 'providers' || $tname eq 'p' )
	{
		require Kanadzuchi::RDB::Table::Providers;
		$tbobj = new Kanadzuchi::RDB::Table::Providers();
	}

	return($tbobj);
}

1;
__END__
