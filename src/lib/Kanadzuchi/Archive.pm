# $Id: Archive.pm,v 1.6 2010/06/10 10:28:35 ak Exp $
# -Id: Compress.pm,v 1.1 2009/08/29 08:04:54 ak Exp -
# -Id: Compress.pm,v 1.2 2009/05/29 08:22:21 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                
   ##                ##      ##                 
  ####  #####   #### ##          ##  ##  ####   
 ##  ## ##  ## ##    #####  ###  ##  ## ##  ##  
 ###### ##     ##    ##  ##  ##  ##  ## ######  
 ##  ## ##     ##    ##  ##  ##   ####  ##      
 ##  ## ##      #### ##  ## ####   ##    ####   
package Kanadzuchi::Archive;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Path::Class;
use Perl6::Slurp;
use Digest::MD5;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'input',	# (Path::Class::File) Source file
	'output',	# (Path::Class::File) Compressed file
	'cleanup',	# (Integer) Remove the file after compression
	'override',	# (Integer) Override flag, 1 = Override
	'level',	# (Integer) Compression level(1-9)
	'filename',	# (String) Extracted file name
	'format',	# (String) Data compression format
	'prefix',	# (String) Archive file prefix
	'module',	# (String) Module name, IO::Compress::*
);

#  ____ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||o |||n |||s |||t |||a |||n |||t ||
# ||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub ARCHIVEFORMAT() { 'gzip' }	# Default archive format

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
	# @Return	Kanadzuchi::Archive::* Object
	my $class = shift();
	my $argvs = { @_ };
	my $plmod = q();
	my $afext = { 'zip' => 'zip', 'gzip' => 'gz', 'bzip2' => 'bz2' };

	MODULENAME: {
		$plmod = [split( q{::}, $class )]->[2] || $class->ARCHIVEFORMAT();
		$argvs->{'module'} = q|IO::Compress::|.$plmod;
	}

	INPUT: {
		if( defined($argvs->{'input'}) )
		{
			last() if( ref($argvs->{'input'}) =~ m{\APath::Class::File} );
			$argvs->{'input'} = new Path::Class::File( $argvs->{'input'} );
		}
	}

	OUTPUT: {
		$argvs->{'format'} ||= lc( $plmod );
		$argvs->{'prefix'} = $afext->{ $argvs->{'format'} };
		last() unless( defined($argvs->{'input'}) );

		if( defined($argvs->{'output'}) )
		{
			last() if( ref($argvs->{'output'}) =~ m{\APath::Class::File} );
			$argvs->{'output'} .= $argvs->{'prefix'} unless( $argvs->{'output'} =~ m{[.](zip|gz|bz2)\z} );
			$argvs->{'output'}  = new Path::Class::File( $argvs->{'output'} );
		}
		else
		{
			$argvs->{'output'} = new Path::Class::File( $argvs->{'input'}.q{.}.$argvs->{'prefix'} );
		}
	}

	FILENAME: {
		if( defined($argvs->{'filename'}) )
		{
			# Remove the directory
			if( ref($argvs->{'filename'}) =~ m{\APath::Class::File} )
			{
				$argvs->{'filename'} = $argvs->{'filename'}->basename();
			}
			else
			{
				$argvs->{'filename'} = [reverse(split(q{/}, $argvs->{'filename'}))]->[0];
			}
		}
		else
		{
			last() unless( defined($argvs->{'input'}) );
			$argvs->{'filename'} = $argvs->{'input'}->basename();
		}
	}

	$argvs->{'override'} = $argvs->{'override'} ? 1 : 0;
	$argvs->{'cleanup'} = $argvs->{'cleanup'} ? 1 : 0;
	$argvs->{'level'} ||= 6;

	return( $class->SUPER::new($argvs) );
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub is_available
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|a|v|a|i|l|a|b|l|e|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Is avaiable compression format or not
	# @Param	<None>
	# @Return	1 = Is available
	#		0 = Is not.
	my $self = shift();
	my $path = $self->{'module'};

	$path =~ y{:}{/}s;
	$path .= '.pm';

	eval { require $path; };
	return(1) unless( $@ );
	return(0);
}

sub compress { };


1;
__END__
