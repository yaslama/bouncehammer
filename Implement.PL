# $Id: Implement.PL,v 1.1 2010/03/23 19:23:04 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
use strict;
use warnings;

my $Command = lc($ARGV[0]) || q();
my $Implementations = {
	'tb' => \&TB,
};

sub TB
{
	# -T, -B operation on file handle
	my $testf = './RELEASE_NOTES';
	my $fileh = undef();
	return(q()) unless( -r $testf );
	open( $fileh, '<', $testf ) || return(q());
	eval { -T $fileh; };
	return($@)
}

if( exists($Implementations->{$Command}) )
{
	print $Implementations->{$Command}->();
}
else
{
	printf(STDERR "Usage: perl %s (tb|check|installed|missing)\n", $0 );
}

__END__
