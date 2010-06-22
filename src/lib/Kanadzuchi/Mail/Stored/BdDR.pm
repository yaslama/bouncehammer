# $Id: BdDR.pm,v 1.6 2010/06/21 09:53:52 ak Exp $
# -Id: RDB.pm,v 1.10 2010/03/26 07:21:27 ak Exp -
# -Id: Stored.pm,v 1.5 2009/12/31 16:30:13 ak Exp -
# -Id: Stored.pm,v 1.1 2009/08/29 07:33:13 ak Exp -
# -Id: Stored.pm,v 1.14 2009/08/12 01:59:20 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Stored::
                              
 #####      ## ####   #####   
 ##  ##     ## ## ##  ##  ##  
 #####   ##### ##  ## ##  ##  
 ##  ## ##  ## ##  ## #####   
 ##  ## ##  ## ## ##  ## ##   
 #####   ##### ####   ##  ##  
package Kanadzuchi::Mail::Stored::BdDR;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail::Stored';
use strict;
use warnings;
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::BdDR::Page;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
sub searchandnew
{
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#|s|e|a|r|c|h|a|n|d|n|e|w|
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	new() by SELECT * FROM t_bouncelogs WHERE '?' = '?'
	# @Param <obj>	(DBI::db) Database handle
	# @Param <ref>	(Ref->Hash) Where condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Return	(Kanadzuchi::Iterator) K::Mail::Stored::BdDR(s)
	my $class = shift();
	my $txdbh = shift() || return( Kanadzuchi::Iterator->new([]) );
	my $wcond = shift() || {};
	my $pagin = shift() || Kanadzuchi::BdDR::Page->new();
	my $sdata = [];
	my $txtab = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $txdbh );
	my $xrecs = $txtab->search( $wcond, $pagin );

	map { push( @$sdata, __PACKAGE__->new(%$_) ) } @$xrecs;
	return( Kanadzuchi::Iterator->new($sdata) );
}

sub remove
{
	# +-+-+-+-+-+-+
	# |r|e|m|o|v|e|
	# +-+-+-+-+-+-+
	#
	# @Description	DELETE the rocord(Wrapper method of BdDR::BounceLogs->remove())
	# @Param <obj>	(K::BdDR::BounceLogs::Table) TxnTable object
	# @Param <obj>	(K::BdDR::Cache) Cache object
	# @Return	(Integer)  1 = Successfully removed
	#		(Integer)  0 = No data to DELETE in the db || Failed to DELETE
	my $self = shift();
	my $xtable = shift() || return(0);
	my $tcache = shift() || return(0);
	my $wherec = {};

	return(0) if( ! $self->{'id'} && ! $self->{'token'} );
	$wherec->{'id'} = $self->{'id'} if( $self->{'id'} );
	$wherec->{'token'} = $self->{'token'} if( $self->{'token'} );

	if( $xtable->remove( $wherec ) )
	{
		$tcache->purgeit( lc $xtable->alias(), $self->{'token'} );
		return(1);
	}
	return(0);

}

sub disable
{
	# +-+-+-+-+-+-+-+
	# |d|i|s|a|b|l|e|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Disable the rocord(Wrapper method of BdDR::BounceLogs->disable())
	# @Param <obj>	(K::BdDR::BounceLogs::Table) TxnTable object
	# @Param <obj>	(K::BdDR::Cache) Cache object
	# @Return	(Integer)  1 = Successfully disabled
	#		(Integer)  0 = No data to UPDATE(disable) in the db || Failed to UPDATE
	my $self = shift();
	my $xtable = shift() || return(0);
	my $tcache = shift() || return(0);
	my $xcache = undef();
	my $wherec = {};

	return(0) if( ! $self->{'id'} && ! $self->{'token'} );
	$wherec->{'id'} = $self->{'id'} if( $self->{'id'} );
	$wherec->{'token'} = $self->{'token'} if( $self->{'token'} );

	if( $xtable->disable( $wherec ) )
	{
		$xcache = $tcache->getit( lc $xtable->alias(), $self->{'token'} );
		$xcache->{'disabled'} = 1;
		$tcache->setit( lc $xtable->alias(), $self->{'token'}, $xcache );
		return(1);
	}
	return(0);
}

1;
__END__
