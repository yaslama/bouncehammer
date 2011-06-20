-- $Id: MySQL-dailyupdates.sql,v 1.1.2.1 2011/06/20 03:43:41 ak Exp $
-- bounceHammer Daily Updates table for MySQL 4.x

CREATE TABLE t_dailyupdates (
	id		INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	thetime		INTEGER NOT NULL UNIQUE,
	thedate		CHARACTER VARYING(15) NOT NULL UNIQUE,
	inserted	INTEGER DEFAULT 0,
	updated		INTEGER DEFAULT 0,
	skipped		INTEGER DEFAULT 0,
	failed		INTEGER DEFAULT 0,
	executed	INTEGER DEFAULT 0,
	modified	INTEGER DEFAULT 0,
	description	CHARACTER VARYING(255),
	disabled	TINYINT DEFAULT 0,
	INDEX(thedate)
);
