# $Id: Parser.pm,v 1.4 2010/06/11 00:05:59 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::MIME::
                                            
 #####                                      
 ##  ##  ####  #####   #####  ####  #####   
 ##  ##     ## ##  ## ##     ##  ## ##  ##  
 #####   ##### ##      ####  ###### ##      
 ##     ##  ## ##         ## ##     ##      
 ##      ##### ##     #####   ####  ##      
package Kanadzuchi::MIME::Parser;
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'data'		# (Ref->Hash) MIME Entity
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
	# @Param <ref>	(Ref->Scalar) Data
	# @Return	(Kanadzuchi::MIME::Parser) Ojbect
	my $class = shift();
	my $argvs = { 'data' => {} };
	return( $class->SUPER::new($argvs));
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub parseit
{
	# +-+-+-+-+-+-+-+
	# |p|a|r|s|e|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Parse the email body as a header
	# @Param <ref>	(Ref->Scalar|String) Email header text
	# @Return	(Kanadzuchi::MIME::Parser) This object
	my $self = shift();
	my $text = shift() || return($self);
	my $data = ref($text) eq q|SCALAR| ? $$text : $text;

	return($self) unless( defined $data );
	return($self) if( ref($data) || ! length($data) );
	$self->flush();

	foreach my $thisline ( split( qq{\n}, $data ) )
	{
		if( $thisline =~ m{\A(.+?)[:](.+)\z} )
		{
			my $headname = $1;
			my $headdata = $2;

			$headdata =~ s{\A\s+}{};
			$headdata =~ s{\s+\z}{};
			next() unless( $headdata );

			$self->{'data'}->{$headname} = [] unless( ref($self->{'data'}->{$headname}) eq q|ARRAY| );
			push( @{ $self->{'data'}->{ $headname } }, $headdata );
		}
	}
	return($self);
}

sub flush
{
	# +-+-+-+-+-+
	# |f|l|u|s|h|
	# +-+-+-+-+-+
	#
	# @Description	Delete all of the data
	# @Param	<None>
	# @Return	(Integer) The number of entries
	my $self = shift();
	$self->{'data'} = {};
	return($self);
}

sub count
{
	# +-+-+-+-+-+
	# |c|o|u|n|t|
	# +-+-+-+-+-+
	#
	# @Description	Return the number of headers
	# @Param	<None>
	# @Return	(Integer) The number of headers
	my $self = shift();
	return( keys %{ $self->{'data'} } );
}

sub getit
{
	# +-+-+-+-+-+
	# |g|e|t|i|t|
	# +-+-+-+-+-+
	#
	# @Description	Get the header content
	# @Param <tab>	(String) Header name
	# @Return	(Array|String) Value
	my $self = shift();
	my $head = shift() || return(undef());
	my $data = undef();

	return(q{}) unless( ref($self->{'data'}->{$head}) eq q|ARRAY| );
	return(q{}) unless( scalar @{ $self->{'data'}->{$head} } );
	$data = $self->{'data'}->{$head};

	return(@$data) if( wantarray() );
	return($data->[0]);
}

1;
__END__
