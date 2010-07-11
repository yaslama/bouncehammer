# $Id: Test.pm,v 1.6 2010/07/11 09:20:41 ak Exp $
# Kanadzuchi::
                               
 ######                  ##    
   ##     ####   ##### ######  
   ##    ##  ## ##       ##    
   ##    ######  ####    ##    
   ##    ##         ##   ##    
   ##     ####  #####     ###  
                               
package Kanadzuchi::Test;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use 5.008001;
use strict;
use warnings;
use base 'Class::Accessor::Fast::XS';
use Path::Class;
use JSON::Syck;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Rewritable accessors
__PACKAGE__->mk_accessors(
	'class',	# (String) Class name
	'methods',	# (Ref->Array) Methods
	'instance',	# (Object) Instance
	'tempdir',	# (Path::Class::Dir) Path to output directory
	'example',	# (Path::Class::Dir) Path to sample directory
);

sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param	<None>
	# @Return	(Kanadzuchi) Object
	my $class = shift();
	my $argvs = { @_ };

	$argvs->{'tempdir'} = new Path::Class::Dir('./.test');
	$argvs->{'example'} = new Path::Class::Dir('./examples');
	return( $class->SUPER::new($argvs) );
}

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
our $FalseValues = [ 0, "0", "", undef(), () ];
our $ZeroValues = [ 0, 0.0, 00_00, -0, +0, 0e0, 0e1, 0e-1, 0b0000,
	0x0, 00, 000, 0000, 0<<0, 0<<1, 0>>0, 0>>1, 0%1, "0",
	'0', q( ), qq( ),
];
our $NegativeValues = [ -1, -2, -1e1, -1e2 ];

# See http://en.wikipedia.org/wiki/ASCII
our $EscapeCharacters = [ "\a", "a\b", "\t", "\n", "\f", "\r", "\0","\e", ];

our $ControlCharacters = [ "\c@", "\cA", "\cB", "\cC", "\cD", "\cE", "\cF", "\cG",
			"a\cH", "\cI", "\cJ", "\cK", "\cL", "\cM", "\cN", "\cO",
			"\cP", "\cQ", "\cR", "\cS", "\cT", "\cU", "\cV", "\cW", "\cX",
			"\cY", "\cZ", "\c[", "\c\\", "\c]", "\c^", "\c_", "\c?", ];

our $ExceptionalValues = [];
push( @$ExceptionalValues, 
	@$FalseValues, @$ZeroValues, @$EscapeCharacters, @$ControlCharacters );
1;
__END__
