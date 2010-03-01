# $Id: Gzip.pm,v 1.3 2010/03/01 23:41:46 ak Exp $
# -Id: Gzip.pm,v 1.1 2009/08/29 08:05:06 ak Exp -
# -Id: Gzip.pm,v 1.1 2009/05/26 02:45:39 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Archive::
                              
  ####            ##          
 ##  ## ######        #####   
 ##        ##    ###  ##  ##  
 ## ###   ##      ##  ##  ##  
 ##  ##  ##       ##  #####   
  ####  ######   #### ##      
                      ##      
package Kanadzuchi::Archive::Gzip;

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
	# @Description	Compress the file with GZip
	# @Param	<None>
	# @Return	n = Size of the compressed file 
	#		0 = Failed to compress or missing argument
	my $self = shift();
	my $gzip = undef();

	return(0) unless( $self->{'input'} );
	return(0) unless( -r $self->{'input'} );
	return(0) if( $self->{'override'} == 0 && -e $self->{'output'} );

	eval {
		use IO::Compress::Gzip;

		$self->{'output'}->remove() if( $self->{'override'} && -e $self->{'output'} );
		$gzip = IO::Compress::Gzip->new(
				$self->{'output'}->stringify(),
				'Name' => $self->{'filename'},
				'Level' => $self->{'level'},
				'TextFlag' => -T $self->{'input'} ? 1 : 0,
				'Append' => 0, );
	};
	return(0) if( $@ );

	$gzip->binmode();
	$gzip->print( Perl6::Slurp::slurp( $self->{'input'}->stringify() ) );
	$gzip->close();
	$self->{'input'}->remove() if( $self->{'cleanup'} );
	return( $self->{'output'}->stat->size() );

}

1;
__END__
