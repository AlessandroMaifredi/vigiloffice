BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "hvacs" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hvacs" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "type" text NOT NULL,
    "flameSensor" json NOT NULL,
    "tempSensor" json NOT NULL,
    "ventActuator" json NOT NULL,
    "alarm" json NOT NULL,
    "lastUpdate" timestamp without time zone
);

--
-- ACTION DROP TABLE
--
DROP TABLE "lamps" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "lamps" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "type" text NOT NULL,
    "lightSensor" json NOT NULL,
    "motionSensor" json NOT NULL,
    "flameSensor" json NOT NULL,
    "rgbLed" json NOT NULL,
    "alarm" json NOT NULL,
    "lastUpdate" timestamp without time zone
);

--
-- ACTION DROP TABLE
--
DROP TABLE "parkings" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "parkings" (
    "id" bigserial PRIMARY KEY,
    "macAddress" text NOT NULL,
    "type" text NOT NULL,
    "floodingSensor" json NOT NULL,
    "flameSensor" json NOT NULL,
    "avoidanceSensor" json NOT NULL,
    "rgbLed" json NOT NULL,
    "alarm" json NOT NULL,
    "lastUpdate" timestamp without time zone,
    "renterId" text
);


--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240615091834515', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240615091834515', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
