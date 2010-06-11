# $Id: Stored.pm,v 1.7 2010/06/10 10:28:44 ak Exp $
# -Id: Returned.pm,v 1.10 2010/02/17 15:32:18 ak Exp -
# -Id: Returned.pm,v 1.2 2009/08/29 19:01:18 ak Exp -
# -Id: Returned.pm,v 1.15 2009/08/21 02:44:15 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::
                                         
  ##### ##                           ##  
 ###  ###### ####  #####   ####      ##  
  ###   ##  ##  ## ##  ## ##  ##  #####  
   ###  ##  ##  ## ##     ###### ##  ##  
    ### ##  ##  ## ##     ##     ##  ##  
 #####   ### ####  ##      ####   #####  
package Kanadzuchi::Mail::Stored;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail';
use strict;
use warnings;
use Kanadzuchi::Iterator;
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'id',			# (Integer) Record ID
	'updated',		# (Time::Piece) Updated date
	'disabled',		# (Boolean) Disable flag
);

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub damn
{
	#+-+-+-+-+
	#|d|a|m|n|
	#+-+-+-+-+
	#
	# @Description	Damn, Object to hash reference
	# @Param	<None>
	# @Return	(Ref->Hash)
	my $self = shift();
	my $damn = $self->SUPER::damn();

	map { $damn->{$_} = $self->{$_} if( exists($self->{$_}) ) } ( 'id', 'disabled' );
	map { $damn->{$_} = $self->{$_}->epoch() if( ref($self->{$_}) eq q|Time::Piece| ) } ( 'updated' );
	return($damn);
}

sub insert
{
	# +-+-+-+-+-+-+
	# |i|n|s|e|r|t|
	# +-+-+-+-+-+-+
	#
	# @Description	 INSERT INTO
	# @Param <obj>	 (K::BdDR::BounceLogs::Table) TxnTable object
	# @Param <ref>	 (Ref->Hash) Kanadzuchi::BdDR::BounceLogs::Masters::Table(s)
	# @Param <obj>	 (K::BdDR::Cache) Cache object
	# @Return	 (Integer) n = The ID of created object
	#		 (Integer) 0 = Failed to INSERT
	my $self = shift();
	my $xtable = shift() || return(0);
	my $mtable = shift() || return(0);
	my $tcache = shift() || undef();

	my $mtcols = $xtable->fields->{'join'};
	my $mcache = {};	# Cached data for mastertable
	my $xcache = {};	# Cached data for transaction table
	my $nudata = 0;		# The ID of Inserted record
	my $tcdata = q();	# Temporary cache data
	my $xalias = lc($xtable->alias());
	my $malias = q();

	# Get the value of transaction table from cache
	if( $tcache )
	{
		# Old data will not be inserted
		$xcache = $tcache->getit( $xalias, $self->{'token'} );
		return( $xcache->{'id'} ) if( $xcache->{'id'} );

		# Get the value of each mastertable from cache
		GETIT_FROM_CACHE: foreach my $_mt ( @$mtcols )
		{
			$malias = lc($mtable->{$_mt.'s'}->alias());
			$tcdata = $_mt eq 'addresser' ? $self->{$_mt}->address() : $self->{$_mt};
			$mcache->{$_mt} = $tcache->getit( $malias, $tcdata );
		}
	}

	# Set the value of each mastertable into cache
	SETIT_INTO_CACHE: foreach my $_mt ( @$mtcols )
	{
		unless( $mcache->{$_mt} )
		{
			$malias = lc($mtable->{$_mt.'s'}->alias());
			$tcdata = $_mt eq 'addresser' ? $self->{$_mt}->address() : $self->{$_mt};
			$mcache->{$_mt} = $mtable->{$malias}->getidbyname( $tcdata );

			unless( $mcache->{$_mt} )
			{
				# Do not INSERT 'senderdomain' automatically.
				next() if( $_mt eq 'senderdomain' );
				$mcache->{$_mt} = $mtable->{$malias}->insert( { 'name' => $tcdata } );
			}

			next() unless( $tcache );
			$tcache->setit( $malias, $tcdata, $mcache->{$_mt} ) if( $mcache->{$_mt} );
		}
	}

	# Do not INSERT if the senderdomain does not exist in the database.
	return(0) unless($mcache->{'senderdomain'});

	$nudata = $xtable->insert( {
			'addresser'	=> $mcache->{'addresser'},
			'recipient'	=> $self->{'recipient'}->address(),
			'destination'	=> $mcache->{'destination'},
			'senderdomain'	=> $mcache->{'senderdomain'},
			'token'		=> $self->{'token'},
			'reason'	=> $self->{'reason'},
			'hostgroup'	=> $self->{'hostgroup'},
			'provider'	=> $mcache->{'provider'},
			'bounced'	=> $self->{'bounced'},
			'updated'	=> new Time::Piece(),
			'description'	=> ${ Kanadzuchi::Metadata->to_string($self->{'description'}) },
		} );

	return(0) if( $nudata == 0 );
	return($nudata) unless( $tcache );

	# Set data into cache
	$xcache = { 'id' => $nudata, 'bounced' => $self->{'bounced'}->epoch(),
			'frequency' => 1, 'reason' => $self->{'reason'},
			'hostgroup' => $self->{'hostgroup'} };
	$tcache->setit( $xalias, $self->{'token'}, $xcache );
	return($nudata);
}

sub update
{
	# +-+-+-+-+-+-+
	# |u|p|d|a|t|e|
	# +-+-+-+-+-+-+
	#
	# @Description	UPDATE the rocord
	# @Param <obj>	(K::BdDR::BounceLogs::Table) TxnTable object
	# @Param <obj>	(K::BdDR::Cache) Cache object
	# @Return	(Integer)  n = The ID of updated record
	#		(Integer)  0 = No data to UPDATE in the db || Failed to UPDATE
	#		(Integer) -1 = New data is too old or same
	my $self = shift();
	my $xtable = shift() || return(0);
	my $tcache = shift() || return(0);

	my $isnew1 = 0;		# (Integer) Flag, 1 = the data is newer than the DB's one
	my $xcache = {};	# (Ref->Hash) Cached data
	my $nucond = {};	# (Ref->Hash) Where condition for UPDATE
	my $nudata = {};	# (Ref->Hash) New data to UPDATE
	my $xalias = lc($xtable->alias());

	# Get the value of transaction table from cache
	$xcache = $tcache->getit( $xalias, $self->{'token'} );

	unless( $xcache->{'id'} )
	{
		# There is no data to update in the database.
		return(0) unless( $self->findbytoken($xtable,$tcache) );

		# Get the value of transaction table from cache, Again
		$xcache = $tcache->getit( $xalias, $self->{'token'} );
	}

	foreach my $_f ( 'reason', 'hostgroup' )
	{
		next() if( defined($xcache->{$_f}) && $self->{$_f} eq $xcache->{$_f} );
		$nudata->{$_f} = $self->{$_f};
	}

	$isnew1 = 1 if( $xcache->{'bounced'} < $self->{'bounced'}->epoch() );
	$nucond = { 'id' => $xcache->{'id'} };
	$nudata->{'frequency'} = \'frequency + 1' if( $isnew1 );
	$nudata->{'bounced'} = $self->{'bounced'} if( $isnew1 );
	$nudata->{'updated'} = new Time::Piece();

	return(0) if( keys(%$nudata) == 1 );			# No key except 'updated'
	return(0) unless( $xtable->update($nudata,$nucond) );	# UPDATE new data

	# Set new data into cache
	foreach my $_f ( 'reason', 'hostgroup' )
	{
		next() unless( $nudata->{$_f} );
		$xcache->{$_f} = $nudata->{$_f};
	}
	$xcache->{'frequency'}++;
	$xcache->{'bounced'} = $isnew1 ? $nudata->{'bounced'}->epoch() : $self->{'bounced'}->epoch();
	$tcache->setit( $xalias, $self->{'token'}, $xcache );
	return(1);
}

sub findbytoken
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |f|i|n|d|b|y|t|o|k|e|n|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Finds a record by message token
	# @Param <obj>	(K::BdDR::BounceLogs::Table) TxnTable object
	# @Param <obj>	(K::BdDR::Cache) Cache object
	# @Return	(Integer) 1 = Find the record
	#		(Integer) 0 = The message token not found
	my $self = shift();
	my $xtable = shift() || return(0);
	my $tcache = shift() || return(0);
	my $xcache = {};
	my $xalias = lc($xtable->alias());

	eval {
		my $therow = undef();
		my $whcond = { 'token' => $self->{'token'} };

		# Get the value of transaction table from cache
		$xcache = $tcache->getit( $xalias, $self->{'token'} );
		unless( exists($xcache->{'id'}) )
		{
			# Get the value from transaction table.
			$therow = $xtable->object->single( $xtable->table(), $whcond );

			if( $therow )
			{
				$xcache = { 
					'id' => $therow->get_column('id'),
					'reason' => $therow->reason(),
					'bounced' => $therow->bounced->epoch(),
					'frequency' => $therow->frequency(),
				};
				$tcache->setit( $xalias, $self->{'token'}, $xcache );
			}
		}
	};

	if( $@ )
	{
		$xtable->error->{'string'} = $@;
		$xtable->error->{'count'}++;
		return(0);
	}
	return(0) unless( $xcache->{'id'} );
	return(1);
}

1;
__END__
