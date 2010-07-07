# $Id: Zip.pm,v 1.4 2010/07/07 11:21:40 ak Exp $
# -Id: Zip.pm,v 1.1 2009/08/29 08:05:06 ak Exp -
# -Id: Zip.pm,v 1.2 2009/05/26 02:45:39 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Archive::
                       
 ######    ##          
    ###        #####   
   ##     ###  ##  ##  
  ##       ##  ##  ##  
 ###       ##  #####   
 ######   #### ##      
               ##      
package Kanadzuchi::Archive::Zip;

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
	# @Description	Compress the file with Zip
	# @Param	<None>
	# @Return	n = Size of the compressed file 
	#		0 = Failed to compress or missing argument
	my $self = shift();
	my $zipf = undef();
	
	return(0) unless( $self->{'input'} );
	return(0) unless( -r $self->{'input'} );
	return(0) if( $self->{'override'} == 0 && -e $self->{'output'} );

	eval {
		use IO::Compress::Zip;

		$self->{'output'}->remove() if( $self->{'override'} && -e $self->{'output'} );
		$zipf = IO::Compress::Zip->new(
				$self->{'output'}->stringify(),
				'Name' => $self->{'filename'},
				'Level' => $self->{'level'},
				'ExtAttr' => ( 0644 << 16 ),
				'TextFlag' => -T $self->{'input'} ? 1 : 0,
				'Append' => 0, );
	};
	return(0) if( $@ );

	$zipf->binmode();
	$zipf->print( Perl6::Slurp::slurp( $self->{'input'}->stringify() ) );
	$zipf->close();
	$self->{'input'}->remove() if( $self->{'cleanup'} );
	return $self->{'output'}->stat->size();
}

1;
__END__
