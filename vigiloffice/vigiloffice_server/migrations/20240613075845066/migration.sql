BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "parkings" ADD COLUMN "renterId" text;

--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240613075845066', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240613075845066', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
