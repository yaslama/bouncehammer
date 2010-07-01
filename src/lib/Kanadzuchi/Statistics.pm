# $Id: Statistics.pm,v 1.7 2010/06/25 19:29:22 ak Exp $
# -Id: Statistics.pm,v 1.1 2009/08/29 09:00:23 ak Exp -
# -Id: Statistics.pm,v 1.1 2009/07/16 09:05:33 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                               
  ##### ##          ##    ##           ##    ##                
 ###  ###### #### ######       ##### ######       ####  #####  
  ###   ##      ##  ##   ###  ##       ##   ###  ##    ##      
   ###  ##   #####  ##    ##   ####    ##    ##  ##     ####   
    ### ##  ##  ##  ##    ##      ##   ##    ##  ##        ##  
 #####   ### #####   ### #### #####     ### ####  #### #####   
package Kanadzuchi::Statistics;
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use List::Util;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'label',	# (String) Name of this statistics
	'rounding',	# (Integer) Rounding digit, 1 = int(), 0 = Do Not Round
	'unbiased',	# (Integer) Unbiased variance
	'sample',	# (Ref->Array) Sample
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
	# @Param
	# @Return	(Kanadzuchi::Statistics) Object
	my $class = shift();
	my $argvs = { @_ };

	# Default values
	$argvs->{'rounding'} = 4 unless( defined($argvs->{'rounding'}) );
	$argvs->{'unbiased'} = 1 unless( defined($argvs->{'unbiased'}) );
	$argvs->{'sample'} ||= [];
	$argvs->{'label'} ||= q();
	return $class->SUPER::new($argvs);
}

sub is_number
{
	# +-+-+-+-+-+-+-+-+-+
	# |i|s|_|n|u|m|b|e|r|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	The argument is a number or not
	# @Param <str>	(String) Number
	# @Return	(Integer) 1 = Is a number
	#		(Integer) 0 = Is not a number
	my $class = shift();
	my $n = shift();

	return(1) if( $n =~ m{\A[-+]?\d+\z} );			# Integer
	return(1) if( $n =~ m{\A[-+]?\d+[.]\d+\z} );		# Float
	return(1) if( $n =~ m{\A[-+]?\d+[Ee][-+]?\d+\z} );	# Float(e)
	return(0);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub round
{
	# +-+-+-+-+-+
	# |r|o|u|n|d|
	# +-+-+-+-+-+
	#
	# @Description	Rounding
	# @Param <num>	(Float) Number
	# @Return	(Float) Rounded number
	my $self = shift();
	my $n = shift() || return q{};
	my $p = 0;

	return $n if( $self->{'rounding'} == 0 );
	return int($n) if( $self->{'rounding'} == 1 );

	$p = 10 ** ( $self->{'rounding'} - 1 );
	return( int( $n * $p + 0.5 ) / $p );
}

# Descriptive Statistics
sub size
{
	# +-+-+-+-+
	# |s|i|z|e|
	# +-+-+-+-+
	#
	# @Description	Sample size
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Integer) Sample size
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};
	my $size = 0;

	return(-1) unless( ref($smpl) eq q|ARRAY| );
	return scalar(@$smpl);
}

sub mean
{
	# +-+-+-+-+
	# |m|e|a|n|
	# +-+-+-+-+
	#
	# @Description	Mean
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Mean
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};
	my $mean = 0;

	return q{} if( $self->size( $smpl ) < 1 );
	$mean = List::Util::sum( @{$smpl} ) / $self->size( $smpl );
	return $self->round( $mean );
}

*var = *variance;
sub variance
{
	# +-+-+-+-+-+-+-+-+
	# |v|a|r|i|a|n|c|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Variance
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Variance
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};
	my $mean = 0;
	my $diff = [];

	my $rounding = $self->{'rounding'};
	my $variance = 0;

	return q() if( $self->size( $smpl ) < 1 );

	$self->{'rounding'} = 0;
	$mean = $self->mean($smpl);
	$self->{'rounding'} = $rounding;
	return q() unless( __PACKAGE__->is_number( $mean ) );

	$diff = [ map { ( $_ - $mean ) ** 2 } @{$smpl} ];
	$variance = List::Util::sum(@$diff) / ( $self->size($smpl) - $self->{'unbiased'} );

	return $self->round($variance);
}

sub stddev
{
	# +-+-+-+-+-+-+
	# |s|t|d|d|e|v|
	# +-+-+-+-+-+-+
	#
	# @Description	Standard Deviation
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Standard Deviation
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};
	my $rounding = $self->{'rounding'};
	my $variance = 0;

	return q() if( $self->size( $smpl ) < 1 );

	$self->{'rounding'} = 0;
	$variance = $self->variance( $smpl );
	$self->{'rounding'} = $rounding;
	return  $self->round( sqrt($variance) );
}

sub max
{
	# +-+-+-+
	# |m|a|x|
	# +-+-+-+
	#
	# @Description	Maximum
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Maximum
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};

	return q() if( $self->size( $smpl ) < 1 );
	return List::Util::max( @{$smpl} );
}

sub min
{
	# +-+-+-+
	# |m|a|x|
	# +-+-+-+
	#
	# @Description	Minimum
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Minimum
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};

	return q() if( $self->size( $smpl ) < 1 );
	return List::Util::min( @{$smpl} );
}

sub quartile
{
	# +-+-+-+-+-+-+-+-+
	# |q|u|a|r|t|i|l|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Quartile(4-Quantile)
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Param <int>	(Integer) Quartile(1..3), default = 2
	# @Return	(Float) 1st or 2nd or 3rd Quartile
	my $self = shift();
	my $q = shift() || 2;
	my $smpl = shift() || $self->{'sample'};

	my $sorted = [];
	my $qindex = 0;
	my $remain = 0;

	return q() if( $self->size( $smpl ) < 1 );

	$q = 2 if( $q < 1 || $q > 3 );
	$sorted = [ sort { $a <=> $b } @{$smpl} ];
	$qindex = 1 - ( 0.25 * $q ) + ( 0.25 * $q * $self->size( $smpl ) );
	$remain = ( $qindex * 100 ) % 100;
	return $sorted->[$qindex-1] if( $remain == 0 );

	$qindex = int($qindex);
	$remain = $remain / 100;
	return( $sorted->[$qindex-1] + ( $remain * ( $sorted->[$qindex] - $sorted->[$qindex-1] ) ) );
}

sub median
{
	# +-+-+-+-+-+-+
	# |m|e|d|i|a|n|
	# +-+-+-+-+-+-+
	#
	# @Description	Median
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Median
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};
	return( $self->quartile( 2, $smpl ) );
}

sub range
{
	# +-+-+-+-+-+
	# |r|a|n|g|e|
	# +-+-+-+-+-+
	#
	# @Description	Range
	# @Param <ref>	(Ref->Array) Array of sample(optional)
	# @Return	(Float) Range
	my $self = shift();
	my $smpl = shift() || $self->{'sample'};

	return q() if( $self->size( $smpl ) < 1 );
	return( List::Util::max( @{$smpl} ) - List::Util::min( @{$smpl} ) );
}

1;
__END__
