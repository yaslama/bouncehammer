# $Id: YAML.pm,v 1.1 2010/06/25 19:29:28 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Statistics::Stored::
                             
 ##  ##  ##   ##  ## ##      
 ##  ## ####  ###### ##      
  #### ##  ## ###### ##      
   ##  ###### ##  ## ##      
   ##  ##  ## ##  ## ##      
   ##  ##  ## ##  ## ######  
package Kanadzuchi::Statistics::Stored::YAML;
use base 'Kanadzuchi::Statistics::Stored';
use strict;
use warnings;
use Kanadzuchi::Metadata;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'file',		# (Ref->Array|Path::Class::File|String) YAML File(s)
	'data',		# (Ref->Array) Loaded data from file
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
	# @Return	(Kanadzuchi::Statistics::YAML) Object
	my $class = shift();
	my $argvs = { @_ };
	my $ipsum = undef();

	$argvs->{'data'} = [];
	$ipsum = $class->SUPER::new(%$argvs);
	$ipsum->load() if( defined $argvs->{'file'} );
	return $ipsum;
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub load
{
	# +-+-+-+-+
	# |l|o|a|d|
	# +-+-+-+-+
	#
	# @Description	Load the file(s)
	# @Param	<None>
	# @Return	(Ref->Array)
	my $self = shift();
	my $data = [];
	my $smpl = [];

	$self->{'data'} = [];
	return [] unless( defined $self->{'file'} );

	if( ref($self->{'file'}) eq q|ARRAY| )
	{
		foreach my $f ( @{ $self->{'file'} } )
		{
			next() unless $f;
			push( @$data, @{ Kanadzuchi::Metadata->to_object($f) } );
		}
	}
	else
	{
		$data = Kanadzuchi::Metadata->to_object( $self->{'file'} );
	}
	return [] unless( scalar @$data );

	while( my $e = shift @$data )
	{
		push( @$smpl, {
			'senderdomain' => $e->{'senderdomain'},
			'destination' => $e->{'destination'},
			'frequency' => $e->{'frequency'},
			'hostgroup' => $e->{'hostgroup'},
			'provider' => $e->{'provider'},
			'reason' => $e->{'reason'}, } );
	}
	$data = undef();
	$self->{'data'} = $smpl;
	return $self;
}

sub congregat
{
	# +-+-+-+-+-+-+-+-+-+
	# |c|o|n|g|r|e|g|a|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Count by each key of the table
	# @Param <str>	(String) Table name or alias
	# @Return	(Ref->Hash)
	my $self = shift();
	my $name = shift() || return undef();
	my $size = {};
	my $freq = {};
	my $aggr = [];

	return undef() unless( scalar @{ $self->{'data'} } );
	map { $size->{ $_ }++ } map( $_->{ $name }, @{ $self->{'data'} } );
	map { $freq->{ $_->{ $name } } += $_->{'frequency'} } @{ $self->{'data'} };

	foreach my $e ( keys %$size )
	{
		push( @$aggr, { 'name' => $e, 'size' => $size->{$e}, 'freq' => $freq->{$e} } );
	}
	return $aggr;
}

1;
__END__
