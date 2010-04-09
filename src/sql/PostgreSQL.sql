-- $Id: PostgreSQL.sql,v 1.10 2010/04/09 06:40:00 ak Exp $
-- BounceHammer for PostgreSQL

CREATE TABLE t_hostgroups (
	id		INTEGER NOT NULL,
	name		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
ALTER TABLE ONLY t_hostgroups ADD CONSTRAINT pk_hostgroups PRIMARY KEY (id);

CREATE TABLE t_providers (
	id		INTEGER NOT NULL,
	name		CHARACTER VARYING(63) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_providers_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_providers_id_seq OWNED BY t_providers.id;
ALTER TABLE t_providers ALTER COLUMN id SET DEFAULT nextval('t_providers_id_seq'::regclass);
ALTER TABLE ONLY t_providers ADD CONSTRAINT pk_providers PRIMARY KEY (id);

CREATE TABLE t_addressers (
	id		INTEGER NOT NULL,
	email		CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_addressers_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_addressers_id_seq OWNED BY t_addressers.id;
ALTER TABLE t_addressers ALTER COLUMN id SET DEFAULT nextval('t_addressers_id_seq'::regclass);
ALTER TABLE ONLY t_addressers ADD CONSTRAINT pk_addressers PRIMARY KEY (id);

CREATE TABLE t_senderdomains (
	id		INTEGER NOT NULL,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_senderdomains_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_senderdomains_id_seq OWNED BY t_senderdomains.id;
ALTER TABLE t_senderdomains ALTER COLUMN id SET DEFAULT nextval('t_senderdomains_id_seq'::regclass);
ALTER TABLE ONLY t_senderdomains ADD CONSTRAINT pk_senderdomains PRIMARY KEY (id);


CREATE TABLE t_destinations (
	id		INTEGER NOT NULL,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_destinations_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_destinations_id_seq OWNED BY t_destinations.id;
ALTER TABLE t_destinations ALTER COLUMN id SET DEFAULT nextval('t_destinations_id_seq'::regclass);
ALTER TABLE ONLY t_destinations ADD CONSTRAINT pk_destinations PRIMARY KEY (id);


CREATE TABLE t_reasons (
	id		INTEGER NOT NULL,
	why		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
ALTER TABLE ONLY t_reasons ADD CONSTRAINT pk_reasons PRIMARY KEY (id);


CREATE TABLE t_bouncelogs (
	id		INTEGER NOT NULL,
	addresser	INTEGER NOT NULL REFERENCES t_addressers(id),
	recipient	CHARACTER VARYING(255) NOT NULL,
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
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_bouncelogs_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_bouncelogs_id_seq OWNED BY t_bouncelogs.id;
ALTER TABLE t_bouncelogs ALTER COLUMN id SET DEFAULT nextval('t_bouncelogs_id_seq'::regclass);
ALTER TABLE ONLY t_bouncelogs ADD CONSTRAINT pk_bouncelogs PRIMARY KEY (id);


CREATE VIEW v1_bouncelogs AS
	SELECT
		b.id AS id,
		b.addresser AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		b.frequency AS freq,
		b.bounced,
		b.updated,
		b.hostgroup,
		b.provider,
		b.reason
	FROM
		t_bouncelogs b,
		t_senderdomains s
	WHERE (
		( b.senderdomain = s.id ) AND 
		( b.disabled = 0 )
	);

CREATE VIEW v2_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		d.domainname AS dest,
		b.frequency AS freq,
		b.bounced,
		b.updated,
		b.hostgroup,
		b.provider,
		b.reason
	FROM
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_destinations d
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND 
		( b.disabled = 0 )
	);

CREATE VIEW v3_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		d.domainname AS dest,
		b.frequency AS freq,
		b.bounced,
		b.updated,
		b.hostgroup,
		b.provider,
		b.reason
	FROM
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_destinations d
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND 
		( b.destination = d.id ) AND
		( b.disabled = 0 )
	);

CREATE VIEW v4_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		b.frequency AS freq,
		b.bounced,
		b.updated,
		g.name AS hostgroup,
		p.name AS provider,
		w.why AS reason
	FROM
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_hostgroups g,
		t_providers p,
		t_reasons w
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND
		( b.hostgroup = g.id ) AND
		( b.provider = p.id ) AND
		( b.reason = w.id ) AND
		( b.disabled = 0 )
	);

CREATE VIEW v5_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		d.domainname AS dest,
		b.frequency AS freq,
		b.bounced,
		b.updated,
		g.name AS hostgroup,
		p.name AS provider,
		w.why AS reason
	FROM
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_destinations d,
		t_hostgroups g,
		t_providers p,
		t_reasons w
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND
		( b.destination = d.id ) AND
		( b.hostgroup = g.id ) AND
		( b.provider = p.id ) AND
		( b.reason = w.id ) AND
		( b.disabled = 0 )
	);

CREATE VIEW v6_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		b.frequency AS freq,
		('1970-01-01 09:00:00+09'::timestamp with time zone + ((b.bounced)::double precision * '00:00:01'::interval)) AS bounced,
		('1970-01-01 09:00:00+09'::timestamp with time zone + ((b.updated)::double precision * '00:00:01'::interval)) AS updated,
		g.name AS hostgroup,
		p.name AS provider,
		w.why AS reason
	FROM 
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_hostgroups g,
		t_providers p,
		t_reasons w
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND
		( b.hostgroup = g.id ) AND
		( b.provider = p.id ) AND
		( b.reason = w.id ) AND
		( b.disabled = 0 )
	);

CREATE VIEW v7_bouncelogs AS
	SELECT
		b.id AS id,
		a.email AS addr,
		b.recipient AS rcpt,
		s.domainname AS sender,
		d.domainname AS dest,
		b.frequency AS freq,
		('1970-01-01 09:00:00+09'::timestamp with time zone + ((b.bounced)::double precision * '00:00:01'::interval)) AS bounced,
		('1970-01-01 09:00:00+09'::timestamp with time zone + ((b.updated)::double precision * '00:00:01'::interval)) AS updated,
		g.name AS hostgroup,
		p.name AS provider,
		w.why AS reason
	FROM 
		t_bouncelogs b,
		t_addressers a,
		t_senderdomains s,
		t_destinations d,
		t_hostgroups g,
		t_providers p,
		t_reasons w
	WHERE (
		( b.addresser = a.id ) AND 
		( b.senderdomain = s.id ) AND
		( b.destination = d.id ) AND
		( b.hostgroup = g.id ) AND
		( b.provider = p.id ) AND
		( b.reason = w.id ) AND
		( b.disabled = 0 )
	);

CREATE INDEX i_bouncelogs_token ON t_bouncelogs USING btree (token);
CREATE INDEX i_bouncelogs_reason ON t_bouncelogs USING btree (reason);
CREATE INDEX i_bouncelogs_bounced ON t_bouncelogs USING btree (bounced);
CREATE INDEX i_bouncelogs_updated ON t_bouncelogs USING btree (updated);
CREATE INDEX i_bouncelogs_provider ON t_bouncelogs USING btree (provider);
CREATE INDEX i_bouncelogs_hostgroup ON t_bouncelogs USING btree (hostgroup);
CREATE INDEX i_bouncelogs_addresser ON t_bouncelogs USING btree (addresser);
CREATE INDEX i_bouncelogs_recipient ON t_bouncelogs USING btree (recipient);
CREATE INDEX i_bouncelogs_destination ON t_bouncelogs USING btree (destination);
CREATE INDEX i_bouncelogs_senderdomain ON t_bouncelogs USING btree (senderdomain);

CREATE INDEX i_bouncelogs_ar ON t_bouncelogs USING btree ( addresser, recipient );
CREATE INDEX i_bouncelogs_ad ON t_bouncelogs USING btree ( addresser, destination );
CREATE INDEX i_bouncelogs_adw ON t_bouncelogs USING btree ( addresser, destination, reason );
CREATE INDEX i_bouncelogs_adg ON t_bouncelogs USING btree ( addresser, destination, hostgroup );
CREATE INDEX i_bouncelogs_adgw ON t_bouncelogs USING btree ( addresser, destination, hostgroup, reason );

CREATE INDEX i_bouncelogs_rs ON t_bouncelogs USING btree ( recipient, senderdomain );
CREATE INDEX i_bouncelogs_rsw ON t_bouncelogs USING btree ( recipient, senderdomain, reason );
CREATE INDEX i_bouncelogs_rsg ON t_bouncelogs USING btree ( recipient, senderdomain, hostgroup );
CREATE INDEX i_bouncelogs_rsgw ON t_bouncelogs USING btree ( recipient, senderdomain, hostgroup, reason );

CREATE INDEX i_bouncelogs_dw ON t_bouncelogs USING btree ( destination, reason );
CREATE INDEX i_bouncelogs_db ON t_bouncelogs USING btree ( destination, bounced );
CREATE INDEX i_bouncelogs_df ON t_bouncelogs USING btree ( destination, frequency );
CREATE INDEX i_bouncelogs_ds ON t_bouncelogs USING btree ( destination, senderdomain );
CREATE INDEX i_bouncelogs_dsw ON t_bouncelogs USING btree ( destination, senderdomain, reason );

CREATE INDEX i_bouncelogs_sw ON t_bouncelogs USING btree ( senderdomain, reason );
CREATE INDEX i_bouncelogs_sb ON t_bouncelogs USING btree ( senderdomain, bounced );
CREATE INDEX i_bouncelogs_sp ON t_bouncelogs USING btree ( senderdomain, provider );
CREATE INDEX i_bouncelogs_sg ON t_bouncelogs USING btree ( senderdomain, hostgroup );
CREATE INDEX i_bouncelogs_sf ON t_bouncelogs USING btree ( senderdomain, frequency );
CREATE INDEX i_bouncelogs_sbw ON t_bouncelogs USING btree ( senderdomain, bounced, reason );
CREATE INDEX i_bouncelogs_sbp ON t_bouncelogs USING btree ( senderdomain, bounced, provider );
CREATE INDEX i_bouncelogs_sbg ON t_bouncelogs USING btree ( senderdomain, bounced, hostgroup );
CREATE INDEX i_bouncelogs_sbf ON t_bouncelogs USING btree ( senderdomain, bounced, frequency );
CREATE INDEX i_bouncelogs_sbgw ON t_bouncelogs USING btree ( senderdomain, bounced, hostgroup, reason );
CREATE INDEX i_bouncelogs_sbpw ON t_bouncelogs USING btree ( senderdomain, bounced, provider, reason );
CREATE INDEX i_bouncelogs_sfgw ON t_bouncelogs USING btree ( senderdomain, frequency, hostgroup, reason );
CREATE INDEX i_bouncelogs_sfpw ON t_bouncelogs USING btree ( senderdomain, frequency, provider, reason );
CREATE INDEX i_bouncelogs_sbgwf ON t_bouncelogs USING btree ( senderdomain, bounced, hostgroup, reason, frequency );
CREATE INDEX i_bouncelogs_sbpwf ON t_bouncelogs USING btree ( senderdomain, bounced, provider, reason, frequency );

CREATE INDEX i_bouncelogs_gw ON t_bouncelogs USING btree ( hostgroup, reason );
CREATE INDEX i_bouncelogs_gwb ON t_bouncelogs USING btree ( hostgroup, reason, bounced );
CREATE INDEX i_bouncelogs_gwf ON t_bouncelogs USING btree ( hostgroup, reason, frequency );

CREATE INDEX i_bouncelogs_pw ON t_bouncelogs USING btree ( provider, reason );
CREATE INDEX i_bouncelogs_pwb ON t_bouncelogs USING btree ( provider, reason, bounced );
CREATE INDEX i_bouncelogs_pwf ON t_bouncelogs USING btree ( provider, reason, frequency );

CREATE INDEX i_addressers_e ON t_addressers USING btree (email);
CREATE INDEX i_addressers_ie ON t_addressers USING btree (id, email);
CREATE INDEX i_senderdomains_d ON t_senderdomains USING btree (domainname);
CREATE INDEX i_senderdomains_id ON t_senderdomains USING btree (id, domainname);
CREATE INDEX i_destinations_d ON t_destinations USING btree (domainname);
CREATE INDEX i_destinations_id ON t_destinations USING btree (id, domainname);
CREATE INDEX i_hostgroups_n ON t_hostgroups USING btree ( name );
CREATE INDEX i_hostgroups_in ON t_hostgroups USING btree ( id, name );
CREATE INDEX i_reasons_w ON t_reasons USING btree ( why );
CREATE INDEX i_reasons_iw ON t_reasons USING btree ( id, why );

