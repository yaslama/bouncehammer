# $Id: ListOf.pm,v 1.3.2.2 2011/10/09 04:53:42 ak Exp $
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
use JSON::Syck;
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
	my $listmaps = { 'neighbors' => 'nd', 'countries' => 'cc', 'mtamodules' => 'mm' };
	my $listpath = $self->param( $listmaps->{ lc $listname } );

	if( $listname eq 'mtamodules' )
	{
		# mta modules
		my $rdirectory = $listpath;
		my $modulebase = q|Kanadzuchi::MTA::|;
		my $mclassname = q();
		my $modulefile = q();
		my $modulepath = q();
		my $modulename = q();
		my $moduledata = {};
		my $mtasubdirs = [];
		my $stdmodules = [];
		my $commodules = [];
		my $usrmodules = [];
		my $commercial = [];
		my $standardmm = [];

		# Load module list
		eval {
			require $rdirectory.'/MODULES';
			$standardmm = Kanadzuchi::MTA::MODULES->standard();
			$commercial = [ map { 'Comm::'.$_ } @{ Kanadzuchi::MTA::MODULES->commercial() } ];
		};

		# Find MTA Modules
		foreach my $mtamodule ( @$standardmm, @$commercial )
		{
			my( $v, $d, $i );

			$modulename =  $mtamodule;
			$mclassname =  $modulebase.$modulename;

			$modulefile =  'lib/Kanadzuchi/MTA/'.$modulename;
			$modulefile =~ s{::}{/}g;
			$modulefile .= '.pm';

			$modulepath =  $rdirectory.'/'.$mtamodule;
			$modulepath =~ s{::}{/}g;
			$modulepath .= '.pm';

			if( -f $modulepath && -r _ && -s _ )
			{
				eval {
					require $modulepath;
					$v = $mclassname->version;
					$d = $mclassname->description;
					$i = 1;
				};
			}

			$moduledata = {
				'name' => $modulename,
				'path' => $modulefile,
				'version' => $v,
				'description' => $d,
				'installed' => $i || 0,
			};

			if( grep { $mtamodule eq $_ } @$commercial )
			{
				push( @$commodules, $moduledata );
			}
			else
			{
				push( @$stdmodules, $moduledata );
			}
		}

		# (FFR) Crawl MTA module directory to find user-defined moduels
		opendir( my $dh, $rdirectory.'/User' );
		READDIR: while( my $de = readdir($dh) )
		{
			$modulename =  $de;
			$modulename =~ s{[.]pm\z}{};

			$modulefile =  'lib/Kanadzuchi/MTA/User/'.$modulename;
			$modulefile =~ s{::}{/}g;
			$modulefile .= '.pm';

			$modulepath =  $rdirectory.'/User/'.$de;
			$mclassname =  $modulebase.$modulename;

			if( -f $modulepath && -r _ && -s _ && $modulepath =~ m{[.]pm\z} )
			{
				next(READDIR) if( grep { $modulename eq $_ } @$standardmm, @$commercial );

				eval {
					require $modulepath; 
					$moduledata = {
						'name' => $modulename,
						'path' => $modulefile,
						'version' => $mclassname->version() || 'N/A',
						'description' => $mclassname->description() || 'N/A',
						'installed' => 1,
					};
					push( @$usrmodules, $moduledata );
				};
			}
		}
		closedir($dh);

		$self->tt_params(
			'pv_listroot' => $rdirectory,
			'pv_listname' => $listname,
			'pv_listfile' => 'MTA Modules',
			'pv_listpath' => $listpath,
			'pv_liststdm' => $stdmodules,
			'pv_listcomm' => $commodules,
			'pv_listusrm' => $usrmodules,
		);
	}
	else
	{
		# neighbors, countries
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
			'pv_issample' => $issample,
			'pv_listname' => $listname,
			'pv_listfile' => $lfobject->basename(),
			'pv_listpath' => $listpath,
			'pv_listdata' => $listdata,
			'pv_listtime' => $listtime->ymd('/').' '.$listtime->hms(':'),
		);
	}

	return $self->tt_process($listtmpl);
}

1;
__END__
