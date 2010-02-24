# $Id: Token.pm,v 1.2 2010/02/21 20:46:44 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                     
 ######         ##                   
   ##     ####  ##     ####  #####   
   ##    ##  ## ## ## ##  ## ##  ##  
   ##    ##  ## ####  ###### ##  ##  
   ##    ##  ## ## ## ##     ##  ##  
   ##     ####  ##  ## ####  ##  ##  
package Kanadzuchi::UI::Web::Token;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::String;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub token_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|o|k|e|n|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Make message token
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = q(messagetoken.).$self->{'language'}.q(.html);
	my $q = $self->query();

	if( defined($q->param('makenewtoken')) && $q->param('makenewtoken') == 1 )
	{
		$file = q(div-new-message-token.).$self->{'language'}.q(.html);
		my $_sender = defined($q->param('addresser')) ? lc($q->param('addresser')) : q();
		my $_recipt = defined($q->param('recipient')) ? lc($q->param('recipient')) : q();
		my $_string = q(Failed to create);

		$_string = Kanadzuchi::String->token( $_sender, $_recipt ) if( $_sender && $_recipt );

		$self->tt_params( 
			'addresser' => $_sender,
			'recipient' => $_recipt,
			'token' => $_string );
	}

	$self->tt_process($file);
}

1;
__END__
