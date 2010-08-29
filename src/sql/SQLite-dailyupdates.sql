-- $Id: SQLite-dailyupdates.sql,v 1.1 2010/08/16 11:57:56 ak Exp $
-- BounceHammer Daily Updates table for SQLite 
CREATE TABLE t_dailyupdates (
	id		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	thetime		INTEGER NOT NULL UNIQUE,
	thedate		CHARACTER VARYING(15) NOT NULL UNIQUE,
	inserted	INTEGER DEFAULT 0,
	updated		INTEGER DEFAULT 0,
	skipped		INTEGER DEFAULT 0,
	failed		INTEGER DEFAULT 0,
	executed	INTEGER DEFAULT 0,
	modified	INTEGER DEFAULT 0,
	description	CHARACTER VARYING(255),
	disabled	INTEGER DEFAULT 0
);

CREATE INDEX i_dailyupdates_thedate ON t_dailyupdates(thedate);

