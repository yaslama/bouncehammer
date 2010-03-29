# $Id: Web.pm,v 1.12 2010/03/27 14:14:20 ak Exp $
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
use Kanadzuchi::Exceptions;
use Kanadzuchi::Time;
use Compress::Zlib;
use Error ':try';
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#

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
	my $conf = $self->param('cf');	# String, Config file
	my $webc = $self->param('wf');	# String, WebUI config file
	my $tmpl = $self->param('tf');	# String, Templates
	my $path = [];			# Array ref, INCLUDE_PATH
	my $lang = $ENV{'HTTP_ACCEPT_LANGUAGE'} || q(en-us);

	# Insert the template paths, '../tmpl/*' overrides configurated sytem
	# template directory in bouncehammer.cf
	foreach my $__subdir ( 'page', 'help', 'element', 'stylesheet', 'javascript' )
	{
		push( @{$path}, 
			'../template/standard/'.$__subdir,
			$tmpl.q(/standard/).$__subdir );
	}

	# Load config file, Template configuration, and so on
	$self->loadconfig() if( -r $conf && -T _ && -r $webc && -T _ );
	$self->tt_config( 'TEMPLATE_OPTIONS' => { 'INCLUDE_PATH' => $path } );
	$self->{'language'} = $self->{'webconfig'}->{'language'};
	$self->{'datetime'} = bless( localtime(), 'Time::Piece' );
	$self->{'database'} = undef();

	my $q = $self->query;
	my $s = $self->session;

	if( ! defined($s->param('language')) )
	{
		my $_lang = $q->param('language') || substr( $lang, 0, 2 ) || $self->{'language'} || q(en);
		$s->param( '-name' => 'language', '-value' => $_lang );
		$s->expire($self->{'webconfig'}->{'session'}->{'expires'});
	}
	elsif( defined($q->param('language')) && $q->param('language') ne $s->param('language') )
	{
		$s->param( '-name' => 'language', '-value' => $q->param('language') );
	}

	$self->{'language'} = $s->param('language');
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
		'Test' => 'test_ontheweb',
		'Parse' => 'parse_ontheweb',
		'Index' => 'index_ontheweb',
		'Token' => 'token_ontheweb',
		'Search' => 'search_ontheweb',
		'Update' => 'update_ontheweb',
		'Profile' => 'profile_ontheweb',
		'Summary' => 'summary_ontheweb',
		'TableList' => 'tablelist_ontheweb',
		'TableControl' => 'tablectl_ontheweb',
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
	$self->{'database'} = new Kanadzuchi::RDB();

	# Set values to Kanadzuchi::Database object, Create data source name
	try {
		unless( $self->{'database'}->setup($self->{'sysconfig'}->{'database'}) )
		{
			Kanadzuchi::Exception::Web->throw( '-text' => 'Failed to setup' );
		}

		if( length($self->{'database'}->datasn()) < 5 )
		{
			# Datatabase name or database type is not defined
			Kanadzuchi::Exception::Web->throw( 
				'-text' => 'Failed to create data source name' );
		}
		
		eval{ 
			$hdbi = Kanadzuchi::RDB::Schema->connect(
					$self->{'database'}->datasn(), 
					$self->{'database'}->username(),
					$self->{'database'}->password() );
		};

		Kanadzuchi::Exception::Web->throw( '-text' => $@ ) if( $@ );
		$self->{'database'}->handle($hdbi);
	}
	catch Kanadzuchi::Exception::Web with {
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

sub tt_pre_process
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|t|_|p|r|e|_|p|r|o|c|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	my $self = shift();
	my $port = $ENV{'SERVER_PORT'} || 0;
	my $host = $ENV{'HTTP_HOST'} || q(localhost);
	my $vers = $Kanadzuchi::VERSION || q(0.0.0);
	my $scri = $ENV{'SCRIPT_NAME'} || q(/);
	my $path = $ENV{'PATH_INFO'} || q();

	$host .= ( $port != 0 && $port != 80 ) ? q(:).$port : q();
	$vers =~ s{[.]\d+\z}{};

	$self->tt_params( 
		'systemname' => $Kanadzuchi::SYSNAME,
		'sysversion' => $Kanadzuchi::VERSION,
		'scriptname' => $scri,
		'head1title' => $Kanadzuchi::SYSNAME.q(<sup>).$vers.q(</sup>),
		'thepageuri' => q(http://).$host.$scri,
		'mylanguage' => $self->{'language'},
		'prototype' => $self->prototype,
		'pathinfo' => $path,
		'thisyear' => $self->{'datetime'}->year(),
		'tzoffset' => Kanadzuchi::Time->second2tz( $self->{'datetime'}->tzoffset() ),
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

sub cryptcbc
{
	# +-+-+-+-+-+-+-+-+
	# |c|r|y|p|t|c|b|c|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Encrypt/Decrypt text|data
	# @Param <str>	(String) Plain text|Encrypted data
	# @Param <flg>	(Character) e = Encrypt, d = Decrypt
	# @Return	(String) Encrypted hex string
	#		(String) Decrypted plain text
	require Crypt::CBC;
	my $self = shift();
	my $data = shift() || return(q{});
	my $flag = shift() || return(q{});
	my $conf = $self->{'webconfig'}->{'security'}->{'crypt'};
	my $cipher = undef();	# Crypt::CBC object

	$cipher = new Crypt::CBC( '-key' => $conf->{'key'}, '-chipher' => $conf->{'chipher'} );
	$cipher->salt($conf->{'salt'});

	return( $cipher->encrypt_hex(Compress::Zlib::compress($data)) ) if( $flag eq 'e' );
	return( Compress::Zlib::uncompress($cipher->decrypt_hex($data)) ) if( $flag eq 'd' );
}

sub encryptit
{
	# +-+-+-+-+-+-+-+-+-+
	# |e|n|c|r|y|p|t|i|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Wrapper method of cryptcbc()
	# @Param <str>	(String) Plain text
	# @Return	(String) Encrypted hex string
	# @See		cryptcbc()
	my( $self, $data ) = @_;
	return( $self->cryptcbc( $data, q(e) ) );
}

sub decryptit
{
	# +-+-+-+-+-+-+-+-+-+
	# |d|e|c|r|y|p|t|i|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Wrapper method of cryptcbc()
	# @Param <str>	(String) Encrypted text(hex)
	# @Return	(String) Plain text
	# @See		cryptcbc()
	my( $self, $data ) = @_;
	return( $self->cryptcbc( $data, q(d) ) );
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
	my $file = q(exception.).$self->{'language'}.q(.html);

	$self->tt_params( 'exception' => $mesg );
	$self->tt_process($file);
}

1;
__END__
