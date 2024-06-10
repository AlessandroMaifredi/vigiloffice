BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hvacs" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "flameSensor" json NOT NULL,
    "tempSensor" json NOT NULL,
    "ventActuator" json NOT NULL,
    "alarm" json NOT NULL,
    "lastUpdate" timestamp without time zone
);


--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240607123752849', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240607123752849', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
