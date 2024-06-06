BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "lamps" ADD COLUMN "lastUpdate" timestamp without time zone;

--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240606085020713', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240606085020713', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
