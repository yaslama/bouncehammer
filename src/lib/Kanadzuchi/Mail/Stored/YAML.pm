# $Id: YAML.pm,v 1.8 2010/03/04 08:32:20 ak Exp $
# -Id: Serialized.pm,v 1.8 2009/12/31 16:30:13 ak Exp -
# -Id: Serialized.pm,v 1.2 2009/10/06 09:11:18 ak Exp -
# -Id: Serialized.pm,v 1.12 2009/07/16 09:05:42 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Stored
                             
 ##  ##  ##   ##  ## ##      
 ##  ## ####  ###### ##      
  #### ##  ## ###### ##      
   ##  ###### ##  ## ##      
   ##  ##  ## ##  ## ##      
   ##  ##  ## ##  ## ######  
package Kanadzuchi::Mail::Stored::YAML;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail';
use strict;
use warnings;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# __PACKAGE__->mk_accessors();

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub loadandnew
{
	#+-+-+-+-+-+-+-+-+-+-+
	#|l|o|a|d|a|n|d|n|e|w|
	#+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	new() by serialized data
	# @Param <str>	(String) Serialized data(YAML|JSON)
	# @Param <flg>	(Integer) 1 = Create new object, 0 = is hash ref.
	# @Return	(Ref->Array) Array-ref of Hash references if <flg> = 0
	# @Return	(Ref->Array) Array-ref of K::M::S::YAML object if <flg> = 1
	my $class = shift();
	my $sdata = shift() || return([]);
	my $oflag = shift() || 0;
	my $jsonx = undef();	# JSON::Syck object(array)

	eval { $jsonx = Kanadzuchi::Metadata->to_object( $sdata ); };
	return([]) if($@);
	return([]) if( ref($jsonx) ne q|ARRAY| );

	my $arref = [];		# Array reference
	my $hashr = {};		# Hash reference for the object

	CREATE_OBJECT: foreach my $j ( @$jsonx )
	{
		$hashr = {
			'addresser'	=> $j->{'addresser'} || q(),
			'recipient'	=> $j->{'recipient'} || q(),
			'frequency'	=> $j->{'frequency'} || q(),
			'senderdomain'	=> $j->{'senderdomain'} || q(),
			'token'		=> $j->{'token'} || q(),
			'deliverystatus'=> $j->{'deliverystatus'} 
						|| $j->{'description'}->{'deliverystatus'}
						|| q(),
			'diagnosticcode'=> $j->{'description'}->{'diagnosticcode'} || q(),
			'destination'	=> $j->{'destination'} || q(),
			'description'	=> $j->{'description'} || q(),
			'timezoneoffset'=> $j->{'description'}->{'timezoneoffset'} || q(),
			'hostgroup'	=> $j->{'hostgroup'} || q(),
			'provider'	=> $j->{'provider'} || q(),
			'reason'	=> $j->{'reason'} || q(),
			'bounced'	=> $j->{'bounced'} || q(),
		};

		push( @$arref, $oflag ? __PACKAGE__->new(%$hashr) : $hashr );
	}

	return($arref);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub insert
{
	# +-+-+-+-+-+-+
	# |i|n|s|e|r|t|
	# +-+-+-+-+-+-+
	#
	# @Description	UPDATE the rocord
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) n = The ID of created object
	#		(Integer) 0 = Failed to INSERT
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();
	my $msgd = undef();

	eval{
		my $_addr = {};	# Addresser ID, eMail address
		my $_send = {};	# SenderDomain ID, Domain name(host)
		my $_dest = {};	# Destination ID, Domain name(host)
		my $_prov = {}; # Provider ID, name
		my $_hgrp = {};	# Host group ID, name
		my $_rwhy = {};	# Reason ID, why
		my $_time = {};	# Bounced and Updated time(epoch)
		my $_data = {};	# Temporary var for pre-fetching

		CACHE_SENDERDOMAIN: {
			# Senderdomain: Check and create cache
			$_send = {
				'cache' => $dobj->cache->{'SenderDomains'},
				'sock' => $dobj->handle->resultset('SenderDomains'),
				'host' => $self->{'senderdomain'},
			};
			$_send->{'id'} = $_send->{'cache'}->{ $_send->{'host'} } || 0;

			# FFR: auto insert if it does not exist
			return(0) if( $_send->{'id'} == 0 );
		}

		CACHE_ADDRESSER: {
			# Addresser: Check and create cache
			$_addr = {
				'cache' => $dobj->cache->{'Addressers'},
				'sock' => $dobj->handle->resultset('Addressers'),
				'mail' => $self->{'addresser'}->address(),
				'id' => 0,
			};
			$_data = { 'email' => $_addr->{'mail'} };

			last() if( exists( $_addr->{'cache'}->{ $_addr->{'mail'} } ) );
			$_addr->{'id'} = $_addr->{'sock'}->find_or_create( $_data )->id();
			$_addr->{'cache'}->{ $_addr->{'mail'} } = $_addr->{'id'};
		}

		CACHE_DESTINATION: {
			# Destination: Check and create cache
			$_dest = {
				'cache' => $dobj->cache->{'Destinations'},
				'sock' => $dobj->handle->resultset('Destinations'),
				'host' => $self->{'destination'},
				'id' => 0,
			};
			$_data = { 'domainname' => $_dest->{'host'} };

			last() if( exists( $_dest->{'cache'}->{ $_dest->{'host'} } ) );
			$_dest->{'id'} = $_dest->{'sock'}->find_or_create( $_data )->id();
			$_dest->{'cache'}->{ $_dest->{'host'} } = $_dest->{'id'};
		}

		CACHE_PROVIDER: {
			# Provider
			$_prov = {
				'cache' => $dobj->cache->{'Providers'},
				'sock' => $dobj->handle->resultset('Providers'),
				'name' => $self->{'provider'},
				'id' => 0,
			};
			$_data = { 'name' => $_prov->{'name'} };

			last() if( exists( $_prov->{'cache'}->{ $_prov->{'name'} } ) );
			$_prov->{'id'} = $_prov->{'sock'}->find_or_create( $_data )->id();
			$_prov->{'cache'}->{ $_prov->{'name'} } = $_prov->{'id'};
		}

		# Host group
		$_hgrp->{'name'} = $self->{'hostgroup'} || q(undefined);
		$_hgrp->{'id'} = __PACKAGE__->gname2id( $_hgrp->{'name'} );

		# Reason
		$_rwhy->{'name'} = $self->{'reason'} || q(undefined);
		$_rwhy->{'id'} = __PACKAGE__->rname2id( $_rwhy->{'name'} );

		# Date, Time
		$_time->{'bounced'} = $self->bounced->epoch();
		$_time->{'updated'} = time();

		$that = $dobj->handle->resultset('BounceLogs')->create( {
				'addresser'	=> $_addr->{'cache'}->{ $_addr->{'mail'} },
				'recipient'	=> $self->{'recipient'}->address(),
				'destination'	=> $_dest->{'cache'}->{ $_dest->{'host'} },
				'senderdomain'	=> $_send->{'cache'}->{ $_send->{'host'} },
				'token'		=> $self->{'token'},
				'reason'	=> $_rwhy->{'id'},
				'hostgroup'	=> $_hgrp->{'id'},
				'provider'	=> $_prov->{'cache'}->{ $_prov->{'name'} },
				'bounced'	=> $_time->{'bounced'},
				'updated'	=> $_time->{'updated'},
				'description'	=> ${ Kanadzuchi::Metadata->to_string($self->{'description'}) },
		} );
	};
	return(0) if( $@ || $that == 0 );

	# Make cache
	$msgd = $dobj->cache->{'MesgTokens'}->{ $self->{'token'} };
	$msgd->{'id'} = $that->id();
	$msgd->{'reason'} = __PACKAGE__->rname2id( $self->{'reason'} );
	$msgd->{'bounced'} = $self->bounced->epoch();
	return($that->id());
}

sub update
{
	# +-+-+-+-+-+-+
	# |u|p|d|a|t|e|
	# +-+-+-+-+-+-+
	#
	# @Description	 UPDATE the rocord
	# @Param <ref>	 (K::RDB) Kanadzuchi::RDB object
	# @Param <ID>	 (Integer) The ID of the record in t_bouncelogs table
	# @Return	 (Integer) n = The ID of updated object
	#		 (Integer) 0 = Failed to UPDATE
	my $self = shift();
	my $dobj = shift() || return(0);
	my $blid = shift() || return(0);
	my $that = undef();

	eval{
		my $_sock = $dobj->handle->resultset('BounceLogs');
		my $_data = {};
		my $_cond = {};
		my( $_desc, $_hgrp, $_rwhy, $_time ) = undef();

		$_time = $self->bounced->epoch();
		$_desc = ${Kanadzuchi::Metadata->to_string($self->{'description'})} || q();
		$_hgrp = __PACKAGE__->gname2id( $self->{'hostgroup'} );
		$_rwhy = __PACKAGE__->rname2id( $self->{'reason'} );

		$_cond = { 'id' => $blid, 'disabled' => 0 };
		$_data = {
			'frequency' => \'frequency + 1',
			'hostgroup' => $_hgrp,
			'reason' => $_rwhy,
			'bounced' => $_time,
			'updated' => time(),
			'description' => $_desc, };

		$that = $_sock->search( $_cond )->update( $_data );
	};
	return(0) if($@);
	return($that);
}

sub findbytoken
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |f|i|n|d|b|y|t|o|k|e|n|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Finds a record by message token
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) 1 = Find the record
	#		(Integer) 0 = The message token not found
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();
	my $msgd = $dobj->cache->{'MesgTokens'};
	my $rset = $dobj->handle->resultset('BounceLogs');

	return(0) unless(defined($self->{'token'}));
	return(1) if( exists($msgd->{ $self->{'token'} }) );

	eval{ $that = $rset->search( { 'token' => $self->{'token'}, 'disabled' => 0 } ); };
	return(0) if( $@ || $that == 0 );

	# Make cache
	$msgd->{ $self->{'token'} }->{'id'} = $that->first->id();
	$msgd->{ $self->{'token'} }->{'reason'} = $that->get_column('reason')->max();
	$msgd->{ $self->{'token'} }->{'bounced'} = $that->get_column('bounced')->max();
	return(1);
}

1;
__END__
