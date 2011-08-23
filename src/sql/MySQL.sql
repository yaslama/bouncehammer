-- $Id: MySQL.sql,v 1.9.2.2 2011/08/23 21:25:50 ak Exp $
-- bounceHammer for MySQL 4.x - 5.x

CREATE TABLE t_hostgroups (
	id		INTEGER NOT NULL PRIMARY KEY,
	name		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(name),
	INDEX(id,name)
);

CREATE TABLE t_providers (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name		CHARACTER VARYING(63) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(name),
	INDEX(id,name)
);

CREATE TABLE t_addressers (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	email		CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(email),
	INDEX(id,email)
);

CREATE TABLE t_senderdomains (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(domainname),
	INDEX(id,domainname)
);

CREATE TABLE t_destinations (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	domainname	CHARACTER VARYING(255) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(domainname),
	INDEX(id,domainname)
);

CREATE TABLE t_reasons (
	id		INTEGER NOT NULL PRIMARY KEY,
	why		CHARACTER VARYING(15) NOT NULL UNIQUE,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(why),
	INDEX(id,why)
);

CREATE TABLE t_bouncelogs (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
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
	disabled	TINYINT DEFAULT 0,
	INDEX(bounced), INDEX(hostgroup), INDEX(token), INDEX(addresser), INDEX(recipient), 
	INDEX(senderdomain), INDEX(destination), INDEX(updated), INDEX(reason), INDEX(provider),
	INDEX(addresser, recipient),
	INDEX(addresser, destination),
	INDEX(addresser, destination, reason),
	INDEX(addresser, destination, hostgroup),
	INDEX(addresser, destination, reason, hostgroup),
	INDEX(recipient, senderdomain),
	INDEX(recipient, senderdomain, reason),
	INDEX(recipient, senderdomain, hostgroup),
	INDEX(recipient, senderdomain, reason, hostgroup),
	INDEX(destination, reason),
	INDEX(destination, bounced),
	INDEX(destination, frequency),
	INDEX(destination, senderdomain),
	INDEX(destination, senderdomain, reason),
	INDEX(senderdomain, reason),
	INDEX(senderdomain, bounced),
	INDEX(senderdomain, hostgroup),
	INDEX(senderdomain, provider),
	INDEX(senderdomain, frequency),
	INDEX(senderdomain, bounced, reason),
	INDEX(senderdomain, bounced, hostgroup),
	INDEX(senderdomain, bounced, provider),
	INDEX(senderdomain, bounced, frequency),
	INDEX(senderdomain, bounced, hostgroup, reason),
	INDEX(senderdomain, bounced, provider, reason),
	INDEX(senderdomain, frequency, hostgroup, reason),
	INDEX(senderdomain, frequency, provider, reason),
	INDEX(senderdomain, bounced, frequency, hostgroup, reason),
	INDEX(senderdomain, bounced, frequency, provider, reason),
	INDEX(hostgroup, reason),
	INDEX(hostgroup, reason, bounced),
	INDEX(hostgroup, reason, frequency),
	INDEX(provider, reason),
	INDEX(provider, reason, bounced),
	INDEX(provider, reason, frequency)
);

