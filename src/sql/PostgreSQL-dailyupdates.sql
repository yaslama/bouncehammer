-- $Id: PostgreSQL-dailyupdates.sql,v 1.2.2.1 2011/06/20 03:43:41 ak Exp $
-- bounceHammer Daily Updates table for PostgreSQL

CREATE TABLE t_dailyupdates (
	id		INTEGER NOT NULL,
	thetime		INTEGER NOT NULL UNIQUE,
	thedate		CHARACTER VARYING(15) NOT NULL UNIQUE,
	inserted	INTEGER DEFAULT 0,
	updated		INTEGER DEFAULT 0,
	skipped		INTEGER DEFAULT 0,
	failed		INTEGER DEFAULT 0,
	executed	INTEGER DEFAULT 0,
	modified	INTEGER DEFAULT 0,
	description	CHARACTER VARYING(255),
	disabled	INT2 DEFAULT 0
);
CREATE SEQUENCE t_dailyupdates_id_seq INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1;
ALTER SEQUENCE t_dailyupdates_id_seq OWNED BY t_dailyupdates.id;
ALTER TABLE t_dailyupdates ALTER COLUMN id SET DEFAULT nextval('t_dailyupdates_id_seq'::regclass);
ALTER TABLE ONLY t_dailyupdates ADD CONSTRAINT pk_dailyupdates PRIMARY KEY (id);
CREATE INDEX i_dailyupdates_thedate ON t_dailyupdates USING btree (thedate);
