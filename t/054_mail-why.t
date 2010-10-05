# $Id: 054_mail-why.t,v 1.7 2010/10/05 11:30:57 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 852 );

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
        'msgtoobig'	=> q(Kanadzuchi::Mail::Why::MesgTooBig),
        'userunknown'	=> q(Kanadzuchi::Mail::Why::UserUnknown),
        'rejected'	=> q(Kanadzuchi::Mail::Why::Rejected),
        'systemerror'	=> q(Kanadzuchi::Mail::Why::SystemError),
        'securityerr'	=> q(Kanadzuchi::Mail::Why::SecurityError),
        'contenterr'	=> q(Kanadzuchi::Mail::Why::ContentError),
};

my $Strings = {
	'filtered'	=> [
		q{due to extended inactivity new mail is not currently being accepted for this mailbox},
		q{this account has been disabled or discontinued},
	],
        'contenterr'	=> [
		q(The message was rejected because it contains prohibited virus or spam content),
		q(Message filtered. Please see the faqs section on spam),
		q(Blocked by policy: No spam please),
		q(Message rejected due to suspected spam content),
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
	],
	'securityerr' => [
		q{553 sorry, that domain isn't in my list of allowed rcpthosts (#5.7.1)},
	],
	'systemerror' => [
		q{Server configuration error},
		q{Local error in processing},
		q{mail system configuration error},
		q{system config error},
		q{Too many hops},
	],
	'rejected' => [
		q{domain of sender address example.jp does not exist},
		q(Domain of sender address exampe.int does not exist),
		q(Sorry, Your remotehost looks suspiciously like spammer),
	],
        'systemfull'	=> [ q(Requested mail action aborted: exceeded storage allocation) ],
        'mesgtoobig'	=> [
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
METHODS: foreach my $c ( keys(%$Classes) ){ can_ok( $Classes->{$c}, 'textumhabet' ); }

# 3. Call class method
CLASS_METHODS: foreach my $c ( keys(%$Classes) )
{
	MATCH: foreach my $s ( @{$Strings->{$c}} )
	{
		ok( $Classes->{$c}->textumhabet($s), 'Match String by '.$c.'->textumhabet('.$s.')' );
	}

	is( $Classes->{$c}->textumhabet($OtherString), 0, 'No Match String by '.$c.'->textumhabet('.$OtherString.')' );

	ZERO: foreach my $z ( @{$Kanadzuchi::Test::ExceptionalValues}, @{$Kanadzuchi::Test::NegativeValues} )
	{
		my $argv = defined($z) ? sprintf("%#x", ord($z)) : 'undef()';
		is( $Classes->{$c}->textumhabet($z), 0,
			'No Match String by '.$c.'->textumhabet('.$argv.')' );
	}
}

__END__
