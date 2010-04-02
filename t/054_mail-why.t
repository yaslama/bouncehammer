# $Id: 054_mail-why.t,v 1.3 2010/04/02 11:44:17 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 525 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Classes = {
        'filtered'	=> q(Kanadzuchi::Mail::Why::Filtered),
        'hostunknown'	=> q(Kanadzuchi::Mail::Why::HostUnknown),
        'mailboxfull'	=> q(Kanadzuchi::Mail::Why::MailboxFull),
        'relayingdenied'=> q(Kanadzuchi::Mail::Why::RelayingDenied),
        'systemfull'	=> q(Kanadzuchi::Mail::Why::SystemFull),
        'msgtoobig'	=> q(Kanadzuchi::Mail::Why::TooBig),
        'userunknown'	=> q(Kanadzuchi::Mail::Why::UserUnknown),
};

my $Strings = {
        'filtered'	=> [
		q(Sorry, Your remotehost looks suspiciously like spammer),
		q(The message was rejected because it contains prohibited virus or spam content),
		q(Message filtered. Please see the faqs section on spam),
		q(Blocked by policy: No spam please),
		q(Message rejected due to suspected spam content),
		q(Domain of sender address exampe.int does not exist),
	],
        'hostunknown'	=> [
		q(Recipient address rejected: Unknown domain name),
		q(Host Unknown),
	],
        'mailboxfull'	=> [
		q(Mailbox full),
		q(Mailbox is full),
		q(Too much mail data),
		q(Account is over quota),
		q(Account is temporarily over quota),
	],
        'relayingdenied'=> [ 
		q(Relaying denied),
		q{553 sorry, that domain isn't in my list of allowed rcpthosts (#5.7.1)},
	],
        'systemfull'	=> [ q(Requested mail action aborted: exceeded storage allocation) ],
        'msgtoobig'	=> [
		q(Message size exceeds fixed maximum message size),
		q(Message size exceeds fixed limit),
		q(Message size exceeds maximum value),
	],
        'userunknown'	=> [
		q(user01@example.jp: ...User Unknown),
		q(No such mailbox),
		q(Recipient address rejected: User unknown in relay recipient table),
		q(Recipient address rejected: User unknown in local recipient table),
		q(Recipient address rejected: User unknown in virtual mailbox table),
		q(Recipient address rejected: User unknown in virtual alias table),
		q(Recipient address rejected: Unknown user),
		q(Delivery error: dd this user doesn't have a site account.),
		q(Sorry, User unknown),
		q(Sorry, No mailbox here by that name),
		q(Mailbox not present),
		q(Requested action not taken: Mailbox unavailable),
		q(Recipient rejected: Mailbox would exceed maximum allowed storage),
		q(Recipient is not local),
		q(Unknown address),
		q(Unknown recipient),
	],
};

my $OtherString = 'This string does not match with any patterns';

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
REQUIRE: foreach my $c ( keys(%$Classes) ){ require_ok("$Classes->{$c}"); }
METHODS: foreach my $c ( keys(%$Classes) ){ can_ok( $Classes->{$c}, 'is_included' ); }

# 3. Call class method
CLASS_METHODS: foreach my $c ( keys(%$Classes) )
{
	MATCH: foreach my $s ( @{$Strings->{$c}} )
	{
		ok( $Classes->{$c}->is_included($s), 'Match String by '.$c.q{->is_included()} );
	}

	is( $Classes->{$c}->is_included($OtherString), 0, 'No Match String by '.$c.q{->is_included()} );

	ZERO: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues} )
	{
		my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
		is( $Classes->{$c}->is_included($z), 0,
			'No Match String by '.$c.'->is_included('.$argv.')' );
	}
}

__END__
