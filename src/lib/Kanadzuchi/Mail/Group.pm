# $Id: Group.pm,v 1.23 2010/06/17 12:00:26 ak Exp $
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
sub communisexemplar {}
sub nominisexemplaria {}
sub classisnomina {}
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
	my $areakeylist = [ qw(AU BR CA CN CZ DE EG IN JP KR LV NO NZ RU SG TW UK US ZA) ];
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

sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };
	my $commx = $class->communisexemplar() || undef();
	my $regex = $class->nominisexemplaria();
	my $klass = $class->classisnomina();
	my $group = lc $class;
	my $cpath = q();

	return($mdata) if( $commx && $dpart !~ $commx );
	$group =~ s{(?>\A.+::)}{};

	foreach my $d ( keys(%$regex) )
	{
		next() unless( grep { $dpart =~ $_ } @{ $regex->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::|.$klass->{$d};
		$mdata->{'group'} = $group;
		$mdata->{'provider'} = $d;

		unless( $klass->{$d} eq q|Generic| )
		{
			$cpath =  $mdata->{'class'};
			$cpath =~ y{:}{/}s;
			$cpath .= '.pm';

			require $cpath;
		}
		last();
	}

	return($mdata);
}

'EXPERIMENTAL IMPLEMENTATION';
__END__
