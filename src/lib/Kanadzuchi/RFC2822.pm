# $Id: RFC2822.pm,v 1.11 2010/07/07 01:06:21 ak Exp $
# -Id: RFC2822.pm,v 1.1 2009/08/29 08:52:03 ak Exp -
# -Id: RFC2822.pm,v 1.6 2009/05/29 08:22:21 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                  
 #####  ###### ####   ####   ####   ####   ####   
 ##  ## ##    ##  ## ##  ## ##  ## ##  ## ##  ##  
 ##  ## ####  ##         ##  ####      ##     ##  
 #####  ##    ##      ####  ##  ##  ####   ####   
 ## ##  ##    ##  ## ##     ##  ## ##     ##      
 ##  ## ##     ####  ######  ####  ###### ######  
package Kanadzuchi::RFC2822;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Regular expression of valid RFC-2822 email address(<addr-spec>)
my $Rx = { 'rfc2822' => undef(), 'ignored' => undef(), 'domain' => undef(), };

# See http://www.ietf.org/rfc/rfc2822.txt
#  or http://www.ex-parrot.com/pdw/Mail-RFC822-Address.html ...
#   addr-spec       = local-part "@" domain
#   local-part      = dot-atom / quoted-string / obs-local-part
#   domain          = dot-atom / domain-literal / obs-domain
#   domain-literal  = [CFWS] "[" *([FWS] dcontent) [FWS] "]" [CFWS]
#   dcontent        = dtext / quoted-pair
#   dtext           = NO-WS-CTL /     ; Non white space controls
#                     %d33-90 /       ; The rest of the US-ASCII
#                     %d94-126        ;  characters not including "[",
#                                     ;  "]", or "\"
BUILD_REGULAR_EXPRESSIONS: {
	my $atom = qr{[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+}o;
	my $quoted_string = qr{"(?:\\[^\r\n]|[^\\"])*"}o;
	my $domain_literal = qr{\[(?:\\[\x01-\x09\x0B-\x0c\x0e-\x7f]|[\x21-\x5a\x5e-\x7e])*\]}o;
	my $dot_atom = qr{$atom(?:[.]$atom)*}o;
	my $local_part = qr{(?:$dot_atom|$quoted_string)}o;
	my $domain = qr{(?:$dot_atom|$domain_literal)}o;

	$Rx->{'rfc2822'} = qr{$local_part[@]$domain}o;
	$Rx->{'ignored'} = qr{$local_part[.]*[@]$domain}o;
	$Rx->{'domain'} = qr{$domain}o;
}

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub is_emailaddress
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|e|m|a|i|l|a|d|d|r|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether address is valid e-mail address or not
	# @Param <addr>	(String) e-Mail address
	# @Return	(Integer) 1 = is valid e-mail address
	#		(Integer) 0 = is not
	# return(1) if( $_[1] =~ $Rx->{rfc2822} );
	my $class = shift();
	my $email = shift() || return(0);
	return(0) if( $email =~ m{([\x00-\x1f]|\x1f)} );
	return(1) if( $email =~ $Rx->{'ignored'} );
	return(0);
}

sub is_domainpart
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|d|o|m|a|i|n|p|a|r|t|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether domain is valid domain part or not
	# @Param <addr>	(String) Domain name
	# @Return	(Integer) 1 = is valid domain part
	#		(Integer) 0 = is not
	my $class = shift();
	my $dpart = shift() || return(0);
	return(0) if( $dpart =~ m{([\x00-\x1f]|\x1f)} );
	return(1) if( $dpart =~ $Rx->{'domain'} );
	return(0);
}

sub is_mailerdaemon
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|m|a|i|l|e|r|d|a|e|m|o|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether address is MAILER-DAEMON or not
	# @Param <addr>	(String) e-Mail address
	# @Return	(Integer) 1 = is MAILER-DAEMON
	#		(Integer) 0 = is not
	my $class = shift();
	my $email = shift() || return(0);
	return(1) if( lc($email) =~ m{\bmailer-daemon\b} );
	return(0);
}

sub is_subaddress
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|s|u|b|a|d|d|r|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Whether address is sub-address or not
	# @Param <addr>	(String) e-Mail address
	# @Return	(Integer) 1 = is sub-address
	#		(Integer) 0 = is not
	# @See		http://tools.ietf.org/html/rfc5233
	my $class = shift();
	my $email = shift() || return(0);
	my $lpart = [ split(q{@},$email) ]->[0];

	return(0) unless( $class->is_emailaddress($email) );
	return(1) if( $lpart =~ m{\A[-_\w]+?[+][^@]+\z} );
	return(0);
}

sub expand_subaddress
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |e|x|p|a|n|d|_|s|u|b|a|d|d|r|e|s|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Expand sub-address: a+b=example.jp@... -> b@example.jp
	# @Param <addr>	(String) sub-address
	# @Return	(String) Expanded e-Mail address
	#		(String) Empty
	# @See		http://tools.ietf.org/html/rfc5233
	my $class = shift();
	my $email = shift() || return(q{});
	my $lpart = [ split(q{@},$email) ]->[0];
	my $xtemp = q();
	my $xaddr = q();

	return(q{}) unless( $class->is_subaddress($email) );
	if( $lpart =~ m{\A[-_\w]+?[+](\w[-._\w]+\w)[=](\w[-.\w]+\w)\z} )
	{
		$xtemp = $1.q{@}.$2;
		$xaddr = $xtemp if( $class->is_emailaddress($xtemp) );
	}
	return($xaddr);
}

sub cleanup
{
	# +-+-+-+-+-+-+-+
	# |c|l|e|a|n|u|p|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Clean up mail address
	# @Param <addr>	email address
	# @Return	(String) email address
	my $class = shift();
	my $email = shift();

	chomp($email);				# Remove CR/LF
	$email =~ s{\A\s+}{}g;			# Remove spaces in the head
	$email =~ s{\s+\z}{}g;			# Remove spaces in the tail
	$email =~ s{\Amailto:}{}g;		# Remove 'mailto' schema
	$email =~ s{\A.+[<](.+)[>]\z}{$1}g;	# Remove Comment block1
	$email =~ s{\A[<](.+)[>].+\z}{$1}g;	# Remove Comment block2
	$email =~ y{[]<>()'";: }{}d;		# Remove brackets and quotations
	return($email);
}

1;
__END__
