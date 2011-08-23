# $Id: 055_mail-group.t,v 1.31.2.15 2011/08/21 18:49:38 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Test::More ( 'no_plan' );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $BaseGrp = q|Kanadzuchi::Mail::Group|;
my $Classes = {
	'neighbor'	=> q|Kanadzuchi::Mail::Group::Neighbor|,
	'smartphone'	=> q|Kanadzuchi::Mail::Group::Smartphone|,
	'webmail'	=> q|Kanadzuchi::Mail::Group::WebMail|,
	'aesmartphone'	=> q|Kanadzuchi::Mail::Group::AE::Smartphone|,
	'alsmartphone'	=> q|Kanadzuchi::Mail::Group::AL::Smartphone|,
	'alwebmail'	=> q|Kanadzuchi::Mail::Group::AL::WebMail|,
	'arcellphone'	=> q|Kanadzuchi::Mail::Group::AR::Cellphone|,
	'arsmartphone'	=> q|Kanadzuchi::Mail::Group::AR::Smartphone|,
	'arwebmail'	=> q|Kanadzuchi::Mail::Group::AR::WebMail|,
	'atsmartphone'	=> q|Kanadzuchi::Mail::Group::AT::Smartphone|,
	'atcellphone'	=> q|Kanadzuchi::Mail::Group::AT::Cellphone|,
	'aucellphone'	=> q|Kanadzuchi::Mail::Group::AU::Cellphone|,
	'ausmartphone'	=> q|Kanadzuchi::Mail::Group::AU::Smartphone|,
	'auwebmail'	=> q|Kanadzuchi::Mail::Group::AU::WebMail|,
	'awcellphone'	=> q|Kanadzuchi::Mail::Group::AW::Cellphone|,
	'awsmartphone'	=> q|Kanadzuchi::Mail::Group::AW::Smartphone|,
	'besmartphone'	=> q|Kanadzuchi::Mail::Group::BE::Smartphone|,
	'bgcellphone'	=> q|Kanadzuchi::Mail::Group::BG::Cellphone|,
	'bgsmartphone'	=> q|Kanadzuchi::Mail::Group::BG::Smartphone|,
	'bmsmartphone'	=> q|Kanadzuchi::Mail::Group::BM::Smartphone|,
	'brcellphone'	=> q|Kanadzuchi::Mail::Group::BR::Cellphone|,
	'brsmartphone'	=> q|Kanadzuchi::Mail::Group::BR::Smartphone|,
	'brwebmail'	=> q|Kanadzuchi::Mail::Group::BR::WebMail|,
	'bssmartphone'	=> q|Kanadzuchi::Mail::Group::BS::Smartphone|,
	'cacellphone'	=> q|Kanadzuchi::Mail::Group::CA::Cellphone|,
	'casmartphone'	=> q|Kanadzuchi::Mail::Group::CA::Smartphone|,
	'cawebmail'	=> q|Kanadzuchi::Mail::Group::CA::WebMail|,
	'chcellphone'	=> q|Kanadzuchi::Mail::Group::CH::Cellphone|,
	'chsmartphone'	=> q|Kanadzuchi::Mail::Group::CH::Smartphone|,
	'clsmartphone'	=> q|Kanadzuchi::Mail::Group::CL::Smartphone|,
	'cnsmartphone'	=> q|Kanadzuchi::Mail::Group::CN::Smartphone|,
	'cnwebmail'	=> q|Kanadzuchi::Mail::Group::CN::WebMail|,
	'cocellphone'	=> q|Kanadzuchi::Mail::Group::CO::Cellphone|,
	'cosmartphone'	=> q|Kanadzuchi::Mail::Group::CO::Smartphone|,
	'crcellphone'	=> q|Kanadzuchi::Mail::Group::CR::Cellphone|,
	'czsmartphone'	=> q|Kanadzuchi::Mail::Group::CZ::Smartphone|,
	'czwebmail'	=> q|Kanadzuchi::Mail::Group::CZ::WebMail|,
	'decellphone'	=> q|Kanadzuchi::Mail::Group::DE::Cellphone|,
	'desmartphone'	=> q|Kanadzuchi::Mail::Group::DE::Smartphone|,
	'dewebmail'	=> q|Kanadzuchi::Mail::Group::DE::WebMail|,
	'dksmartphone'	=> q|Kanadzuchi::Mail::Group::DK::Smartphone|,
	'dosmartphone'	=> q|Kanadzuchi::Mail::Group::DO::Smartphone|,
	'ecsmartphone'	=> q|Kanadzuchi::Mail::Group::EC::Smartphone|,
	'egsmartphone'	=> q|Kanadzuchi::Mail::Group::EG::Smartphone|,
	'egwebmail'	=> q|Kanadzuchi::Mail::Group::EG::WebMail|,
	'escellphone'	=> q|Kanadzuchi::Mail::Group::ES::Cellphone|,
	'essmartphone'	=> q|Kanadzuchi::Mail::Group::ES::Smartphone|,
	'eswebmail'	=> q|Kanadzuchi::Mail::Group::ES::WebMail|,
	'frcellphone'	=> q|Kanadzuchi::Mail::Group::FR::Cellphone|,
	'frsmartphone'	=> q|Kanadzuchi::Mail::Group::FR::Smartphone|,
	'frwebmail'	=> q|Kanadzuchi::Mail::Group::FR::WebMail|,
	'grsmartphone'	=> q|Kanadzuchi::Mail::Group::GR::Smartphone|,
	'gtsmartphone'	=> q|Kanadzuchi::Mail::Group::GT::Smartphone|,
	'hksmartphone'	=> q|Kanadzuchi::Mail::Group::HK::Smartphone|,
	'hnsmartphone'	=> q|Kanadzuchi::Mail::Group::HN::Smartphone|,
	'hrcellphone'	=> q|Kanadzuchi::Mail::Group::HR::Cellphone|,
	'hrsmartphone'	=> q|Kanadzuchi::Mail::Group::HR::Smartphone|,
	'husmartphone'	=> q|Kanadzuchi::Mail::Group::HU::Smartphone|,
	'idsmartphone'	=> q|Kanadzuchi::Mail::Group::ID::Smartphone|,
	'iecellphone'	=> q|Kanadzuchi::Mail::Group::IE::Cellphone|,
	'iesmartphone'	=> q|Kanadzuchi::Mail::Group::IE::Smartphone|,
	'ilcellphone'	=> q|Kanadzuchi::Mail::Group::IL::Cellphone|,
	'ilsmartphone'	=> q|Kanadzuchi::Mail::Group::IL::Smartphone|,
	'ilwebmail'	=> q|Kanadzuchi::Mail::Group::IL::WebMail|,
	'incellphone'	=> q|Kanadzuchi::Mail::Group::IN::Cellphone|,
	'insmartphone'	=> q|Kanadzuchi::Mail::Group::IN::Smartphone|,
	'inwebmail'	=> q|Kanadzuchi::Mail::Group::IN::WebMail|,
	'irwebmail'	=> q|Kanadzuchi::Mail::Group::IR::WebMail|,
	'iscellphone'	=> q|Kanadzuchi::Mail::Group::IS::Cellphone|,
	'issmartphone'	=> q|Kanadzuchi::Mail::Group::IS::Smartphone|,
	'itcellphone'	=> q|Kanadzuchi::Mail::Group::IT::Cellphone|,
	'itsmartphone'	=> q|Kanadzuchi::Mail::Group::IT::Smartphone|,
	'jmsmartphone'	=> q|Kanadzuchi::Mail::Group::JM::Smartphone|,
	'jpcellphone'	=> q|Kanadzuchi::Mail::Group::JP::Cellphone|,
	'jpsmartphone'	=> q|Kanadzuchi::Mail::Group::JP::Smartphone|,
	'jpwebmail'	=> q|Kanadzuchi::Mail::Group::JP::WebMail|,
	'kesmartphone'	=> q|Kanadzuchi::Mail::Group::KE::Smartphone|,
	'krwebmail'	=> q|Kanadzuchi::Mail::Group::KR::WebMail|,
	'lbsmartphone'	=> q|Kanadzuchi::Mail::Group::LB::Smartphone|,
	'lkcellphone'	=> q|Kanadzuchi::Mail::Group::LK::Cellphone|,
	'lksmartphone'	=> q|Kanadzuchi::Mail::Group::LK::Smartphone|,
	'lusmartphone'	=> q|Kanadzuchi::Mail::Group::LU::Smartphone|,
	'lvwebmail'	=> q|Kanadzuchi::Mail::Group::LV::WebMail|,
	'masmartphone'	=> q|Kanadzuchi::Mail::Group::MA::Smartphone|,
	'mdwebmail'	=> q|Kanadzuchi::Mail::Group::MD::WebMail|,
	'mesmartphone'	=> q|Kanadzuchi::Mail::Group::ME::Smartphone|,
	'mksmartphone'	=> q|Kanadzuchi::Mail::Group::MK::Smartphone|,
	'mosmartphone'	=> q|Kanadzuchi::Mail::Group::MO::Smartphone|,
	'mucellphone'	=> q|Kanadzuchi::Mail::Group::MU::Cellphone|,
	'mxcellphone'	=> q|Kanadzuchi::Mail::Group::MX::Cellphone|,
	'mxsmartphone'	=> q|Kanadzuchi::Mail::Group::MX::Smartphone|,
	'mysmartphone'	=> q|Kanadzuchi::Mail::Group::MY::Smartphone|,
	'ngsmartphone'	=> q|Kanadzuchi::Mail::Group::NG::Smartphone|,
	'nicellphone'	=> q|Kanadzuchi::Mail::Group::NI::Cellphone|,
	'nismartphone'	=> q|Kanadzuchi::Mail::Group::NI::Smartphone|,
	'nlcellphone'	=> q|Kanadzuchi::Mail::Group::NL::Cellphone|,
	'nlsmartphone'	=> q|Kanadzuchi::Mail::Group::NL::Smartphone|,
	'nosmartphone'	=> q|Kanadzuchi::Mail::Group::NO::Smartphone|,
	'nowebmail'	=> q|Kanadzuchi::Mail::Group::NO::WebMail|,
	'npcellphone'	=> q|Kanadzuchi::Mail::Group::NP::Cellphone|,
	'npsmartphone'	=> q|Kanadzuchi::Mail::Group::NP::Smartphone|,
	'nzcellphone'	=> q|Kanadzuchi::Mail::Group::NZ::Cellphone|,
	'nzsmartphone'	=> q|Kanadzuchi::Mail::Group::NZ::Smartphone|,
	'nzwebmail'	=> q|Kanadzuchi::Mail::Group::NZ::WebMail|,
	'omsmartphone'	=> q|Kanadzuchi::Mail::Group::OM::Smartphone|,
	'pasmartphone'	=> q|Kanadzuchi::Mail::Group::PA::Smartphone|,
	'pesmartphone'	=> q|Kanadzuchi::Mail::Group::PE::Smartphone|,
	'phsmartphone'	=> q|Kanadzuchi::Mail::Group::PH::Smartphone|,
	'pksmartphone'	=> q|Kanadzuchi::Mail::Group::PK::Smartphone|,
	'plcellphone'	=> q|Kanadzuchi::Mail::Group::PL::Cellphone|,
	'plsmartphone'	=> q|Kanadzuchi::Mail::Group::PL::Smartphone|,
	'prcellphone'	=> q|Kanadzuchi::Mail::Group::PR::Cellphone|,
	'prsmartphone'	=> q|Kanadzuchi::Mail::Group::PR::Smartphone|,
	'ptsmartphone'	=> q|Kanadzuchi::Mail::Group::PT::Smartphone|,
	'ptwebmail'	=> q|Kanadzuchi::Mail::Group::PT::WebMail|,
	'pysmartphone'	=> q|Kanadzuchi::Mail::Group::PY::Smartphone|,
	'rosmartphone'	=> q|Kanadzuchi::Mail::Group::RO::Smartphone|,
	'rowebmail'	=> q|Kanadzuchi::Mail::Group::RO::WebMail|,
	'rssmartphone'	=> q|Kanadzuchi::Mail::Group::RS::Smartphone|,
	'rusmartphone'	=> q|Kanadzuchi::Mail::Group::RU::Smartphone|,
	'ruwebmail'	=> q|Kanadzuchi::Mail::Group::RU::WebMail|,
	'sasmartphone'	=> q|Kanadzuchi::Mail::Group::SA::Smartphone|,
	'secellphone'	=> q|Kanadzuchi::Mail::Group::SE::Cellphone|,
	'sesmartphone'	=> q|Kanadzuchi::Mail::Group::SE::Smartphone|,
	'sgcellphone'	=> q|Kanadzuchi::Mail::Group::SG::Cellphone|,
	'sgsmartphone'	=> q|Kanadzuchi::Mail::Group::SG::Smartphone|,
	'sgwebmail'	=> q|Kanadzuchi::Mail::Group::SG::WebMail|,
	'sksmartphone'	=> q|Kanadzuchi::Mail::Group::SK::Smartphone|,
	'skwebmail'	=> q|Kanadzuchi::Mail::Group::SK::WebMail|,
	'srsmartphone'	=> q|Kanadzuchi::Mail::Group::SR::Smartphone|,
	'svsmartphone'	=> q|Kanadzuchi::Mail::Group::SV::Smartphone|,
	'thsmartphone'	=> q|Kanadzuchi::Mail::Group::TH::Smartphone|,
	'thwebmail'	=> q|Kanadzuchi::Mail::Group::TH::WebMail|,
	'trsmartphone'	=> q|Kanadzuchi::Mail::Group::TR::Smartphone|,
	'twsmartphone'	=> q|Kanadzuchi::Mail::Group::TW::Smartphone|,
	'twwebmail'	=> q|Kanadzuchi::Mail::Group::TW::WebMail|,
	'uasmartphone'	=> q|Kanadzuchi::Mail::Group::UA::Smartphone|,
	'ugsmartphone'	=> q|Kanadzuchi::Mail::Group::UG::Smartphone|,
	'ukcellphone'	=> q|Kanadzuchi::Mail::Group::UK::Cellphone|,
	'uksmartphone'	=> q|Kanadzuchi::Mail::Group::UK::Smartphone|,
	'ukwebmail'	=> q|Kanadzuchi::Mail::Group::UK::WebMail|,
	'uscellphone'	=> q|Kanadzuchi::Mail::Group::US::Cellphone|,
	'ussmartphone'	=> q|Kanadzuchi::Mail::Group::US::Smartphone|,
	'uswebmail'	=> q|Kanadzuchi::Mail::Group::US::WebMail|,
	'uysmartphone'	=> q|Kanadzuchi::Mail::Group::UY::Smartphone|,
	'vesmartphone'	=> q|Kanadzuchi::Mail::Group::VE::Smartphone|,
	'vnsmartphone'	=> q|Kanadzuchi::Mail::Group::VN::Smartphone|,
	'vnwebmail'	=> q|Kanadzuchi::Mail::Group::VN::WebMail|,
	'zacellphone'	=> q|Kanadzuchi::Mail::Group::ZA::Cellphone|,
	'zasmartphone'	=> q|Kanadzuchi::Mail::Group::ZA::Smartphone|,
	'zawebmail'	=> q|Kanadzuchi::Mail::Group::ZA::WebMail|,

};

my $Domains = {
	'neighbor'	=> [],
	'webmail'	=> [ qw( aol.com aol.jp gmail.com googlemail.com yahoo.com yahoo.co.jp 
				hotmail.com windowslive.com mac.com me.com excite.com
				lycos.com lycosmail.com facebook.com groups.facebook.com myspace.com
				love.com ygm.com latinmail.com myopera.com ) ],
	'smartphone'	=> [ qw( vertu.me mobileemail.vodafone.net 360.com ovi.com blackberry.orange.fr ) ],
	'aesmartphone'	=> [ qw( du.blackberry.com etisalat.blackberry.com ) ],
	'alsmartphone'	=> [ qw( amc.blackberry.com ) ],
	'alwebmail'	=> [ qw( albaniaonline.net primo.al ) ],
	'arcellphone'	=> [ qw( sms.ctimovil.com.ar nextel.net.ar alertas.personal.com.ar) ],
	'arsmartphone'	=> [ qw( movistar.ar.blackberry.com claroar.blackberry.com ) ],
	'arwebmail'	=> [ qw( uolsinectis.com.ar ciudad.com.ar ) ],
	'atcellphone'	=> [ qw( sms.t-mobile.at ) ],
	'atsmartphone'	=> [ qw( instantemail.t-mobile.at mobileemail.a1.net ) ],
	'aucellphone'	=> [ qw( sms.tim.telstra.com tim.telstra.com optusmobile.com.au ) ],
	'ausmartphone'	=> [ qw( telstra.blackberry.com three.blackberry.com optus.blackberry.com ) ],
	'auwebmail'	=> [ qw( fastmail.net fastmail.fm aussiemail.com.au ) ],
	'awcellphone'	=> [ qw( mas.aw ) ],
	'awsmartphone'	=> [ qw( setar.blackberry.com ) ],
	'besmartphone'	=> [ qw( base.blackberry.com proximus.blackberry.com blackberry.mobistar.be ) ],
	'bgcellphone'	=> [ qw( sms.globul.bg sms.mtel.net sms.vivacom.bg ) ],
	'bgsmartphone'	=> [ qw( mtel.blackberry.com globul.blackberry.com ) ],
	'bmsmartphone'	=> [ qw( m3wireless.blackberry.com ) ],
	'brcellphone'	=> [ qw( torpedoemail.com.br clarotorpedo.com.br ) ],
	'brsmartphone'	=> [ qw( timbrasil.blackberry.com vivo.blackberry.com oi.blackberry.com
				 nextel.br.blackberry.com claro.blackberry.com ) ],
	'brwebmail'	=> [ qw( bol.com.br zipmail.com.br ) ],
	'bssmartphone'	=> [ qw( btccybercell.blackberry.com ) ],
	'cacellphone'	=> [ qw( txt.bellmobility.ca txt.bell.ca vmobile.ca msg.telus.com ) ],
	'casmartphone'	=> [ qw( rogers.blackberry.net virginmobile.blackberry.com bell.blackberry.com ) ],
	'cawebmail'	=> [ qw( hushmail.com hush.com zworg.com ) ],
	'chcellphone'	=> [ qw( gsm.sunrise.ch ) ],
	'chsmartphone'	=> [ qw( mobileemail.swisscom.ch sunrise.blackberry.com ) ],
	'clsmartphone'	=> [ qw( entelpcs.blackberry.net movistar.cl.blackberry.com clarochile.blackberry.com ) ],
	'cnsmartphone'	=> [ qw( chinamobile.blackberry.com chinaunicom.blackberry.com ) ],
	'cnwebmail'	=> [ qw( 163.com 188.com ) ],
	'cocellphone'	=> [ qw( sms.tigo.com.co comcel.com.co movistar.com.co ) ],
	'cosmartphone'	=> [ qw( comcel.blackberry.com movistar.co.blackberry.com ) ],
	'crcellphone'	=> [ qw( ice.cr ) ],
	'czsmartphone'	=> [ qw( o2.blackberry.cz tmobilecz.blackberry.com ) ],
	'czwebmail'	=> [ qw( seznam.cz email.cz ) ],
	'decellphone'	=> [ qw( vodafone-sms.de o2online.de vodafone-sms.de smsmail.eplus.de ) ],
	'desmartphone'	=> [ qw( instantemail.t-mobile.de o2.blackberry.de eplus.blackberry.com ) ],
	'dewebmail'	=> [ qw( gmx.de ) ],
	'dksmartphone'	=> [ qw( tre.blackberry.com telenor.dk.blackberry.com teliadk.blackberry.com ) ],
	'dosmartphone'	=> [ qw( clarodr.blackberry.com vivard.blackberry.com ) ],
	'ecsmartphone'	=> [ qw( movistar.ec.blackberry.com porta.blackberry.com ) ],
	'egwebmail'	=> [ qw( gawab.com giza.cc ) ],
	'escellphone'	=> [ qw( correo.movistar.net vodafone.es ) ],
	'essmartphone'	=> [ qw( movistar.net amena.blackberry.com ) ],
	'eswebmail'	=> [ qw( terra.com ) ],
	'frcellphone'	=> [ qw( mms.bouyguestelecom.fr ) ],
	'frsmartphone'	=> [ qw( bouyguestelecom.blackberry.com ) ],
	'frwebmail'	=> [ qw( cario.fr mageos.com voila.fr ) ],
	'grsmartphone'	=> [ qw( windgr.blackberry.com cosmotegr.blackberry.com ) ],
	'gtsmartphone'	=> [ qw( claroguatemala.blackberry.com movistar.gt.blackberry.com ) ],
	'hksmartphone'	=> [ qw( threehk.blackberry.com csl.blackberry.com ) ],
	'hnsmartphone'	=> [ qw( clarohn.blackberry.com ) ],
	'hrcellphone'	=> [ qw( sms.t-mobile.hr ) ],
	'hrsmartphone'	=> [ qw( instantemail.t-mobile.hr ) ],
	'husmartphone'	=> [ qw( instantemail.t-mobile.hu ) ],
	'idsmartphone'	=> [ qw( indosat.blackberry.com telkomsel.blackberry.com xl.blackberry.com ) ],
	'iecellphone'	=> [ qw( sms.mymeteor.ie mms.mymeteor.ie ) ],
	'iesmartphone'	=> [ qw( o2mail.ie 3ireland.blackberry.com ) ],
	'ilcellphone'	=> [ qw( spikkosms.com ) ],
	'ilsmartphone'	=> [ qw( cellcom.blackberry.com pelephone.blackberry.com ) ],
	'ilwebmail'	=> [ qw( walla.co.il ) ],
	'incellphone'	=> [ qw( aircel.co.in airtelap.com airtelkk.com bplmobile.com ) ],
	'insmartphone'	=> [ qw( airtel.blackberry.com hutch.blackberry.com ) ],
	'inwebmail'	=> [ qw( ibibo.com in.com rediffmail.com) ],
	'irwebmail'	=> [ qw( iran.ir ) ],
	'iscellphone'	=> [ qw( sms.is ) ],
	'issmartphone'	=> [ qw( siminn.blackberry.com ) ],
	'itcellphone'	=> [ qw( sms.vodafone.it ) ],
	'itsmartphone'	=> [ qw( treitalia.blackberry.com tim.blackberry.com ) ],
	'jmsmartphone'	=> [ qw( cwjamaica.blackberry.net digicel.blackberry.com 
				 clarojm.blackberry.com ) ],
	'jpcellphone'	=> [ qw( docomo.ne.jp ezweb.ne.jp softbank.ne.jp d.vodafone.ne.jp jp-k.ne.jp
				 vertuclub.ne.jp ido.ne.jp eza.ido.ne.jp sky.tu-ka.ne.jp ) ],
	'jpsmartphone'	=> [ qw( i.softbank.jp docomo.blackberry.com emnet.ne.jp willcom.com
				 bb.emobile.jp ) ],
	'jpwebmail'	=> [ qw( auone.jp dwmail.jp mail.goo.ne.jp goo.jp infoseek.jp livedoor.com
				 nifty.com nifmail.jp kitty.jp x-o.jp ) ],
	'kesmartphone'	=> [ qw( airtel.blackberry.com safaricom.blackberry.com ) ],
	'krwebmail'	=> [ qw( hanmail.net empas.com ) ],
	'lbsmartphone'	=> [ qw( alfa.blackberry.com mtctouch.blackberry.com ) ],
	'lkcellphone'	=> [ qw( sms.mobitel.lk ) ],
	'lksmartphone'	=> [ qw( dialog.blackberry.com ) ],
	'lusmartphone'	=> [ qw( tango.blackberry.com mobileemail.luxgsm.lu voxmobile.blackberry.com ) ],
	'lvwebmail'	=> [ qw( inbox.lv mail.lv ) ],
	'masmartphone'	=> [ qw( iam.blackberry.com meditel.blackberry.com ) ],
	'mdwebmail'	=> [ qw( mail.md ) ],
	'mesmartphone'	=> [ qw( instantemail.t-mobile.me ) ],
	'mksmartphone'	=> [ qw( instantemail.t-mobile.mk ) ],
	'mosmartphone'	=> [ qw( ctm.blackberry.com smartonemo.blackberry.com ) ],
	'mucellphone'	=> [ qw( emtelworld.net ) ],
	'mxcellphone'	=> [ qw( msgnextel.com.mx ) ],
	'mxsmartphone'	=> [ qw( telcel.blackberry.net movistar.mx.blackberry.com 
				 iusacell.blackberry.com ) ],
	'mysmartphone'	=> [ qw( maxis.blackberry.com digi.my.blackberry.com ) ],
	'ngsmartphone'	=> [ qw( gloworld.blackberry.com ) ],
	'nicellphone'	=> [ qw( ideasclaro-ca.com ) ],
	'nismartphone'	=> [ qw( claronicaragua.blackberry.com movistar.ni.blackberry.com ) ],
	'nlcellphone'	=> [ qw( gin.nl sms.orange.nl ) ],
	'nlsmartphone'	=> [ qw( kpn.blackberry.com instantemail.t-mobile.nl uts.blackberry.com ) ],
	'nosmartphone'	=> [ qw( telenor.blackberry.com telenor.no.blackberry.com ) ],
	'nowebmail'	=> [ qw( runbox.com ) ],
	'npcellphone'	=> [ qw( sms.spicenepal.com ) ],
	'npsmartphone'	=> [ qw( ncell.blackberry.com ) ],
	'nzcellphone'	=> [ qw( sms.vodafone.net.nz ) ],
	'nzsmartphone'	=> [ qw( tnz.blackberry.com ) ],
	'nzwebmail'	=> [ qw( coolkiwi.com vodafone.co.nz wave.co.nz orcon.net.nz ) ],
	'omsmartphone'	=> [ qw( omanmobile.blackberry.com nawras.blackberry.com ) ],
	'pasmartphone'	=> [ qw( digicel.blackberry.com movistar.pa.blackberry.com 
				 claropanama.blackberry.com cwmovil.blackberry.com ) ],
	'pesmartphone'	=> [ qw( movistar.pe.blackberry.com claroperu.blackberry.com ) ],
	'phsmartphone'	=> [ qw( globe.blackberry.com smart.blackberry.com ) ],
	'pksmartphone'	=> [ qw( mobilink.blackberry.com ) ],
	'plcellphone'	=> [ qw( orange.pl text.plusgsm.pl ) ],
	'plsmartphone'	=> [ qw( era.blackberry.com iplus.blackberry.com ) ],
	'prcellphone'	=> [ qw( vtexto.com mmst5.tracfone.com cwemail.com ) ],
	'prsmartphone'	=> [ qw( vzwpr.blackberry.com claropr.blackberry.com ) ],
	'ptsmartphone'	=> [ qw( tmn.blackberry.com optimus.blackberry.com ) ],
	'ptwebmail'	=> [ qw( sapo.pt ) ],
	'pysmartphone'	=> [ qw( claropy.blackberry.com ) ],
	'rosmartphone'	=> [ qw( cosmotero.blackberry.com ) ],
	'rowebmail'	=> [ qw( posta.ro mail.co.ro ) ],
	'rssmartphone'	=> [ qw( telenorserbia.blackberry.com ) ],
	'rusmartphone'	=> [ qw( mts.blackberry.com beeline.blackberry.com ) ],
	'ruwebmail'	=> [ qw( mail.ru yandex.ru ) ],
	'sasmartphone'	=> [ qw( stc.blackberry.com mobily.blackberry.com ) ],
	'secellphone'	=> [ qw( sms.tele2.se ) ],
	'sesmartphone'	=> [ qw( telenor-se.blackberry.com tele2se.blackberry.com ) ],
	'sgcellphone'	=> [ qw( m1.com.sg starhub-enterprisemessaing.com ) ],
	'sgsmartphone'	=> [ qw( m1.blackberry.com singtel.blackberry.com starhub.blackberry.com ) ],
	'sgwebmail'	=> [ qw( insing.com ) ],
	'sksmartphone'	=> [ qw( tmobilesk.blackberry.com ) ],
	'skwebmail'	=> [ qw( post.sk pobox.sk ) ],
	'srsmartphone'	=> [ qw( teleg.blackberry.com ) ],
	'svsmartphone'	=> [ qw( movistar.sv.blackberry.com ) ],
	'thsmartphone'	=> [ qw( aiscorporatemail.blackberry.com dtac.blackberry.com ) ],
	'thwebmail'	=> [ qw( thaimail.com ) ],
	'trsmartphone'	=> [ qw( turkcell.blackberry.com avea.blackberry.com ) ],
	'twwebmail'	=> [ qw( seed.net.tw mars.seed.net.tw kingnet.com.tw ) ],
	'uasmartphone'	=> [ qw( mtsua.blackberry.com ) ],
	'ugsmartphone'	=> [ qw( utl.blackberry.com mtninternet.blackberry.com ) ],
	'ukcellphone'	=> [ qw( text.aql.com orange.net vodafone.net ) ],
	'uksmartphone'	=> [ qw( o2.co.uk instantemail.t-mobile.co.uk o2email.co.uk bt.blackberry.com) ],
	'ukwebmail'	=> [ qw( postmaster.co.uk yipple.com ) ],
	'uscellphone'	=> [ qw( vtext.com mms.att.net pm.sprint.com ) ],
	'ussmartphone'	=> [ qw( sprint.blackberry.net alltel.blackberry.com vzw.blackberry.net
				 att.blackberry.com mycingular.blackberry.net ) ],
	'uswebmail'	=> [ qw( bluetie.com lavabit.com luxsci.com inbox.com mail.com usa.com 
				 pobox.com onepost.net mail2world.com myemail.com shtrudel.com ) ],
	'uysmartphone'	=> [ qw( movistar.uy.blackberry.com clarouy.blackberry.com ) ],
	'vesmartphone'	=> [ qw( movistar.ve.blackberry.com ) ],
	'vnsmartphone'	=> [ qw( viettel.blackberry.com ) ],
	'vnwebmail'	=> [ qw( pmail.vnn.vn ) ],
	'zacellphone'	=> [ qw( sms.co.za voda.co.za ) ],
	'zasmartphone'	=> [ qw( cellc.blackberry.com mtn.blackberry.com ) ],
	'zawebmail'	=> [ qw( webmail.co.za mighty.co.za ) ],
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#

REQUIRE: {
	use_ok($BaseGrp);
	foreach my $c ( keys(%$Classes) ){ require_ok("$Classes->{$c}") }
}

METHODS: {
	can_ok($BaseGrp, qw(reperit postulat communisexemplar nominisexemplaria classisnomina));
	foreach my $c ( keys(%$Classes) ){ can_ok( $Classes->{$c}, 'reperit' ) } 

	LEGERE: {
		my $loadedgr = $BaseGrp->postulat();

		isa_ok( $loadedgr, q|ARRAY| );
		foreach my $g ( @$loadedgr )
		{
			ok( (grep { $g eq $_ } values(%$Classes)), $g );
		}
	}
}

# 3. Call class method
CLASS_METHODS: foreach my $c ( keys(%$Domains) )
{
	my $detected = {};
	my $thegroup = q();
	MATCH: foreach my $s ( @{$Domains->{$c}} )
	{
		$detected = $Classes->{ $c }->reperit($s);
		$thegroup = lc $Classes->{ $c };
		$thegroup =~ s{\A.+::}{};

		isa_ok( $detected, q|HASH|, '->reperit('.$s.')' );
		ok( $detected->{'class'}, '->reperit('.$s.')->class = '.$detected->{'class'} );
		is( $detected->{'group'}, $thegroup, '->reperit('.$s.')->group = '.$detected->{'group'} );
		ok( $detected->{'provider'}, '->reperit('.$s.')->provider = '.$detected->{'provider'} );
	}

	DONT_MATCH: foreach my $s ( @{$Domains->{$c}} )
	{
		$detected = $Classes->{ $c }->reperit($s.'.org');
		isa_ok( $detected, q|HASH|, '->reperit' );
		is( $detected->{'class'}, q(), '->class = ' );
		is( $detected->{'group'}, q(), '->group = ' );
		is( $detected->{'provider'}, q(), '->provider = ' );

	}
}

__END__
