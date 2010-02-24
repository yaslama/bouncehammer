use strict;
use warnings;
use lib qw(./t/lib ./dist/lib ./src/lib);
use Test::More;

my $Modules = [
	q(Kanadzuchi::API),
	q(Kanadzuchi::API::HTTP),
];

plan( tests => $#{$Modules} + 1 );
foreach my $module ( @$Modules ){ use_ok($module); }

__END__
