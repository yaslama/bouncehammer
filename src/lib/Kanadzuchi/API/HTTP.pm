# $Id: HTTP.pm,v 1.10 2010/03/26 07:18:31 ak Exp $
# -Id: HTTP.pm,v 1.3 2009/10/06 00:36:49 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::API::
                              
 ##  ## ###### ###### #####   
 ##  ##   ##     ##   ##  ##  
 ######   ##     ##   ##  ##  
 ##  ##   ##     ##   #####   
 ##  ##   ##     ##   ##      
 ##  ##   ##     ##   ##      
package Kanadzuchi::API::HTTP;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'CGI::Application';
use Kanadzuchi::Exceptions;
use Kanadzuchi::Time;
use Error ':try';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#

#   ____ ____ ____ ____ ____ ____ ____ 
#  ||M |||e |||t |||h |||o |||d |||s ||
#  ||__|||__|||__|||__|||__|||__|||__||
#  |/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
#   * http://search.cpan.org/~markstos/CGI-Application-4.21/lib/CGI/Application.pm'
#   * http://search.cpan.org/~ceeshek/CGI-Application-Plugin-TT-1.04/lib/CGI/Application/Plugin/TT.pm
#   * http://search.cpan.org/~abw/Template-Toolkit-2.20/lib/Template.pm
#
sub cgiapp_init
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |c|g|i|a|p|p|_|i|n|i|t|
	# +-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();
	my $conf = $self->param('cf');	# String, Config file
	my $webc = $self->param('wf');	# String, WebUI config file

	# Load config file, Template configuration, and so on
	$self->loadconfig() if( -r $conf && -T _ && -r $webc && -T _ );
	$self->{'database'} = undef();
}

sub setup
{
	# +-+-+-+-+-+
	# |s|e|t|u|p|
	# +-+-+-+-+-+
	my $self = shift();

	$self->start_mode('Empty');
	$self->error_mode('exception');
	$self->mode_param('x');
	$self->run_modes( 
		'Empty' => 'api_empty',
		'Query' => 'api_query',
	);
}

sub cgiapp_prerun
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |c|g|i|a|p|p|_|p|r|e|r|u|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	require Kanadzuchi::RDB;
	require Kanadzuchi::RDB::Schema;

	my $self = shift();
	my $hdbi = undef();	# Database handle

	# Create database object
	$self->{'database'} = new Kanadzuchi::RDB( 'count' => 0, 'cache' => {} );

	# Set values to Kanadzuchi::Database object, Create data source name
	try {
		unless( $self->{'database'}->setup($self->{'sysconfig'}->{'database'}) )
		{
			Kanadzuchi::Exception::API->throw( '-text' => 'Failed to setup' );
		}

		if( length($self->{'database'}->datasn()) < 5 )
		{
			# Datatabase name or database type is not defined
			Kanadzuchi::Exception::API->throw( 
				'-text' => 'Failed to create data source name' );
		}
		
		eval{ 
			$hdbi = Kanadzuchi::RDB::Schema->connect(
					$self->{'database'}->datasn(),
					$self->{'database'}->username(),
					$self->{'database'}->password() );
		};

		Kanadzuchi::Exception::API->throw( '-text' => $@ ) if( $@ );
		$self->{'database'}->handle($hdbi);
	}
	catch Kanadzuchi::Exception::API with {
		$self->exception(shift());
	};

	# Set HTTP header, Character set, Language
	$self->query->charset('UTF-8');
}

sub cgiapp_postrun
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |c|g|i|a|p|p|_|p|o|s|t|r|u|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();
}

sub teardown
{
	# +-+-+-+-+-+-+-+-+
	# |t|e|a|r|d|o|w|n|
	# +-+-+-+-+-+-+-+-+
	my $self = shift();
}


#   ____ ____ ____ ____ ____ ____ ____ 
#  ||M |||e |||t |||h |||o |||d |||s ||
#  ||__|||__|||__|||__|||__|||__|||__||
#  |/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
# Kanadzuchi::API::HTTP Methods
#
sub loadconfig
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |l|o|a|d|c|o|n|f|i|g|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Load BounceHammer config file
	# @Param	None
	my $self = shift();
	my $json = undef();	# Hash reference of config file(JSON::Syck)
	my $yaml = undef();
	my $conf = $self->param('cf');
	my $webc = $self->param('wf');

	use Kanadzuchi::Metadata;
	$json = shift( @{Kanadzuchi::Metadata->to_object($conf)} );
	$self->{'sysconfig'} = $json if( ref($json) eq q|HASH| );

	$yaml = shift( @{Kanadzuchi::Metadata->to_object($webc)} );
	$self->{'webconfig'} = $yaml if( ref($yaml) eq q|HASH| );
}

sub api_empty
{
	# +-+-+-+-+-+-+-+-+-+
	# |a|p|i|_|e|m|p|t|y|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return empty page
	# @Param	None
	my $self = shift();
	return();
}

sub api_query
{
	# +-+-+-+-+-+-+-+-+-+
	# |a|p|i|_|q|u|e|r|y|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Send message token and return serialized result.
	# @Param	None
	my $self = shift();
	return() unless( length($self->param('token')) );

	require Kanadzuchi::Mail::Stored::RDB;
	my $answer = [];
	my $isjson = 1;
	my $string = q();
	my $pagecf = { 'currentpagenum' => 1, 'resultperpage' => 1 };
	my $wherec = { 'token' => lc($self->param('token')) };

	$answer = Kanadzuchi::Mail::Stored::RDB->searchandnew( $self->{'database'}, $wherec, \$pagecf, 1 );
	$string = Kanadzuchi::Mail::Stored::RDB->serialize( $answer, $isjson );

	return($string);
}

sub exception
{
	# +-+-+-+-+-+-+-+-+-+
	# |e|x|c|e|p|t|i|o|n|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Print exceptional message
	# @Param <obj>	Kanadzuchi::Exception object
	my $self = shift();
	my $mesg = shift();
	return($mesg);
}

1;
__END__
