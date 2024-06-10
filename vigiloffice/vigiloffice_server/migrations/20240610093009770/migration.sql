BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "parkings" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "floodingSensor" json NOT NULL,
    "flameSensor" json NOT NULL,
    "avoidanceSensor" json NOT NULL,
    "rgbLed" json NOT NULL,
    "alarm" json NOT NULL,
    "lastUpdate" timestamp without time zone
);


--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240610093009770', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240610093009770', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
