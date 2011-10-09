# $Id: 054_mail-why.t,v 1.8.2.2 2011/10/08 13:49:14 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( tests => 1006 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Classes = {
        'contenterr'	=> q(Kanadzuchi::Mail::Why::ContentError),
        'filtered'	=> q(Kanadzuchi::Mail::Why::Filtered),
        'hostunknown'	=> q(Kanadzuchi::Mail::Why::HostUnknown),
        'mailboxfull'	=> q(Kanadzuchi::Mail::Why::MailboxFull),
        'mailererror'	=> q(Kanadzuchi::Mail::Why::MailerError),
        'msgtoobig'	=> q(Kanadzuchi::Mail::Why::MesgTooBig),
        'notaccept'	=> q(Kanadzuchi::Mail::Why::NotAccept),
        'rejected'	=> q(Kanadzuchi::Mail::Why::Rejected),
        'relayingdenied'=> q(Kanadzuchi::Mail::Why::RelayingDenied),
        'securityerr'	=> q(Kanadzuchi::Mail::Why::SecurityError),
        'systemerror'	=> q(Kanadzuchi::Mail::Why::SystemError),
        'systemfull'	=> q(Kanadzuchi::Mail::Why::SystemFull),
        'userunknown'	=> q(Kanadzuchi::Mail::Why::UserUnknown),
};

my $Strings = {
        'contenterr' => [
		q(Message filtered. Please see the faqs section on spam),
		q(Blocked by policy: No spam please),
		q(Message rejected due to suspected spam content),
		q(The message was rejected because it contains prohibited virus or spam content),
	],
	'filtered' => [
		q{due to extended inactivity new mail is not currently being accepted for this mailbox},
		q{this account has been disabled or discontinued},
	],
        'hostunknown' => [
		q(Recipient address rejected: Unknown domain name),
		q(Host Unknown),
	],
        'mailboxfull' => [
		q(Mailbox full),
		q(Mailbox is full),
		q(Too much mail data),
		q(Account is over quota),
		q(Account is temporarily over quota),
	],
	'mailererror' => [
		q(X-Unix; 127),
		q(Command died with status 9),
	],
        'mesgtoobig' => [
		q(Message size exceeds fixed maximum message size),
		q(Message size exceeds fixed limit),
		q(Message size exceeds maximum value),
	],
	'notaccept' => [
		q(Name service error for ...),
		q(Sorry, Your remotehost looks suspiciously like spammer),
		q{we do not accept mail from hosts with dynamic ip or generic dns ptr-records}, # MAIL.RU
		q{we do not accept mail from dynamic ips}, # MAIL.RU
	],
	'rejected' => [
		q{sender rejected},
		q{domain of sender address example.jp does not exist},
		q(Domain of sender address exampe.int does not exist),
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
        'systemfull'	=> [ q(Requested mail action aborted: exceeded storage allocation) ],
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
