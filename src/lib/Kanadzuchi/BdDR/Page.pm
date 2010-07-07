# $Id: Page.pm,v 1.5 2010/07/07 11:21:42 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::BdDR::

 #####                        
 ##  ##  ####   #####  ####   
 ##  ##     ## ##  ## ##  ##  
 #####   ##### ##  ## ######  
 ##     ##  ##  ##### ##      
 ##      #####     ##  ####   
               #####          
package Kanadzuchi::BdDR::Page;
use base 'Class::Accessor::Fast::XS';
use POSIX;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'currentpagenum',	# (Integer) Current page number
	'resultsperpage',	# (Integer) The number of results a page
	'colnameorderby',	# (String) Column name used 'ORDER BY'
	'descendorderby',	# (Integer) 1 = DESC, 0 = Not descending
	'numofrecordsin',	# (Integer) The number of records in the DB
	'lastpagenumber',	# (Integer) Last page number
	'offsetposition',	# (Integer) OFFSET position number
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
	my $argvs = { @_ };

	DEFAULT_VALUES: {
		$argvs->{'currentpagenum'} = 1    unless(defined($argvs->{'currentpagenum'}));
		$argvs->{'resultsperpage'} = 10   unless(defined($argvs->{'resultsperpage'}));
		$argvs->{'colnameorderby'} = 'id' unless(defined($argvs->{'colnameorderby'}));
		$argvs->{'descendorderby'} = 0    unless(defined($argvs->{'descendorderby'}));
		$argvs->{'numofrecordsin'} = 0    unless(defined($argvs->{'numofrecordsin'}));
		$argvs->{'lastpagenumber'} = 0    unless(defined($argvs->{'lastpagenumber'}));
		$argvs->{'offsetposition'} = 0    unless(defined($argvs->{'offsetposition'}));
	}
	return $class->SUPER::new($argvs);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub set
{
	# +-+-+-+
	# |s|e|t|
	# +-+-+-+
	#
	# @Description	Setting up the page number
	# @Param <int>	(Integer) The number of records in the DB
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();
	my $recs = shift() || 0;

	return $self if( $recs !~ m{\A\d+\z} || $recs < 1 );
	$self->{'numofrecordsin'} = $recs;
	$self->{'lastpagenumber'} = int POSIX::ceil( $recs / $self->{'resultsperpage'} );
	return $self;
}

sub reset
{
	# +-+-+-+-+-+
	# |r|e|s|e|t|
	# +-+-+-+-+-+
	#
	# @Description	Reset values
	# @Param	<None>
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();

	$self->{'currentpagenum'} = 1;
	$self->{'resultsperpage'} = 10;
	$self->{'colnameorderby'} = 'id';
	$self->{'descendorderby'} = 0;
	$self->{'numofrecordsin'} = 0;
	$self->{'lastpagenumber'} = 0;
	$self->{'offsetposition'} = 0;

	return $self;
}

sub count
{
	# +-+-+-+-+-+
	# |c|o|u|n|t|
	# +-+-+-+-+-+
	#
	# @Description	Return the number of entries
	# @Param	<None>
	# @Return	(Integer) The number of entries
	return shift->{'numofrecordsin'};
}

sub skip
{
	# +-+-+-+-+
	# |s|k|i|p|
	# +-+-+-+-+
	#
	# @Description	Skip to the page
	# @Param <int>	(Integer) Page number
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();
	my $page = shift() || $self->{'currentpagenum'};
	my $ppos = $page;

	return $self unless( $page =~ m{\A\d+\z} );

	$ppos = $page < 0 ? 1 : $page > $self->{'lastpagenumber'} ? $self->{'lastpagenumber'} : $page;
	$self->{'offsetposition'} = ( $ppos - 1 ) * $self->{'resultsperpage'};
	$self->{'currentpagenum'} = $ppos;

	return $self;
}

sub hasnext
{
	# +-+-+-+-+-+-+-+
	# |h|a|s|n|e|x|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	There is next page or not
	# @Param	<None>
	# @Return	(Boolean) 0 = does not exist, 1 = exists
	my $self = shift();
	return(1) if( $self->{'currentpagenum'} < $self->{'lastpagenumber'} );
	return(0);
}

sub next
{
	# +-+-+-+-+
	# |n|e|x|t|
	# +-+-+-+-+
	#
	# @Description	Next page
	# @Param 	<None>
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();
	my $curr = $self->{'currentpagenum'};
	my $next = $self->{'currentpagenum'} + 1;

	if( $self->hasnext() )
	{
		$self->{'offsetposition'} = $curr * $self->{'resultsperpage'};
		$self->{'currentpagenum'} = $next;
		return $self;
	}
	else
	{
		$self->{'offsetposition'} = ( $curr - 1 ) * $self->{'resultsperpage'};
		$self->{'currentpagenum'} = $self->{'lastpagenumber'};
		return undef;
	}
}

sub prev
{
	# +-+-+-+-+
	# |p|r|e|v|
	# +-+-+-+-+
	#
	# @Description	Previous page
	# @Param 	<None>
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();
	my $curr = $self->{'currentpagenum'};
	my $prev = $self->{'currentpagenum'} - 1;

	if( $curr > 1 )
	{
		$self->{'currentpagenum'} = $prev;
		$self->{'offsetposition'} = ( $prev - 1 ) * $self->{'resultsperpage'};
		return $self;
	}
	else
	{
		$self->{'offsetposition'} = 0;
		$self->{'currentpagenum'} = 1;
		return undef;
	}
}

sub to_hashref
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |t|o|_|h|a|s|h|r|e|f|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Returns DBIx::Skinny compatible hash reference
	# @Param 	<None>
	# @Return	(Kanadzuchi::BdDR::Page) This object
	my $self = shift();
	my $page = {};

	$page->{'limit'} = $self->{'resultsperpage'} if( $self->{'resultsperpage'} );
	$page->{'offset'} = $self->{'offsetposition'} if( $self->{'offsetposition'} );
	$page->{'order_by'} = { $self->{'colnameorderby'} => $self->{'descendorderby'} ? 'DESC' : q() };
	return $page;
}

sub to_sql
{
	# +-+-+-+-+-+-+
	# |t|o|_|s|q|l|
	# +-+-+-+-+-+-+
	#
	# @Description	Convert from object to SQL statement
	# @Param 	<None>
	# @Return	(String) SQL Statement
	my $self = shift();
	my $page = {};
	my $sqls = [];

	if( $self->{'colnameorderby'} )
	{
		push( @$sqls, q(ORDER BY ).$self->{'colnameorderby'} );
		push( @$sqls, q( DESC) ) if( $self->{'descendroderby'} );
	}

	push( @$sqls, q(LIMIT ).$self->{'resultsperpage'} ) if( $self->{'resultsperpage'} );
	push( @$sqls, q(OFFSET ).$self->{'offsetposition'} ) if( $self->{'offsetposition'} );
	return join( q{ }, @$sqls );
}

1;
__END__
