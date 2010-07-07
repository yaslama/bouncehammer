# $Id: Bzip2.pm,v 1.3 2010/07/07 11:21:40 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Archive::
                                    
 #####            ##         ####   
 ##  ## ######        ##### ##  ##  
 #####     ##    ###  ##  ##    ##  
 ##  ##   ##      ##  ##  ## ####   
 ##  ##  ##       ##  ##### ##      
 #####  ######   #### ##    ######  
                      ##            
package Kanadzuchi::Archive::Bzip2;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Archive';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
sub compress
{
	# +-+-+-+-+-+-+-+-+
	# |c|o|m|p|r|e|s|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Compress the file with Bzip2
	# @Param	<None>
	# @Return	n = Size of the compressed file 
	#		0 = Failed to compress or missing argument
	my $self = shift();
	my $bzip = undef();

	return(0) unless( $self->{'input'} );
	return(0) unless( -r $self->{'input'} );
	return(0) if( $self->{'override'} == 0 && -e $self->{'output'} );

	eval {
		use IO::Compress::Bzip2;

		$self->{'output'}->remove() if( $self->{'override'} && -e $self->{'output'} );
		$bzip = IO::Compress::Bzip2->new( $self->{'output'}->stringify(), 'Append' => 0, );
	};
	return(0) if $@;

	$bzip->binmode();
	$bzip->print( Perl6::Slurp::slurp( $self->{'input'}->stringify() ) );
	$bzip->close();
	$self->{'input'}->remove() if( $self->{'cleanup'} );
	return $self->{'output'}->stat->size();
}

1;
__END__
