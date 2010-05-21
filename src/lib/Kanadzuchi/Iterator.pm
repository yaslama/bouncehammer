# $Id: Iterator.pm,v 1.1 2010/05/16 23:58:16 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                   
  ####  ##                      ##                 
   ## ###### ####  ##### #### ###### ####  #####   
   ##   ##  ##  ## ##  ##   ##  ##  ##  ## ##  ##  
   ##   ##  ###### ##    #####  ##  ##  ## ##      
   ##   ##  ##     ##   ##  ##  ##  ##  ## ##      
  ####   ### ####  ##    #####   ### ####  ##      
package Kanadzuchi::Iterator;

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
	'data',			# (Ref->Array) Data
	'position',		# (Integer) Current position
	'count'			# (Integer) Content length
);

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
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param <ref>	(Ref->Array) Data
	# @Return	(Kanadzuchi::Iterator) Ojbect
	my $class = shift();
	my $array = shift() || [];
	my $argvs = { 'count' => 0, 'position' => 0, };

	$argvs->{'data'} = ref($array) eq q|ARRAY| ? $array : [];
	$argvs->{'count'} = scalar @{ $argvs->{'data'} };
	return( $class->SUPER::new($argvs));
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reset
{
	# +-+-+-+-+-+
	# |r|e|s|e|t|
	# +-+-+-+-+-+
	#
	# @Description	Reset/Initialize
	# @Param	<None>
	# @Return	(Kanadzuchi::Iterator) This ojbect
	my $self = shift();
	$self->{'position'} = 0;
	return($self);
}

sub flush
{
	# +-+-+-+-+-+
	# |f|l|u|s|h|
	# +-+-+-+-+-+
	#
	# @Description	Flush all of the data
	# @Param	<None>
	# @Return	(Kanadzuchi::Iterator) This ojbect
	my $self = shift();
	$self->{'data'} = [];
	$self->{'count'} = 0;
	$self->{'position'} = 0;
	return($self);
}

sub first
{
	# +-+-+-+-+-+
	# |f|i|r|s|t|
	# +-+-+-+-+-+
	#
	# @Description	Return first entity
	# @Param	<None>
	# @Return	First entity
	my $self = shift();
	$self->{'position'} = 0;
	return($self->{'data'}->[0]) if( $self->{'count'} );
	return(undef());
}

sub hasnext
{
	# +-+-+-+-+-+-+-+
	# |h|a|s|n|e|x|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	There is next entity or not
	# @Param	<None>
	# @Return	(Boolean) 0 = does not exist, 1 = exists
	my $self = shift();
	my $xpos = $self->{'position'} + 1;
	return(1) if( defined($self->{'data'}->[$xpos]) );
	return(0);
}

sub next
{
	# +-+-+-+-+
	# |n|e|x|t|
	# +-+-+-+-+
	#
	# @Description	Return the next entity
	# @Param	<None>
	# @Return	Next entity in the data
	my $self = shift();
	my $xpos = $self->{'position'} + 1;
	my $next = undef();

	return(undef()) if( $xpos > $self->{'count'} );
	return($self->first()) if( $xpos < 0 );

	$next = $self->{'data'}->[ $self->{'position'} ];
	$self->{'position'} = $xpos;
	return($next);
}

sub prev
{
	# +-+-+-+-+
	# |p|r|e|v|
	# +-+-+-+-+
	#
	# @Description	Return the previous entity
	# @Param	<None>
	# @Return	Previous entity in the data
	my $self = shift();
	my $xpos = $self->{'position'} - 1;
	my $prev = undef();

	return(undef()) if( $xpos > $self->{'count'} );
	return($self->first()) if( $xpos < 0 );

	$prev = $self->{'data'}->[ $self->{'position'} ];
	$self->{'position'} = $xpos;
	return($prev);
}

sub all
{
	# +-+-+-+
	# |a|l|l|
	# +-+-+-+
	#
	# @Description	Return all data
	# @Param	<None>
	# @Return	(Ref->Array) All of the data
	my $self = shift();
	return($self->{'data'});
}


1;
__END__
