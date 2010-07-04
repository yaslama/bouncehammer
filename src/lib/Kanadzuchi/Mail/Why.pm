# $Id: Why.pm,v 1.8 2010/07/04 23:46:50 ak Exp $
# -Id: Pattern.pm,v 1.1 2009/08/29 07:33:13 ak Exp -
# -Id: Pattern.pm,v 1.3 2009/05/29 08:22:25 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::
                       
 ##  ## ##             
 ##  ## ##     ##  ##  
 ##  ## #####  ##  ##  
 ###### ##  ## ##  ##  
 ###### ##  ##  #####  
 ##  ## ##  ##    ##   
               ####    
package Kanadzuchi::Mail::Why;

# Cache for error text patterns
my $Exemplaria = {
	'ExceedLimit' => [],
	'Filtered' => [],
	'HostUnknown' => [],
	'MailboxFull' => [],
	'RelayingDenied' => [],
	'SystemFull' => [],
	'MesgTooBig' => [],
	'UserUnknown' => [],
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub habettextu
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |h|a|b|e|t|t|e|x|t|u|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Argument text is included in the patterns or not.
	# @Param <str>	(String)
	# @Return	(Integer) 1 = included
	# @Return	(Integer) 0 = not
	my $class = shift();
	my $etext = shift() || return 0;
	my $klass = $class; $klass =~ s{\A.+::}{};

	unless( scalar @{ $Exemplaria->{ $klass } } )
	{
		$Exemplaria->{ $klass } = $class->exemplaria();
	}

	return 1 if( grep { lc($etext) =~ $_ } @{ $Exemplaria->{$klass} } );
	return 0;
}

1;
__END__
