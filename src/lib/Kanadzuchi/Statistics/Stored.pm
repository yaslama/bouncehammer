# $Id: Stored.pm,v 1.2 2010/08/16 12:05:12 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Statistics::
                                         
  ##### ##                           ##  
 ###  ###### ####  #####   ####      ##  
  ###   ##  ##  ## ##  ## ##  ##  #####  
   ###  ##  ##  ## ##     ###### ##  ##  
    ### ##  ##  ## ##     ##     ##  ##  
 #####   ### ####  ##      ####   #####  
package Kanadzuchi::Statistics::Stored;
use base 'Kanadzuchi::Statistics';
use strict;
use warnings;
use Kanadzuchi::Mail;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'cache',	# (Ref->Array)
);

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param <ref>	(Ref->Hash)
	# @Return	(Kanadzuchi::Statistics::Stored) Object
	my $class = shift();
	my $argvs = { @_ };

	# Default values
	$argvs->{'cache'} = [];
	return $class->SUPER::new(%$argvs);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub congregat {}
sub aggregate
{
	# +-+-+-+-+-+-+-+-+-+
	# |a|g|g|r|e|g|a|t|e|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Aggregate by the column
	# @Param <str>	(String) Column name
	# @Return	(Ref->Array) Aggregated data
	my $self = shift();
	my $name = shift() || return [];
	my $cond = shift() || {};

	$cond = undef() if( ref($cond) eq q|HASH| && ! keys %$cond );

	my $aggr = $self->congregat( $name, $cond );
	my $list = [];

	if( $name eq 'hostgroup' || $name eq 'reason' )
	{
		$list = $name eq 'reason' 
			? Kanadzuchi::Mail->id2rname('@')
			: Kanadzuchi::Mail->id2gname('@');

		while( my $e =  shift @$list )
		{
			next() if( grep { $e eq $_->{'name'} } @$aggr );
			push( @$aggr, { 'name' => $e, 'size' => 0, 'freq' => 0 } );
		}
	}
	$self->{'cache'} = $aggr if( scalar @$aggr );
	return $aggr;
}

1;
__END__
