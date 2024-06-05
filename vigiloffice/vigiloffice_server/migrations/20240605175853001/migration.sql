BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "devices" (
    "id" bigserial PRIMARY KEY,
    "type" text NOT NULL,
    "macAddress" text NOT NULL
);


--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240605175853001', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240605175853001', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
