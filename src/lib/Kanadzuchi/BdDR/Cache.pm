# $Id: Cache.pm,v 1.2 2010/05/16 23:58:20 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::BdDR::
                                    
  ####               ##             
 ##  ##  ####   #### ##      ####   
 ##         ## ##    #####  ##  ##  
 ##      ##### ##    ##  ## ######  
 ##  ## ##  ## ##    ##  ## ##      
  ####   #####  #### ##  ##  ####   
package Kanadzuchi::BdDR::Cache;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'cache',	# (Ref->Hash) Cache data
	'count',	# (Ref->Hash) Hit count
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
	# @Param	<None>
	# @Return	Kanadzuchi::BdDR::Page Object
	my $class = shift();
	my $argvs = { 'cache' => {}, 'count' => {} };
	return($class->SUPER::new($argvs));
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub getit
{
	# +-+-+-+-+-+
	# |g|e|t|i|t|
	# +-+-+-+-+-+
	#
	# @Description	Get the record from cache data
	# @Param <tab>	(String) Table name
	# @Param <key>	(String) Key string
	# @Return	(String|Integer) Value
	my $self = shift();
	my $ctab = shift() || return(undef());
	my $name = shift() || return(undef());
	my $data = $self->{'cache'}->{$ctab}->{$name};

	$self->{'count'}->{$ctab}++ if( defined($data) );
	return($data);
}

sub setit
{
	# +-+-+-+-+-+
	# |s|e|t|i|t|
	# +-+-+-+-+-+
	#
	# @Description	Set the record into cache data
	# @Param <tab>	(String) Table name
	# @Param <key>	(String) Key
	# @Param <val>	(String) Value
	# @Return	(K::B::Cache) This object
	my $self = shift();
	my $ctab = shift() || return($self);
	my $thek = shift() || return($self);
	my $thev = shift();

	$self->{'cache'}->{$ctab}->{$thek} = $thev;
	return($self);
}

1;
__END__
