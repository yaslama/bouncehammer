# $Id: 000_compile-core.t,v 1.17 2010/05/30 06:07:14 ak Exp $
use strict;
use warnings;
use lib qw(./t/lib ./dist/lib ./src/lib);
use Test::More;

my $Modules = [
	q(Kanadzuchi),
	q(Kanadzuchi::Address),
	q(Kanadzuchi::Archive),
	q(Kanadzuchi::Archive::Bzip2),
	q(Kanadzuchi::Archive::Gzip),
	q(Kanadzuchi::Archive::Zip),
	q(Kanadzuchi::BdDR),
	q(Kanadzuchi::BdDR::BounceLogs),
	q(Kanadzuchi::BdDR::Cache),
	q(Kanadzuchi::BdDR::Page),
	q(Kanadzuchi::BdDR::BounceLogs::Masters),
	q(Kanadzuchi::Config::TestRun),
	q(Kanadzuchi::Exceptions),
	q(Kanadzuchi::Iterator),
	q(Kanadzuchi::Log),
	q(Kanadzuchi::Mail),
	q(Kanadzuchi::Mail::Bounced),
	q(Kanadzuchi::Mail::Bounced::aubyKDDI),
	q(Kanadzuchi::Mail::Bounced::Generic),
	q(Kanadzuchi::Mail::Bounced::NTTDoCoMo),
	q(Kanadzuchi::Mail::Bounced::SoftBank),
	q(Kanadzuchi::Mail::Bounced::Yahoo),
	q(Kanadzuchi::Mail::Group),
	q(Kanadzuchi::Mail::Group::JP::Cellphone),
	q(Kanadzuchi::Mail::Group::JP::Smartphone),
	q(Kanadzuchi::Mail::Group::JP::WebMail),
	q(Kanadzuchi::Mail::Group::Neighbor),
	q(Kanadzuchi::Mail::Group::WebMail),
	q(Kanadzuchi::Mail::Stored),
	q(Kanadzuchi::Mail::Stored::BdDR),
	q(Kanadzuchi::Mail::Stored::YAML),
	q(Kanadzuchi::Mail::Why),
	q(Kanadzuchi::Mail::Why::ExceedLimit),
	q(Kanadzuchi::Mail::Why::Filtered),
	q(Kanadzuchi::Mail::Why::HostUnknown),
	q(Kanadzuchi::Mail::Why::MailboxFull),
	q(Kanadzuchi::Mail::Why::RelayingDenied),
	q(Kanadzuchi::Mail::Why::SystemFull),
	q(Kanadzuchi::Mail::Why::TooBig),
	q(Kanadzuchi::Mail::Why::UserUnknown),
	q(Kanadzuchi::Mbox),
	q(Kanadzuchi::Mbox::Google),
	q(Kanadzuchi::Mbox::KLab),
	q(Kanadzuchi::Mbox::aubyKDDI),
	q(Kanadzuchi::Mbox::qmail),
	q(Kanadzuchi::MIME::Parser),
	q(Kanadzuchi::Metadata),
	q(Kanadzuchi::RFC1893),
	q(Kanadzuchi::RFC2606),
	q(Kanadzuchi::RFC2822),
	q(Kanadzuchi::Statistics),
	q(Kanadzuchi::String),
	q(Kanadzuchi::Time),
	q(Kanadzuchi::UI),
	q(Kanadzuchi::UI::CLI),
];

plan( tests => $#{$Modules} + 1 );
foreach my $module ( @$Modules ){ use_ok($module); }

__END__
