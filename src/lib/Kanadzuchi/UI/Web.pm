# $Id: Web.pm,v 1.26 2010/11/13 19:10:54 ak Exp $
# -Id: WebUI.pm,v 1.6 2009/10/05 08:51:03 ak Exp -
# -Id: WebUI.pm,v 1.11 2009/08/27 05:09:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::
                        
 ##  ##         ##      
 ##  ##   ####  ##      
 ##  ##  ##  ## #####   
 ######  ###### ##  ##  
 ######  ##     ##  ##  
 ##  ##   ####  #####   
package Kanadzuchi::UI::Web;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'CGI::Application';
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::HTMLPrototype;
use CGI::Application::Plugin::Session;
use Kanadzuchi;
use Kanadzuchi::Metadata;
use Kanadzuchi::Exceptions;
use Kanadzuchi::Time;
use Error ':try';
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
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

	my $available = [ qw( en ja ) ];	# Avaiable languages
	my $sysconfig = $self->param('cf');	# String, Config file
	my $webconfig = $self->param('wf');	# String, WebUI config file
	my $templates = $self->param('tf');	# String, Templates
	my $l10nroots = [ '../template/l10n/', $templates.'/l10n/' ];
	my $ttbasedir = 'standard';

	my $ttinclude = [];
	my $httpalang = $ENV{'HTTP_ACCEPT_LANGUAGE'} || 'en-us';
	my $httpquery = $self->query();
	my $htsession = $self->session();

	# Load config file,
	$self->loadconfig() if( -r $sysconfig && -T _ && -r $webconfig && -T _ );
	$self->{'language'} = lc $self->{'webconfig'}->{'language'} || 'en';
	$self->{'datetime'} = bless( localtime(), 'Time::Piece' );
	$self->{'database'} = undef();

	# Detect browser language, Default is English
	if( ! defined $htsession->param('language') )
	{
		$htsession->param( 
			'-name' => 'language', 
			'-value' => $httpquery->param('fe_language') 
					|| substr( $httpalang, 0, 2 ) 
					|| $self->{'language'} 
					|| 'en'
			);

		$htsession->expire( $self->{'webconfig'}->{'session'}->{'expires'} || '+9h' );
	}
	elsif( defined $httpquery->param('fe_language') && 
		$httpquery->param('fe_language') ne $htsession->param('language') ){

		$htsession->param( 
			'-name' => 'language', 
			'-value' => $httpquery->param('fe_language') );
	}

	$self->{'language'} = $htsession->param('language');
	$self->{'language'} = 'en' unless grep { $self->{'language'} } @$available;
	$self->query->charset('UTF-8');

	# Insert the template paths, '../tmpl/*' overrides configurated sytem
	# template directory in bouncehammer.cf
	map { $_ .= $self->{'language'} } @$l10nroots;
	$ttinclude = $l10nroots;

	foreach my $__subdir ( 'page', 'element', 'stylesheet', 'javascript' )
	{
		push( @$ttinclude, 
			'../template/'.$ttbasedir.'/'.$__subdir,
			$templates.'/'.$ttbasedir.'/'.$__subdir );
	}
	$self->tt_config( 'TEMPLATE_OPTIONS' => { 'INCLUDE_PATH' => $ttinclude } );
}

sub setup
{
	# +-+-+-+-+-+
	# |s|e|t|u|p|
	# +-+-+-+-+-+
	my $self = shift();

	$self->start_mode('Index');
	$self->error_mode('exception');
	$self->mode_param('x');
	$self->run_modes( 
		'About'		=> 'about',
		'Aggregate'	=> 'aggregation',
		'DailyUpdates'	=> 'dailyupdates',
		'Delete'	=> 'deletetherecord',
		'Index'		=> 'putindexpage',
		'ListOf'	=> 'listofcontents',
		'Parse'		=> 'onlineparser',
		'Profile'	=> 'systemprofile',
		'Search'	=> 'onlinesearch',
		'StartSearch'	=> 'putsearchform',
		'Summary'	=> 'datasummary',
		'TableControl'	=> 'tablecontrol',
		'TableList'	=> 'tablelist',
		'Test'		=> 'puttestform',
		'Token'		=> 'maketoken',
		'Update'	=> 'updatetherecord',
	);
}

sub cgiapp_prerun
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |c|g|i|a|p|p|_|p|r|e|r|u|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();
	my $bddr = undef();	# (Kanadzuchi::BdDR) Database object
	my $conf = $self->{'sysconfig'};

	# Create database object
	require Kanadzuchi::BdDR;
	$bddr = new Kanadzuchi::BdDR();

	# Set values to Kanadzuchi::BdDR object, Create data source name
	try {
		$bddr->setup( $conf->{'database'} );
		unless( $bddr->connect() )
		{
			my $errormsg .= 'Failed to connect DB'."\n";
			my $boundary = '-' x 64;
			$errormsg .= $boundary;
			$errormsg .= "\n ".$bddr->error->{'string'};
			$errormsg .= $boundary;
			$errormsg .= "\n";
			Kanadzuchi::Exception::Web->throw( '-text' => $errormsg );
		}
		$self->{'database'} = $bddr;
	}
	catch Kanadzuchi::Exception::Web with {
		$self->exception(shift())
	};
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

sub tt_pre_process
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|t|_|p|r|e|_|p|r|o|c|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();

	my $httpport = $ENV{'SERVER_PORT'} || 0;
	my $httphost = $ENV{'HTTP_HOST'} || 'localhost';
	my $majorver = $Kanadzuchi::VERSION || '0.0.0';
	my $htscript = $ENV{'SCRIPT_NAME'} || '/';
	my $pathinfo = $ENV{'PATH_INFO'} || q();

	$httphost .= ':'.$httpport if( $httpport != 0 && $httpport != 80 );
	$majorver =~ s{\A(\d+[.]\d+)[.]\d+}{$1};

	$self->tt_params( 
		'pv_systemname' => $Kanadzuchi::SYSNAME,
		'pv_sysversion' => $Kanadzuchi::VERSION,
		'pv_scriptname' => $htscript,
		'pv_head1title' => $Kanadzuchi::SYSNAME.'<sup>'.$majorver.'</sup>',
		'pv_thepageuri' => 'http://'.$httphost.$htscript,
		'pv_mylanguage' => $self->{'language'},
		'pv_prototype' => $self->prototype,
		'pv_pathinfo' => $pathinfo,
		'pv_thisyear' => $self->{'datetime'}->year(),
		'pv_tzoffset' => Kanadzuchi::Time->second2tz( $self->{'datetime'}->tzoffset() ),
	);
}

sub tt_post_process
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|t|_|p|o|s|t|_|p|r|o|c|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();
}

#   ____ ____ ____ ____ ____ ____ ____ 
#  ||M |||e |||t |||h |||o |||d |||s ||
#  ||__|||__|||__|||__|||__|||__|||__||
#  |/__\|/__\|/__\|/__\|/__\|/__\|/__\|
# 
# Kanadzuchi::UI::Web Methods
sub loadconfig
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |l|o|a|d|c|o|n|f|i|g|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Load BounceHammer config file
	# @Param	None
	my $self = shift();
	my $sysconfig = shift @{ Kanadzuchi::Metadata->to_object($self->param('cf')) };
	$self->{'sysconfig'} = $sysconfig if( ref($sysconfig) eq q|HASH| );

	my $webconfig = shift @{ Kanadzuchi::Metadata->to_object($self->param('wf')) };
	$self->{'webconfig'} = $webconfig if( ref($webconfig) eq q|HASH| );
}

*error = *e;
sub e
{
	# +-+
	# |e|
	# +-+
	#
	# @Description	Return error message to browser
	# @Param <head>	(String) error header
	# @Param <body>	(String) error message
	# @See		template/l10n/??/error.tt
	my $self = shift();
	my $head = shift() || 'generic';
	my $body = shift() || q();
	my $file = 'div-error.html';

	$self->tt_params( 
		'pv_errorhead' => $head,
		'pv_errorbody' => ref($body) eq q|ARRAY| 
				? join( '<br />', @$body )
				: $body,
	);
	return $self->tt_process($file);
}

sub exception
{
	# +-+-+-+-+-+-+-+-+-+
	# |e|x|c|e|p|t|i|o|n|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return exception to browser
	# @Param <str>	(String) Error message
	my $self = shift();
	my $text = shift();
	my $file = 'exception.html';
	my $mode = $self->get_current_runmode() || q();

	if( $mode =~ m{\A(?:Update|Delete|TableControl|Parse|Token)\z} )
	{
		$file = 'div-exception.html' 
	}
	$self->tt_params( 'pv_exception' => $text );
	return $self->tt_process($file);
}

1;
__END__
