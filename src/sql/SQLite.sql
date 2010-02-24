-- $Id: SQLite.sql,v 1.8 2010/02/22 20:10:18 ak Exp $
-- BounceHammer for SQLite
CREATE TABLE t_hostgroups (
	id		INTEGER NOT NULL PRIMARY KEY,
	name		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_providers (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name		CHARACTER VARYING(63) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_addressers (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	email		CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_senderdomains (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_destinations (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_reasons (
	id		INTEGER NOT NULL PRIMARY KEY,
	why		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disable		INTEGER DEFAULT 0
);

CREATE TABLE t_bouncelogs (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	addresser	INTEGER NOT NULL REFERENCES t_addressers(id),
	recipient	CHARACTER VARYING(255) NOT NULL UNIQUE,
	senderdomain	INTEGER NOT NULL REFERENCES t_senderdomains(id),
	destination	INTEGER NOT NULL REFERENCES t_destinations(id),
	token		CHARACTER VARYING(40) NOT NULL UNIQUE,
	frequency	INTEGER DEFAULT 1,
	bounced		INTEGER,
	updated		INTEGER,
	hostgroup	INTEGER DEFAULT 1 REFERENCES t_hostgroups(id),
	provider	INTEGER DEFAULT 4 REFERENCES t_providers(id),
	reason		INTEGER DEFAULT 1 REFERENCES t_reasons(id),
	description	TEXT,
	disable		INTEGER DEFAULT 0
);
CREATE INDEX i_bouncelogs_token ON t_bouncelogs(token);
CREATE INDEX i_bouncelogs_reason ON t_bouncelogs(reason);
CREATE INDEX i_bouncelogs_bounced ON t_bouncelogs(bounced);
CREATE INDEX i_bouncelogs_updated ON t_bouncelogs(updated);
CREATE INDEX i_bouncelogs_provider ON t_bouncelogs(provider);
CREATE INDEX i_bouncelogs_hostgroup ON t_bouncelogs(hostgroup);
CREATE INDEX i_bouncelogs_addresser ON t_bouncelogs(addresser);
CREATE INDEX i_bouncelogs_recipient ON t_bouncelogs(recipient);
CREATE INDEX i_bouncelogs_destination ON t_bouncelogs(destination);
CREATE INDEX i_bouncelogs_senderdomain ON t_bouncelogs(senderdomain);

CREATE INDEX i_bouncelogs_ar ON t_bouncelogs( addresser, recipient );
CREATE INDEX i_bouncelogs_ad ON t_bouncelogs( addresser, destination );
CREATE INDEX i_bouncelogs_adw ON t_bouncelogs( addresser, destination, reason );
CREATE INDEX i_bouncelogs_adg ON t_bouncelogs( addresser, destination, hostgroup );
CREATE INDEX i_bouncelogs_adgw ON t_bouncelogs( addresser, destination, hostgroup, reason );

CREATE INDEX i_bouncelogs_rs ON t_bouncelogs( recipient, senderdomain );
CREATE INDEX i_bouncelogs_rsw ON t_bouncelogs( recipient, senderdomain, reason );
CREATE INDEX i_bouncelogs_rsg ON t_bouncelogs( recipient, senderdomain, hostgroup );
CREATE INDEX i_bouncelogs_rsgw ON t_bouncelogs( recipient, senderdomain, hostgroup, reason );

CREATE INDEX i_bouncelogs_dw ON t_bouncelogs( destination, reason );
CREATE INDEX i_bouncelogs_db ON t_bouncelogs( destination, bounced );
CREATE INDEX i_bouncelogs_df ON t_bouncelogs( destination, frequency );
CREATE INDEX i_bouncelogs_ds ON t_bouncelogs( destination, senderdomain );
CREATE INDEX i_bouncelogs_dsw ON t_bouncelogs( destination, senderdomain, reason );

CREATE INDEX i_bouncelogs_sw ON t_bouncelogs( senderdomain, reason );
CREATE INDEX i_bouncelogs_sb ON t_bouncelogs( senderdomain, bounced );
CREATE INDEX i_bouncelogs_sp ON t_bouncelogs( senderdomain, provider );
CREATE INDEX i_bouncelogs_sg ON t_bouncelogs( senderdomain, hostgroup );
CREATE INDEX i_bouncelogs_sf ON t_bouncelogs( senderdomain, frequency );
CREATE INDEX i_bouncelogs_sbw ON t_bouncelogs( senderdomain, bounced, reason );
CREATE INDEX i_bouncelogs_sbp ON t_bouncelogs( senderdomain, bounced, provider );
CREATE INDEX i_bouncelogs_sbg ON t_bouncelogs( senderdomain, bounced, hostgroup );
CREATE INDEX i_bouncelogs_sbf ON t_bouncelogs( senderdomain, bounced, frequency );
CREATE INDEX i_bouncelogs_sbgw ON t_bouncelogs( senderdomain, bounced, hostgroup, reason );
CREATE INDEX i_bouncelogs_sbpw ON t_bouncelogs( senderdomain, bounced, provider, reason );
CREATE INDEX i_bouncelogs_sfgw ON t_bouncelogs( senderdomain, frequency, hostgroup, reason );
CREATE INDEX i_bouncelogs_sfpw ON t_bouncelogs( senderdomain, frequency, provider, reason );
CREATE INDEX i_bouncelogs_sbgwf ON t_bouncelogs( senderdomain, bounced, hostgroup, reason, frequency );
CREATE INDEX i_bouncelogs_sbpwf ON t_bouncelogs( senderdomain, bounced, provider, reason, frequency );

CREATE INDEX i_bouncelogs_gw ON t_bouncelogs( hostgroup, reason );
CREATE INDEX i_bouncelogs_gwb ON t_bouncelogs( hostgroup, reason, bounced );
CREATE INDEX i_bouncelogs_gwf ON t_bouncelogs( hostgroup, reason, frequency );

CREATE INDEX i_bouncelogs_pw ON t_bouncelogs( provider, reason );
CREATE INDEX i_bouncelogs_pwb ON t_bouncelogs( provider, reason, bounced );
CREATE INDEX i_bouncelogs_pwf ON t_bouncelogs( provider, reason, frequency );

CREATE INDEX i_addressers_e ON t_addressers(email);
CREATE INDEX i_addressers_ie ON t_addressers(id, email);
CREATE INDEX i_senderdomains_d ON t_senderdomains(domainname);
CREATE INDEX i_senderdomains_id ON t_senderdomains(id, domainname);
CREATE INDEX i_destinations_d ON t_destinations(domainname);
CREATE INDEX i_destinations_id ON t_destinations(id, domainname);
CREATE INDEX i_hostgroups_n ON t_hostgroups( name );
CREATE INDEX i_hostgroups_in ON t_hostgroups( id, name );
CREATE INDEX i_reasons_w ON t_reasons( why );
CREATE INDEX i_reasons_iw ON t_reasons( id, why );

