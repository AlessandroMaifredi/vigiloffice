BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "lamps" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "lightSensor" json NOT NULL,
    "motionSensor" json NOT NULL,
    "flameSensor" json NOT NULL,
    "rgbLed" json NOT NULL,
    "alarm" json NOT NULL
);


--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240605212358102', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240605212358102', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
