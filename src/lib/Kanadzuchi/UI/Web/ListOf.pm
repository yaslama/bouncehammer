# $Id: ListOf.pm,v 1.1 2010/07/11 06:48:03 ak Exp $
# -Id: Summary.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Summary.pm,v 1.1 2009/08/18 02:37:53 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                        
 ##      ##           ##      ####    ###               
 ##           ##### ######   ##  ##  ##                 
 ##     ###  ##       ##     ##  ## #####               
 ##      ##   ####    ##     ##  ##  ##                 
 ##      ##      ##   ##     ##  ##  ##   ##  ##  ##    
 ###### #### #####     ###    ####   ##   ##  ##  ##    
package Kanadzuchi::UI::Web::ListOf;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Path::Class::File;
use Time::Piece;
use Kanadzuchi::Metadata;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub listofcontents
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |l|i|s|t|o|f|c|o|n|t|e|n|t|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	List of contents which are defined at the file
	my $self = shift();

	my $listname = $self->param('pi_list') || return $self->exception('E');
	my $listtmpl = lc($listname).'.html';
	my $listmaps = { 'neighbors' => 'nd', 'countries' => 'cc' };
	my $listpath = $self->param( $listmaps->{ lc $listname } );
	my $issample = 0;

	unless( -f $listpath )
	{
		$listpath .= '-example';
		$issample  = 1;
	}
	$self->e('E') unless ( -f $listpath );

	my $lfobject = new Path::Class::File( $listpath );
	my $listtime = Time::Piece->new( $lfobject->stat->[9] );
	my $listdata = shift @{ Kanadzuchi::Metadata->to_object($listpath) };

	if( $listname eq 'countries' )
	{
		require Kanadzuchi::ISO3166;
		my $iso3166c = Kanadzuchi::ISO3166->assignedcode();
		map { $listdata->{$_}->{'name'} = $iso3166c->{$_}->{'shortname'} } keys %$listdata;
		map { $listdata->{$_}->{'code'} = uc $_ } keys %$listdata;

		require JSON::Syck;
		$JSON::Syck::ImplicitTyping  = 1;
		$JSON::Syck::Headless        = 1;
		$JSON::Syck::ImplicitUnicode = 0;
		$JSON::Syck::SingleQuote     = 0;
		$JSON::Syck::SortKeys        = 0;

		foreach my $code ( keys %$listdata )
		{
			foreach my $hgrp ( 'Cellphone', 'Smartphone', 'WebMail' )
			{
				my $classname =  q|Kanadzuchi::Mail::Group::|.uc($code).'::'.$hgrp;
				my $classpath =  $classname; $classpath =~ y{:}{/}s; $classpath .= '.pm';

				eval { require $classpath; };
				next () if $@;
				$listdata->{$code}->{'class'}->{lc $hgrp} = $classname;
				$listdata->{$code}->{'provider'}->{lc $hgrp} = $classname->nominisexemplaria();
			}
		}
	}

	$self->tt_params(
		'issample' => $issample,
		'listname' => $listname,
		'listfile' => $lfobject->basename(),
		'listpath' => $listpath,
		'listdata' => $listdata,
		'listtime' => $listtime->ymd('/').' '.$listtime->hms(':'),
	);

	return $self->tt_process($listtmpl);
}

1;
__END__
