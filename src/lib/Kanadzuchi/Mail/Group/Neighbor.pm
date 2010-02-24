# $Id: Neighbor.pm,v 1.3 2010/02/21 20:36:56 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                          
 ##  ##           ##         ##     ##                    
 ### ##   ####         ##### ##     ##      ####  #####   
 ######  ##  ##  ###  ##  ## #####  #####  ##  ## ##  ##  
 ## ###  ######   ##  ##  ## ##  ## ##  ## ##  ## ##      
 ##  ##  ##       ##   ##### ##  ## ##  ## ##  ## ##      
 ##  ##   ####   ####     ## ##  ## #####   ####  ##      
                      #####                               
package Kanadzuchi::Mail::Group::Neighbor;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::Mail::Group';
use JSON::Syck;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
$JSON::Syck::ImplicitTyping  = 1;
$JSON::Syck::Headless        = 1;
$JSON::Syck::ImplicitUnicode = 0;
$JSON::Syck::SingleQuote     = 0;
$JSON::Syck::SortKeys        = 0;

my $Neighbors = q{__KANADZUCHIROOT__/etc/neighbor-domains};
my $domains = ( -r $Neighbors && -s _ && -T _ ) ? JSON::Syck::LoadFile($Neighbors) : {};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub detectus
{
	# +-+-+-+-+-+-+-+-+
	# |d|e|t|e|c|t|u|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };

	foreach my $d ( keys(%$domains) )
	{
		if( grep { $dpart eq $_ } @{$domains->{$d}} )
		{
			$mdata->{'class'} = $Kanadzuchi::Mail::Group::ClassName.q{::Generic};
			$mdata->{'group'} = 'neighbor';
			$mdata->{'provider'} = $d;
			last();
		}
	}

	return($mdata);
}

sub is_neighbor
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|n|e|i|g|h|b|o|r|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether addr is neighbor or not
	# @Param	<None>
	# @Return	(Integer) 1 = is neighbor
	#		(Integer) 0 = is not neighbor
	my $class = shift();
	my $dpart = shift() || return(0);

	foreach my $d ( keys(%$domains) )
	{
		return(1) if( grep { $dpart eq $_ } @{$domains->{$d}} );
	}
	return(0);
}

1;
__END__
