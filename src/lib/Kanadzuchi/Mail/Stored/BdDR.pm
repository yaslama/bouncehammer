# $Id: BdDR.pm,v 1.4 2010/05/19 18:25:05 ak Exp $
# -Id: RDB.pm,v 1.10 2010/03/26 07:21:27 ak Exp -
# -Id: Stored.pm,v 1.5 2009/12/31 16:30:13 ak Exp -
# -Id: Stored.pm,v 1.1 2009/08/29 07:33:13 ak Exp -
# -Id: Stored.pm,v 1.14 2009/08/12 01:59:20 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Stored::
                              
 #####      ## ####   #####   
 ##  ##     ## ## ##  ##  ##  
 #####   ##### ##  ## ##  ##  
 ##  ## ##  ## ##  ## #####   
 ##  ## ##  ## ## ##  ## ##   
 #####   ##### ####   ##  ##  
package Kanadzuchi::Mail::Stored::BdDR;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail::Stored';
use strict;
use warnings;
use Kanadzuchi::BdDR::BounceLogs;
use Kanadzuchi::BdDR::Page;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# __PACKAGE__->mk_accessors();

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
sub searchandnew
{
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#|s|e|a|r|c|h|a|n|d|n|e|w|
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	new() by SELECT * FROM t_bouncelogs WHERE '?' = '?'
	# @Param <obj>	(DBI::db) Database handle
	# @Param <ref>	(Ref->Hash) Where condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Return	(Kanadzuchi::Iterator) K::Mail::Stored::BdDR(s)
	my $class = shift();
	my $txdbh = shift() || return( Kanadzuchi::Iterator->new([]) );
	my $wcond = shift() || {};
	my $pagin = shift() || Kanadzuchi::BdDR::Page->new();
	my $sdata = [];
	my $txtab = new Kanadzuchi::BdDR::BounceLogs::Table( 'handle' => $txdbh );
	my $xrecs = $txtab->search( $wcond, $pagin );

	map { push( @$sdata, __PACKAGE__->new(%$_) ) } @$xrecs;
	return( Kanadzuchi::Iterator->new($sdata) );
}

1;
__END__
