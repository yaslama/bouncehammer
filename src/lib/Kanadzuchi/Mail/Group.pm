# $Id: Group.pm,v 1.12 2010/06/14 11:23:10 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::
                                     
  ####                               
 ##  ## #####   ####  ##  ## #####   
 ##     ##  ## ##  ## ##  ## ##  ##  
 ## ### ##     ##  ## ##  ## ##  ##  
 ##  ## ##     ##  ## ##  ## #####   
  ####  ##      ####   ##### ##      
                             ##      
package Kanadzuchi::Mail::Group;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit {}
sub postult
{
	# +-+-+-+-+-+-+-+
	# |p|o|s|t|u|l|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Require Kanadzuchi::Mail::Group::???::*
	# @Param	<None>
	# @Return	(Ref->Array) Loaded class names
	my $class = shift();

	require JSON::Syck;
	$JSON::Syck::ImplicitTyping  = 1;
	$JSON::Syck::Headless        = 1;
	$JSON::Syck::ImplicitUnicode = 0;
	$JSON::Syck::SingleQuote     = 0;
	$JSON::Syck::SortKeys        = 0;

	# Experimental implementation for the future.
	my $areakeylist = [ qw(AU CA CZ DE EG JP NO RU UK US) ];
	my $groupbyarea = '__KANADZUCHIROOT__/etc/group-by-area';
	my $loadedgroup = ( -r $groupbyarea && -s _ && -T _ ) ? JSON::Syck::LoadFile($groupbyarea) : {};
	my $didfileload = keys %$loadedgroup ? 1 : 0;
	my $areaclasses = [];
	my $grclassname = q();
	my $grclasspath = q();

	foreach my $area ( @$areakeylist )
	{
		foreach my $hgrp ( 'Cellphone', 'Smartphone', 'WebMail' )
		{
			next() if( $didfileload && ! $loadedgroup->{ lc($area) }->{ lc($hgrp) } );
			$grclassname =  __PACKAGE__.'::'.$area.'::'.$hgrp;
			$grclasspath =  $grclassname;
			$grclasspath =~ y{:}{/}s;
			$grclasspath .= '.pm';

			eval { require $grclasspath; };
			push( @$areaclasses, $grclassname ) unless( $@ );
		}
	}

	return($areaclasses);
}

'EXPERIMENTAL IMPLEMENTATION';
__END__
